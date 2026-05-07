//
//  PracticeView.swift
//  FloatLojic
//
//  Created by Angeline on 30/04/26.
//  Updated to start/stop Core Motion tracking via PracticeViewModel.
//

import SwiftUI

struct PracticeView: View {
    
    @State private var guideTask: Task<Void, Never>?
    @State private var guideImageName = "Guide1"
    @State private var showGuideFlow = true
    @State private var countdown: Int? = nil
    @State private var countdownTask: Task<Void, Never>?
    
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var tutorialVM = TutorialViewModel()
    @StateObject private var practiceVM = PracticeViewModel()
    @State private var practiceLoopTask: Task<Void, Never>?

    private var bubbleImageName: String {
        switch tutorialVM.bubbleState {
        case .none: return ""
        case .one: return "bubblestate1"
        case .two: return "bubblestate2"
        case .three: return "bubblestate3"
        case .four: return "bubblestate4"
        }
    }

    private var bubbleStrikeImageName: String {
        switch tutorialVM.bubbleStrikeState {
        case .none: return ""
        case .one: return "Splash1"
        case .two: return "Splash2"
        case .three: return "Splash3"
        case .four: return "Splash4"
        case .five: return "Splash5"
        }
    }

    var body: some View {
        ZStack {
            animationFrame
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if showGuideFlow {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                VStack{
                    Text("How to play")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .scaleEffect(1.2)
                        .transition(.scale)
                    Image(guideImageName)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1)
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                }
            }

            // Countdown overlay
            if let countdown = countdown {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                Text("\(countdown)")
                    .font(.system(size: 90, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .scaleEffect(1.2)
                    .transition(.scale)
            }

            // Feedback overlay
            if let feedbackState = practiceVM.feedbackState {
                Color.black.opacity(0.22)
                    .ignoresSafeArea()
                FeedbackCard(
                    feedback: feedbackState.feedbackInfo,
//                    onHome: handleBackToTutorial,
                    onTryAgain: startPracticeSession
                )
            }
        }
        .navigationBarBackButtonHidden(practiceVM.feedbackState != nil)
        .onAppear {
            practiceVM.startMotionTracking()
            
            if !practiceVM.isSessionActive {
                runGuideFlow()
            }
        }
        .onDisappear {
            guideTask?.cancel()
            practiceLoopTask?.cancel()
            countdownTask?.cancel()
            tutorialVM.stopLoop()
            practiceVM.stopMotionTracking()
        }
    }
    
    private func runGuideFlow() {
        guideTask?.cancel()
        
        guideTask = Task { @MainActor in
            showGuideFlow = true
            guideImageName = "Guide1"
            
            // STEP 1: Guide1
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            guard !Task.isCancelled else { return }
            
            // STEP 2: anim 1-7
            let frames = [
                "Guide1 1",
                "Guide1 2",
                "Guide1 3",
                "Guide1 4",
                "Guide1 5",
                "Guide1 6",
                "Guide1 7"
            ]
            
            for frame in frames {
                guard !Task.isCancelled else { return }
                guideImageName = frame
                try? await Task.sleep(nanoseconds: 400_000_000)
            }
            
            // STEP 3: Guide1 8 loop 3x
            for _ in 0..<3 {
                for _ in 0..<1 {
                    guard !Task.isCancelled else { return }
                    guideImageName = "Guide1 8"
                    try? await Task.sleep(nanoseconds: 600_000_000)
                }
                
                // STEP 4: Guide1 9 loop 3x
                for _ in 0..<1 {
                    guard !Task.isCancelled else { return }
                    guideImageName = "Guide1 9"
                    try? await Task.sleep(nanoseconds: 600_000_000)
                }
            }
            
            
            guard !Task.isCancelled else { return }
            
            showGuideFlow = false
            
            // lanjut ke countdown EXISTING kamu
            startCountdown()
        }
    }

    // MARK: - Animation Frame (mirror TutorialView)
    private var animationFrame: some View {
        GeometryReader { geometry in
            let frameWidth = geometry.size.width + 80
            let frameHeight = geometry.size.height
            let scale: CGFloat = 2
            let overlayScale: CGFloat = 1.45

            ZStack {
                // Background & Water — normal scale
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameWidth, height: frameHeight)

                Image("Water")
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameWidth, height: frameHeight)
            

                // Bobber — scale up
                Image("BobberFull")
                    .resizable()
                    .frame(width: 40 * scale, height: 80 * scale)
                    .rotationEffect(.degrees(tutorialVM.rotation))
                    .offset(x: tutorialVM.offsetX, y: tutorialVM.offsetY + 70)

                // Air — scale up
                Image("airnew")
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameWidth * scale, height: frameHeight * scale)
                    .offset(x: -25, y: -130)

                // Bubble states — scale up
                if tutorialVM.bubbleState != .none {
                    Image(bubbleImageName)
                        .resizable()
                        .frame(width: frameWidth * overlayScale, height: frameHeight * overlayScale)
                        .offset(x: -5, y: 40)
                }

                if tutorialVM.bubbleStrikeState != .none {
                    Image(bubbleStrikeImageName)
                        .resizable()
                        .frame(width: frameWidth * overlayScale, height: frameHeight * overlayScale)
                        .offset(x: -5, y: 40)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .ignoresSafeArea(edges: [.top, .horizontal])
    }

    // MARK: - Countdown
    private func startCountdown() {
        countdownTask?.cancel()
        countdown = 3

        countdownTask = Task { @MainActor in
            var value = 3
            while value > 0 && !Task.isCancelled {
                countdown = value
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                value -= 1
            }
            guard !Task.isCancelled else { return }
            countdown = nil
            startPracticeSession()
        }
    }

    // MARK: - Session control
    private func startPracticeSession() {
        countdownTask?.cancel()
        countdown = nil
        practiceLoopTask?.cancel()
        tutorialVM.stopLoop()
        practiceVM.startSession()

        practiceLoopTask = Task { @MainActor in
            await runPracticeLoop()
        }
    }
//
//    private func handleBackToTutorial() {
//        practiceLoopTask?.cancel()
//        countdownTask?.cancel()
//        tutorialVM.stopLoop()
//        dismiss()
//    }

    @MainActor
    private func runPracticeLoop() async {
        while !Task.isCancelled,
              practiceVM.isSessionActive,
              practiceVM.feedbackState == nil {

            guard let disturbance = practiceVM.nextDisturbance() else { break }
            await tutorialVM.playOnce(for: disturbance)

            guard !Task.isCancelled, practiceVM.feedbackState == nil else { break }

            if disturbance == .strike {
                await practiceVM.waitForStrikeResolution()
            } else {
                await practiceVM.finishNonStrikeCycle()
            }
        }
    }
}

#Preview {
    PracticeView()
}
