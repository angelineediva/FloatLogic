//
//  PracticeView.swift
//  FloatLojic
//
//  Created by Angeline on 30/04/26.
//

import SwiftUI

struct PracticeView: View {
    @StateObject private var tutorialVM = TutorialViewModel()
    @StateObject private var practiceVM = PracticeViewModel()
    @State private var practiceLoopTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            animationFrame
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            controlsOverlay

            if let feedbackState = practiceVM.feedbackState {
                Color.black.opacity(0.22)
                    .ignoresSafeArea()

                FeedbackCard(state: feedbackState) {
                    startPracticeSession()
                }
            }
        }
        .navigationBarBackButtonHidden(practiceVM.feedbackState != nil)
        .onDisappear {
            practiceLoopTask?.cancel()
            tutorialVM.stopLoop()
        }
    }

    // Animation frame
    private var animationFrame: some View {
        GeometryReader { geometry in
            let frameWidth = geometry.size.width + 80
            let frameHeight = geometry.size.height

            ZStack {
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameWidth, height: frameHeight)

                Image("Water")
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameWidth, height: frameHeight)

                Image("BobberFull")
                    .resizable()
                    .frame(width: 40, height: 80)
                    .rotationEffect(.degrees(tutorialVM.rotation))
                    .offset(x: tutorialVM.offsetX, y: tutorialVM.offsetY + 70)

                Image("airnew")
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameWidth, height: frameHeight)
                    .offset(x: tutorialVM.offsetX - 10)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .ignoresSafeArea(edges: [.top, .horizontal])
    }

    private var controlsOverlay: some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {
                //BUAT DEBUG. nanti dihapus
                Text(debugMovementLabel)
                    .foregroundStyle(.red)

                Button {
                    if practiceVM.currentDisturbance == nil || !practiceVM.isSessionActive {
                        startPracticeSession()
                    } else {
                        practiceVM.handlePull()
                    }
                } label: {
                    Text(actionButtonTitle)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.label))
                        .foregroundColor(Color(.systemBackground))
                        .cornerRadius(14)
                }
                .disabled(!isActionButtonEnabled)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
    }

    private var actionButtonTitle: String {
        practiceVM.currentDisturbance == nil ? "Start" : "Tarik"
    }

    //BUAT DEBUG. nanti dihapus
    private var debugMovementLabel: String {
        guard let disturbance = practiceVM.currentDisturbance else {
            return practiceVM.isSessionActive ? "DEBUG: Menunggu gerakan berikutnya" : "DEBUG: Belum ada gerakan"
        }

        return "DEBUG: Gerakan \(debugTitle(for: disturbance))"
    }

    private var isActionButtonEnabled: Bool {
        practiceVM.currentDisturbance == nil || practiceVM.isSessionActive
    }

    /// Starts a new continuous practice session and keeps generating
    /// random disturbances until a feedback state is produced.
    private func startPracticeSession() {
        practiceLoopTask?.cancel()
        tutorialVM.stopLoop()
        practiceVM.startSession()

        practiceLoopTask = Task { @MainActor in
            await runPracticeLoop()
        }
    }

    @MainActor
    private func runPracticeLoop() async {
        while !Task.isCancelled,
              practiceVM.isSessionActive,
              practiceVM.feedbackState == nil {
            guard let disturbance = practiceVM.nextDisturbance() else {
                break
            }

            await tutorialVM.playOnce(for: disturbance)

            guard !Task.isCancelled, practiceVM.feedbackState == nil else {
                break
            }

            if disturbance == .strike {
                await practiceVM.waitForStrikeResolution()
            } else {
                await practiceVM.finishNonStrikeCycle()
            }
        }
    }

    // BUAT DEBUG. nanti dihapus
    private func debugTitle(for disturbance: DisturbanceType) -> String {
        switch disturbance {
        case .wind:
            return "Wind"
        case .noBait:
            return "No Bait"
        case .fishNibble:
            return "Fish Nibble"
        case .strike:
            return "Strike"
        }
    }
}

#Preview {
    PracticeView()
}
