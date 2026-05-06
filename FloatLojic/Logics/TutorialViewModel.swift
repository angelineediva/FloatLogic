//
//  TutorialViewModel.swift
//  FloatLojic
//
//  Created by Angeline on 04/05/26.
//

import SwiftUI
import Combine

@MainActor
final class TutorialViewModel: ObservableObject {
    enum BubbleState {
        case none, one, two, three, four
    }
    
    enum BubbleStrikeState {
        case none, one, two, three, four, five
    }
    
    @Published var bubbleState: BubbleState = .none
    @Published var bubbleStrikeState: BubbleStrikeState = .none
    @Published var offsetY: CGFloat = 0
    @Published var offsetX: CGFloat = 0
    @Published var rotation: Double = 0

    private var loopTask: Task<Void, Never>?

    deinit {
        loopTask?.cancel()
    }

    // MARK: - Loop Control : ini nge loop nya di sini
    func startLoop(for type: DisturbanceType) {
        loopTask?.cancel()
        loopTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                do {
                    try await self.playCycle(for: type)
                    try await self.pause(seconds: 2)
                } catch is CancellationError {
                    break
                } catch {
                    break
                }
            }
        }
    }

    // NEW: Fungsi untuk Stops any running animation loop and restores the default bobber state.
    func stopLoop() {
        loopTask?.cancel()
        loopTask = nil
        resetVisualState()
    }

    // NEW: fungsi untuk single disturbance cycle for practice mode without starting a loop.
    func playOnce(for type: DisturbanceType) async {
        loopTask?.cancel()

        //loop untuk strike practice
        do {
            resetVisualState()

            if type == .strike {
                try await animateStrikerPractice()
            } else {
                try await playCycle(for: type)
            }
        } catch is CancellationError {
            return
        } catch {
            return
        }
    }

    private func resetVisualState() {
        offsetX = 0
        offsetY = 0
        rotation = 0
        bubbleState = .none
        bubbleStrikeState = .none
    }

    // MARK: - Animations
    private func playCycle(for type: DisturbanceType) async throws {
        resetVisualState()

        switch type {
        case .wind:
            try await animateWind()
        case .noBait:
            try await animateEmpty()
        case .fishNibble:
            try await animateNibble()
        case .strike:
            try await animateStriker()
        }
    }

    // kena angin
    private func animateWind() async throws {
        withAnimation(.easeInOut(duration: 1)) {
            offsetX = 8
            rotation = 4
        }
        try await pause(seconds: 1)

        withAnimation(.easeInOut(duration: 1)) {
            offsetX = -8
            rotation = -4
        }
        try await pause(seconds: 1)

        withAnimation(.easeInOut(duration: 0.8)) {
            offsetX = 0
            rotation = 0
        }
        try await pause(seconds: 0.8)
    }

    // kena nibble
    private func animateNibble() async throws {

        withAnimation(.easeInOut(duration: 0.2)) {
            offsetY = 50
        }

        bubbleState = .one
        try await pause(seconds: 0.08)

        bubbleState = .two
        try await pause(seconds: 0.08)

        bubbleState = .three
        try await pause(seconds: 0.08)

        bubbleState = .four
        try await pause(seconds: 0.1)

        withAnimation(.easeInOut(duration: 0.2)) {
            offsetY = 0
        }

        try await pause(seconds: 0.2)
        bubbleState = .none
       
    }


    // kena umpan
    private func animateStriker() async throws {
        let initialDipDuration = 0.3
        let deepStrikeDuration = 0.2
        let recoveryDuration = 0.18
        let initialBubbleFrameDuration = initialDipDuration / 3
        let strikeBubbleFrameDuration = deepStrikeDuration / 2

        bubbleStrikeState = .none

        withAnimation(.easeInOut(duration: initialDipDuration)) {
            offsetY = 200
        }
        try await pause(seconds: initialBubbleFrameDuration)
        
        
        bubbleStrikeState = .one
        bubbleStrikeState = .two
        try await pause(seconds: initialBubbleFrameDuration)

        
        bubbleStrikeState = .three
        try await pause(seconds: initialBubbleFrameDuration)


        
        withAnimation(.spring(response: deepStrikeDuration, dampingFraction: 0.4)) {
            offsetY = 200
        }
        bubbleStrikeState = .four
        try await pause(seconds: strikeBubbleFrameDuration)
        
        bubbleStrikeState = .five

        try await pause(seconds: strikeBubbleFrameDuration)

        withAnimation(.easeOut(duration: recoveryDuration)) {
            offsetY = 0
        }
        bubbleStrikeState = .none
        
        
        
    }
    
    // NEW: ANIMATE STRIKE UNTUK PRACTICE
    private func animateStrikerPractice() async throws {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < 5 {
            try await animateStriker()
        }
    }
    

    // umpan kosong
    private func animateEmpty() async throws {
        withAnimation(.easeInOut(duration: 1.2)) {
            offsetX = 3
            offsetY = -2
        }
        try await pause(seconds: 1.2)

        withAnimation(.easeInOut(duration: 1.2)) {
            offsetX = -3
            offsetY = 2
        }
        try await pause(seconds: 1.2)

        withAnimation(.easeInOut(duration: 0.8)) {
            offsetX = 0
            offsetY = 0
        }
        try await pause(seconds: 0.8)
    }

    private func pause(seconds: Double) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        try Task.checkCancellation()
    }
}

#Preview {
    TutorialView()
}
