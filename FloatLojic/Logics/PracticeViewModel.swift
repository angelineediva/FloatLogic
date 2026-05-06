//
//  PracticeViewModel.swift
//  FloatLojic
//
//  Created by Codex on 08/08/25.
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

    deinit {
        strikeTimeoutTask?.cancel()
    }

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
        let nextDisturbance = DisturbanceType.allCases.randomElement() ?? .wind //random di sini
        currentDisturbance = nextDisturbance
        scheduleStrikeTimeoutIfNeeded(for: nextDisturbance)

        return nextDisturbance
    }

    func handlePull() {
        guard isSessionActive, let currentDisturbance else {
            return
        }

        strikeTimeoutTask?.cancel()

        switch currentDisturbance {
        case .strike:
            finishRound(with: .strike)
        case .wind, .noBait, .fishNibble:
            finishRound(with: .failed)
        }
    }

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

        guard isSessionActive, feedbackState == nil else {
            return
        }

        currentDisturbance = nil
    }

    func waitForStrikeResolution() async {
        guard currentDisturbance == .strike else {
            return
        }

        while isSessionActive, feedbackState == nil, currentDisturbance == .strike {
            do {
                try await Task.sleep(nanoseconds: 100_000_000)
            } catch {
                return
            }
        }
    }

    // Starts the "too late" timer only when the random disturbance is a strike.
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

    // Finalizes the round and stores the result for the feedback UI.
    private func finishRound(with feedback: FeedbackCardState) {
        guard isSessionActive else {
            return
        }

        isSessionActive = false
        feedbackState = feedback
    }
    // MARK: - Motion tracking lifecycle
    private var coordinator: MotionGestureCoordinator?

    func startMotionTracking() {
        coordinator = MotionGestureCoordinator(practiceVM: self)
        coordinator?.start()
    }

    func stopMotionTracking() {
        coordinator?.stop()
        coordinator = nil
    }

    // MARK: - Motion event handler (called by MotionGestureCoordinator)
    func handleMotionEvent(_ feedback: FeedbackCardState) {
        guard isSessionActive, feedbackState == nil else { return }
        strikeTimeoutTask?.cancel()
        finishRound(with: feedback)
    }
}


