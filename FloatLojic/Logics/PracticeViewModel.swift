//
//  PracticeViewModel.swift
//  FloatLojic
//
//  Created by Codex on 08/08/25.
//  Updated to integrate MotionGestureCoordinator.
//

import Combine
import SwiftUI

@MainActor
final class PracticeViewModel: ObservableObject {
    static let strikeResponseTimeout: TimeInterval = 5
    static let disturbancePause: TimeInterval = 0.5

    @Published private(set) var currentDisturbance: DisturbanceType?
    @Published private(set) var feedbackState: FeedbackCardState?
    @Published private(set) var isSessionActive = false

    // Async timeout task used only for the strike case.
    private var strikeTimeoutTask: Task<Void, Never>?

    // MARK: - Motion coordinator
    // Owns the coordinator so Core Motion lifetime is tied to the VM.
    // Lazy so we can pass `self` safely after init completes.
    private lazy var motionCoordinator = MotionGestureCoordinator(practiceVM: self)

    deinit {
        strikeTimeoutTask?.cancel()
    }

    // MARK: - Motion lifecycle

    /// Call from PracticeView.onAppear — starts Core Motion.
    /// Core Motion runs continuously from this point, regardless of session state.
    func startMotionTracking() {
        motionCoordinator.start()
    }

    /// Call from PracticeView.onDisappear — stops Core Motion.
    func stopMotionTracking() {
        motionCoordinator.stop()
    }

    // MARK: - Session control

    func startSession() {
        strikeTimeoutTask?.cancel()
        feedbackState = nil
        currentDisturbance = nil
        isSessionActive = true
    }

    @discardableResult
    func nextDisturbance() -> DisturbanceType? {
        guard isSessionActive, feedbackState == nil else {
            return nil
        }

        strikeTimeoutTask?.cancel()
        let nextDisturbance = DisturbanceType.allCases.randomElement() ?? .wind
        currentDisturbance = nextDisturbance
        scheduleStrikeTimeoutIfNeeded(for: nextDisturbance)

        return nextDisturbance
    }

    // MARK: - Input handling

    /// Called by the Tarik button in PracticeView (manual pull gesture).
    func handlePull() {
        guard isSessionActive, let currentDisturbance else { return }
        strikeTimeoutTask?.cancel()

        switch currentDisturbance {
        case .strike:
            finishRound(with: .strike)
        case .wind, .noBait, .fishNibble:
            finishRound(with: .failed)
        }
    }

    /// Called by MotionGestureCoordinator when Core Motion detects a relevant event.
    /// This is the ONLY entry point for motion-driven feedback — coordinator never
    /// calls `finishRound` directly to keep all state mutation here.
    func handleMotionEvent(_ outcome: FeedbackCardState) {
        guard isSessionActive, feedbackState == nil else { return }
        strikeTimeoutTask?.cancel()
        finishRound(with: outcome)
    }

    // MARK: - Cycle helpers (called from PracticeView loop)

    func finishNonStrikeCycle() async {
        guard isSessionActive, feedbackState == nil, currentDisturbance != .strike else {
            return
        }

        do {
            try await Task.sleep(
                nanoseconds: UInt64(Self.disturbancePause * 1_000_000_000)
            )
        } catch {
            return
        }

        guard isSessionActive, feedbackState == nil else { return }
        currentDisturbance = nil
    }

    func waitForStrikeResolution() async {
        guard currentDisturbance == .strike else { return }

        while isSessionActive, feedbackState == nil, currentDisturbance == .strike {
            do {
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 s poll
            } catch {
                return
            }
        }
    }

    // MARK: - Private helpers

    /// Starts the "too late" timer only when the disturbance is a strike.
    private func scheduleStrikeTimeoutIfNeeded(for disturbance: DisturbanceType) {
        guard disturbance == .strike else {
            strikeTimeoutTask = nil
            return
        }

        strikeTimeoutTask = Task { [weak self] in
            do {
                try await Task.sleep(
                    nanoseconds: UInt64(Self.strikeResponseTimeout * 1_000_000_000)
                )
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self?.finishRound(with: .tooLate)
                }
            } catch {
                return
            }
        }
    }

    /// Single point of truth for ending a round.
    private func finishRound(with feedback: FeedbackCardState) {
        guard isSessionActive else { return }
        isSessionActive = false
        currentDisturbance = nil
        feedbackState = feedback
    }
}
