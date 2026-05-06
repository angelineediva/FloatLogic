//
//  PracticeView.swift
//  FloatLojic
//
//  Created by Angeline on 30/04/26.
//  Updated to start/stop Core Motion tracking via PracticeViewModel.
//

import SwiftUI

struct PracticeView: View {
    
    @State var countdown: Int? = nil
    @State var countdownTask: Task<Void, Never>?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var tutorialVM = TutorialViewModel()
    @StateObject private var practiceVM = PracticeViewModel()
    @State private var practiceLoopTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            animationFrame
                .frame(maxWidth: .infinity, maxHeight: .infinity)

//            controlsOverlay
            if let countdown = countdown {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()

                Text("\(countdown)")
                    .font(.system(size: 90, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .scaleEffect(1.2)
                    .transition(.scale)
            }
            
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
        // ── Core Motion lifecycle ──────────────────────────────────────
        // Motion starts as soon as the view appears and keeps running
        // continuously until the view disappears, regardless of session state.
        .onAppear {
            practiceVM.startMotionTracking()

            // pastikan hanya jalan sekali
            if practiceVM.isSessionActive == false {
                startCountdown()
            }
        }
        .onDisappear {
            practiceLoopTask?.cancel()
            tutorialVM.stopLoop()
            practiceVM.stopMotionTracking()   // stops Core Motion
        }
    }
    
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
    
    // MARK: - Animation frame

    private var animationFrame: some View {
        GeometryReader { geometry in
            let frameWidth = geometry.size.width + 300
            let frameHeight = geometry.size.height + 200

            ZStack {
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameWidth, height: frameHeight)

                Image("Water")
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameWidth , height: frameHeight)

                Image("BobberFull")
                    .resizable()
                    .frame(width: 120, height: 240)
                    .rotationEffect(.degrees(tutorialVM.rotation))
                    .offset(x: tutorialVM.offsetX, y: tutorialVM.offsetY + 70)

                Image("airnew")
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameWidth, height: frameHeight)
                    .offset(x: tutorialVM.offsetX - 10)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
//            .clipped()
        }
        .ignoresSafeArea(edges: [.top, .horizontal])
    }

    // MARK: - Controls overlay
//
//    private var controlsOverlay: some View {
//        VStack {
//            Spacer()
//
//            VStack(spacing: 16) {
//                // DEBUG label — remove before release
////                Text(debugMovementLabel)
////                    .foregroundStyle(.red)
//
//                Button {
//                    if practiceVM.currentDisturbance == nil || !practiceVM.isSessionActive {
//                        startPracticeSession()
//                    } else {
//                        practiceVM.handlePull()
//                    }
//                } label: {
//                    Text(actionButtonTitle)
//                        .font(.system(size: 18, weight: .bold, design: .rounded))
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 16)
//                        .background(Color(.label))
//                        .foregroundColor(Color(.systemBackground))
//                        .cornerRadius(14)
//                }
//                .disabled(!isActionButtonEnabled)
//            }
//            .padding(.horizontal, 20)
//            .padding(.bottom, 36)
//        }
//    }

//    // MARK: - Helpers
//
//    private var actionButtonTitle: String {
//        practiceVM.currentDisturbance == nil ? "Start" : "Tarik"
//    }
//
//    // DEBUG — remove before release
//    private var debugMovementLabel: String {
//        guard let disturbance = practiceVM.currentDisturbance else {
//            return practiceVM.isSessionActive
//                ? "DEBUG: Menunggu gerakan berikutnya"
//                : "DEBUG: Belum ada gerakan"
//        }
//        return "DEBUG: Gerakan \(debugTitle(for: disturbance))"
//    }
//
//    private var isActionButtonEnabled: Bool {
//        practiceVM.currentDisturbance == nil || practiceVM.isSessionActive
//    }

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

    // DEBUG — remove before release
    private func debugTitle(for disturbance: DisturbanceType) -> String {
        switch disturbance {
        case .wind:       return "Wind"
        case .noBait:     return "No Bait"
        case .fishNibble: return "Fish Nibble"
        case .strike:     return "Strike"
        }
    }
}

#Preview {
    PracticeView()
}
