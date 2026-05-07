//
//  MotionGestureCoordinator.swift
//  FloatLojic
//
//  Created by Graceila Natasya on 06/05/26.
//


//
//  MotionGestureCoordinator.swift
//  FloatLojic
//
//  Bridges Core Motion detection with the PracticeViewModel state machine.
//
//  Responsibilities:
//    • Core Motion runs CONTINUOUSLY while PracticeView is on screen.
//    • Monitors the current disturbance state and applies different
//      motion rules per state:
//
//      ┌─────────────────────────────────────────────────────────────────┐
//      │ wind / noBait / fishNibble  →  user must stay STILL             │
//      │   • Any sustained motion ≥ noiseFloor for ~0.4 s → .failed     │
//      │   • Grace period prevents false positives from natural tremor   │
//      ├─────────────────────────────────────────────────────────────────┤
//      │ strike                      →  user must perform hook gesture   │
//      │   • strongValidHook or weakHook within timeout  → .strike       │
//      │   • Timeout is already handled by PracticeViewModel             │
//      └─────────────────────────────────────────────────────────────────┘
//
//  Ownership model:
//    PracticeViewModel owns this coordinator.
//    PracticeView observes PracticeViewModel only — no direct Core Motion access.
//

import Foundation
import Combine

@MainActor
final class MotionGestureCoordinator {

    // MARK: - Configuration

    private enum Config {
        /// How often the coordinator polls the GestureAnalyzer result.
        /// 20 Hz is enough; we don't need per-frame analysis.
        static let pollHz: Double = 20

        /// How long (seconds) sustained motion must persist in a non-strike
        /// state before we call it a deliberate gesture (not tremor).
        /// Range 0.3–0.5 s as agreed.
        static let nonStrikeGracePeriod: TimeInterval = 0.4

        /// The minimum acceleration magnitude (g) that counts as "motion"
        /// in non-strike states.  Mirrors GestureAnalyzer's noiseFloor.
        static let stillnessThreshold: Double = 0.4
    }

    // MARK: - Dependencies

    /// Core Motion layer — starts on init, never stops while coordinator lives.
    private let motionManager = MotionManager()

    /// Stateless classifier — called on each poll tick.
    private let gestureAnalyzer = GestureAnalyzer()

    /// Weak reference so the coordinator never extends the VM's lifetime.
    private weak var practiceVM: PracticeViewModel?

    // MARK: - Grace-period state

    /// Timestamp (relative to `Date.timeIntervalSinceReferenceDate`) when
    /// continuous motion was first detected in a non-strike state.
    /// `nil` means the device is currently still.
    private var motionOnsetTime: Date?

    // MARK: - Poll timer

    private var pollTimer: AnyCancellable?

    // MARK: - Init / lifecycle

    init(practiceVM: PracticeViewModel) {
        self.practiceVM = practiceVM
    }

    /// Call once when PracticeView appears.
    /// Core Motion starts here and keeps running until `stop()`.
    func start() {
        motionManager.startUpdates()
        startPolling()
    }

    /// Call when PracticeView disappears.
    /// Stops the poll timer AND Core Motion.
    func stop() {
        pollTimer?.cancel()
        pollTimer = nil
        motionManager.stopUpdates()
        resetGraceState()
    }

    // MARK: - Polling

    private func startPolling() {
        pollTimer = Timer.publish(every: 1.0 / Config.pollHz, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    /// Called at `pollHz`. Routes to the correct rule set based on current state.
    private func tick() {
        guard let vm = practiceVM,
              vm.isSessionActive,
              vm.feedbackState == nil else {
            // Session not active or already resolved — nothing to do.
            resetGraceState()
            return
        }

        let samples = motionManager.samples
        let result  = gestureAnalyzer.analyze(samples)

        switch vm.currentDisturbance {
        case .wind, .noBait, .fishNibble:
            handleNonStrikeTick(result: result, vm: vm)

        case .strike:
            handleStrikeTick(result: result, vm: vm)

        case nil:
            // Waiting between disturbances — reset grace period so we
            // don't carry stale onset time into the next disturbance.
            resetGraceState()
        }
    }

    // MARK: - Non-strike logic (wind / noBait / fishNibble)

    /// User must stay still. Sustained motion above stillnessThreshold
    /// for ≥ gracePeriod seconds triggers .failed.
    ///
    /// Grace period design:
    ///   1. First frame above threshold  → record onset time, don't fail yet.
    ///   2. Subsequent frames above threshold → check elapsed time.
    ///   3. If elapsed ≥ gracePeriod → trigger .failed.
    ///   4. Any frame below threshold  → clear onset time (motion stopped).
    private func handleNonStrikeTick(result: HookGestureResult, vm: PracticeViewModel) {
        let isMoving = isSignificantMotion(result)

        if isMoving {
            let now = Date()
            if let onset = motionOnsetTime {
                // Motion has been ongoing — check elapsed duration.
                let elapsed = now.timeIntervalSince(onset)
                if elapsed >= Config.nonStrikeGracePeriod {
                    // Sustained deliberate motion confirmed → penalise.
                    debugLog("Non-strike motion sustained for \(String(format: "%.2f", elapsed))s → .failed")
                    resetGraceState()
                    vm.handleMotionEvent(.failed)
                }
                // else: still within grace period, keep waiting.
            } else {
                // First frame of motion — start the grace-period clock.
                motionOnsetTime = now
                debugLog("Motion onset detected in non-strike state. Grace period started.")
            }
        } else {
            // Device is still — reset so a new burst starts fresh.
            if motionOnsetTime != nil {
                debugLog("Motion stopped before grace period elapsed — cleared.")
            }
            resetGraceState()
        }
    }

    // MARK: - Strike logic

    /// User must perform a hook gesture.
    /// strongValidHook or weakHook  → .strike (success).
    /// The .tooLate path is already handled by PracticeViewModel's timeout task;
    /// we only need to handle the success path here.
    private func handleStrikeTick(result: HookGestureResult, vm: PracticeViewModel) {
        switch result {
        case .strongValidHook, .weakHook:
            debugLog("Hook gesture detected (\(result)) during strike → .strike")
            resetGraceState()
            vm.handleMotionEvent(.strike)

        case .wrongDirection, .noMotion:
            // Still waiting for the gesture — let the timeout task handle expiry.
            break
        }
    }

    // MARK: - Helpers

    /// Returns true if the analyzer result indicates motion above the stillness
    /// threshold for non-strike states.
    ///
    /// We treat both `weakHook` / `strongValidHook` AND `wrongDirection` as
    /// "significant motion" because any direction of movement is forbidden in
    /// non-strike states — it doesn't have to look like a hook to be wrong.
    private func isSignificantMotion(_ result: HookGestureResult) -> Bool {
        switch result {
        case .strongValidHook, .weakHook, .wrongDirection:
            return true
        case .noMotion:
            return false
        }
    }

    private func resetGraceState() {
        motionOnsetTime = nil
    }

    // MARK: - Debug logging

    private func debugLog(_ message: String) {
        #if DEBUG
        print("[MotionGestureCoordinator] \(message)")
        #endif
    }
}
