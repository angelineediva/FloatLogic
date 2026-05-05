
//
//  HookGestureDetector.swift
//  FloatLojic
//
//  High-level coordinator that ties MotionManager and GestureAnalyzer together.
//  Runs periodic analysis on the rolling buffer and publishes the latest result.
//
//  Usage in a future SwiftUI view:
//
//      @StateObject private var detector = HookGestureDetector()
//
//      var body: some View {
//          Text(detector.latestResult.debugDescription)
//              .onAppear  { detector.start() }
//              .onDisappear { detector.stop() }
//              .onChange(of: detector.latestResult) { _, result in
//                  if result == .strongValidHook { triggerStrike() }
//              }
//      }
//

import Foundation
import Combine

// MARK: - HookGestureDetector

/// Observable coordinator. Instantiate once per game scene.
@MainActor
final class HookGestureDetector: ObservableObject {

    // MARK: Published

    /// The most recently computed gesture classification.
    @Published private(set) var latestResult: HookGestureResult = .noMotion

    /// Convenience flag for binding to UI state (e.g., disabling the button
    /// while a motion session is not running).
    @Published private(set) var isRunning: Bool = false

    // MARK: Dependencies

//    private let motionManager  = MotionManager()
    let motionManager = MotionManager()
    private let gestureAnalyzer = GestureAnalyzer()

    // MARK: Private

    /// Timer that triggers gesture analysis at a fixed cadence.
    /// We don't need to analyze every single 60 Hz frame — 15 Hz is plenty
    /// to catch a ~1-second gesture event, and it keeps CPU overhead low.
    private var analysisTimer: AnyCancellable?
    private let analysisHz: Double = 15

    // MARK: Public API

    /// Starts motion capture and the periodic analysis loop.
    func start() {
        guard !isRunning else { return }
        motionManager.startUpdates()
        startAnalysisLoop()
        isRunning = true
    }

    /// Stops motion capture, cancels the analysis loop, and resets the result.
    func stop() {
        motionManager.stopUpdates()
        analysisTimer?.cancel()
        analysisTimer = nil
        latestResult = .noMotion
        isRunning = false
    }

    // MARK: - Private

    /// Fires the analyzer on the published `samples` buffer at `analysisHz`.
    private func startAnalysisLoop() {
        analysisTimer = Timer.publish(every: 1.0 / analysisHz, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                let result = self.gestureAnalyzer.analyze(self.motionManager.samples)
                // Only update the published property when the result changes
                // to avoid spurious SwiftUI redraws.
                if result != self.latestResult {
                    self.latestResult = result
                }
            }
    }
}

// MARK: - HookGestureResult conveniences

extension HookGestureResult: Equatable {}

extension HookGestureResult: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .strongValidHook: return "✅ Strong Valid Hook"
        case .weakHook:        return "🟡 Weak Hook"
        case .wrongDirection:  return "❌ Wrong Direction"
        case .noMotion:        return "💤 No Motion"
        }
    }
}
