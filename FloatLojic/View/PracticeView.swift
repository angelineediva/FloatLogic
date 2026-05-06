//
//  PracticeView.swift
//  FloatLojic
//
//  Created by Angeline on 30/04/26.
//  Updated to start/stop Core Motion tracking via PracticeViewModel.
//

import SwiftUI

struct PracticeView: View {
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

            // Countdown overlay
            if let countdown = countdown {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                Text("\(countdown)")
                    .font(.system(size: 90, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .scaleEffect(1.2)
                    .transition(.scale)
            }

            // Pull button — muncul saat session aktif & ga ada countdown
            if countdown == nil && practiceVM.isSessionActive {
                VStack {
                    Spacer()
                    Button {
                        practiceVM.handlePull()
                    } label: {
                        Text("Tarik!")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(.black.opacity(0.8))
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                    }
                    .glassEffect(.regular.tint(Color.white.opacity(0.25)), in: Capsule())
                    .buttonStyle(.plain)
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    .padding(.bottom, 40)
                }
            }

            // Feedback overlay
            if let feedbackState = practiceVM.feedbackState {
                Color.black.opacity(0.22)
                    .ignoresSafeArea()
                FeedbackCard(
                    feedback: [feedbackState.feedbackInfo],
                    onHome: handleBackToTutorial,
                    onTryAgain: startPracticeSession
                )
            }
        }
        .navigationBarBackButtonHidden(practiceVM.feedbackState != nil)
        .onAppear {
            practiceVM.startMotionTracking()
            if !practiceVM.isSessionActive {
                startCountdown()
            }
        }
        .onDisappear {
            practiceLoopTask?.cancel()
            countdownTask?.cancel()
            tutorialVM.stopLoop()
            practiceVM.stopMotionTracking()
        }
    }

    // MARK: - Animation Frame (mirror TutorialView)
    private var animationFrame: some View {
        GeometryReader { geometry in
            let frameWidth = geometry.size.width + 80
            let frameHeight = geometry.size.height
            let scale: CGFloat = 2

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
                        .frame(width: frameWidth * scale, height: frameHeight * scale)
                        .offset(x: -5, y: -5)
                }

                if tutorialVM.bubbleStrikeState != .none {
                    Image(bubbleStrikeImageName)
                        .resizable()
                        .frame(width: frameWidth * scale, height: frameHeight * scale)
                        .offset(x: -5, y: -5)
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

    private func handleBackToTutorial() {
        practiceLoopTask?.cancel()
        countdownTask?.cancel()
        tutorialVM.stopLoop()
        dismiss()
    }

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
