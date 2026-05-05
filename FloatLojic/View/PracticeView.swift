import SwiftUI
import simd

struct PracticeView: View {
    
    var onExit: (() -> Void)?

    // MARK: - Gesture System
    @StateObject private var detector = HookGestureDetector()

    // MARK: - Debug State
    @State private var latestAcc = SIMD3<Double>(0,0,0)
    @State private var latestMag: Double = 0
    @State private var upwardFraction: Double = 0

    // MARK: - Animation State
    @State private var playHookAnimation = false
    @State private var isOnCooldown = false
    @State private var lastResult: HookGestureResult = .noMotion

    var body: some View {
        ZStack {

            // 🎣 Main Game Area
            VStack {
                Spacer()

                Image(systemName: "figure.fishing")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(playHookAnimation ? -60 : 0))
                    .animation(.easeOut(duration: 0.25), value: playHookAnimation)

                Spacer()
            }

            // 🧪 Debug Panel
            VStack(alignment: .leading, spacing: 6) {
                Text("📊 Motion Debug")
                    .font(.headline)

                Text("x: \(latestAcc.x, specifier: "%.2f")")
                Text("y: \(latestAcc.y, specifier: "%.2f")")
                Text("z: \(latestAcc.z, specifier: "%.2f")")

                Divider()

                Text("Magnitude: \(latestMag, specifier: "%.2f")")
                Text("Upward: \(upwardFraction, specifier: "%.2f")")

                Divider()

                Text("Result:")
                Text(detector.latestResult.debugDescription)
                    .bold()
            }
            .font(.system(.caption, design: .monospaced))
            .padding(12)
            .background(.black.opacity(0.75))
            .foregroundColor(.green)
            .cornerRadius(12)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            // 🎯 Simple vector visualizer
            Circle()
                .fill(Color.red)
                .frame(width: 12, height: 12)
                .offset(
                    x: latestAcc.x * 80,
                    y: -latestAcc.y * 80
                )
        }
        .onAppear {
            detector.start()
        }
        .onDisappear {
            detector.stop()
        }
        .onReceive(detector.$latestResult) { newResult in
            updateDebugValues()
            handleGesture(newResult)
        }
    }
}

// MARK: - Logic
extension PracticeView {

    private func updateDebugValues() {
        guard let last = detector.motionManager.samples.last else { return }

        latestAcc = last.userAcceleration
        latestMag = last.accelerationMagnitude
        upwardFraction = last.userAcceleration.y / max(latestMag, 0.001)
    }

    private func handleGesture(_ result: HookGestureResult) {
        // prevent spam trigger
        if result == .strongValidHook && lastResult != .strongValidHook {
            triggerHook()
        }
        lastResult = result
    }

    private func triggerHook() {
        guard !isOnCooldown else { return }

        isOnCooldown = true
        playHookAnimation = true

        // 🔥 haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // reset animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            playHookAnimation = false
        }

        // cooldown reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isOnCooldown = false
        }
    }
}

#Preview {
    PracticeView()
}
