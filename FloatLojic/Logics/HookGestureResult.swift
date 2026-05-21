//
//  HookGestureResult.swift
//  FloatLojic
//
//  Created by Graceila Natasya on 06/05/26.
//


//
//  GestureAnalyzer.swift
//  FloatLojic
//
//  Stateless rule-based analyzer that inspects a window of MotionSamples
//  and classifies a "fishing hook" gesture.
//
//  ── Gesture mental model ──────────────────────────────────────────────
//
//  The player holds the phone like a fishing rod handle (portrait or slight
//  landscape tilt). A hook gesture looks like:
//
//    1. (Optional) A small downward dip or neutral stillness → preparation.
//    2. A fast upward AND slightly backward snap of the wrist → the strike.
//
//  In device coordinates (portrait, screen facing the player):
//    +Y  = toward the top of the phone (upward)
//    -Z  = away from the player (backward / forward-cast direction)
//
//  So the dominant strike vector should have:
//    userAcceleration.y  > 0  (upward)
//    userAcceleration.z  < 0  (slightly away from body, like flicking a rod)
//
//  To detect the *curve* (not just a straight jab), we look for a
//  direction change over the analysis window:
//    • Early phase: acceleration can be neutral or slightly downward.
//    • Peak phase:  acceleration swings strongly upward (+Y dominant).
//  This early→peak angle shift approximates a parabolic arc.
//
//  ── Threshold rationale ───────────────────────────────────────────────
//
//  Tested on iPhone 14 held comfortably in one hand:
//    • Idle / walking noise:    magnitude ≈ 0.05–0.15 g
//    • Casual upward flick:     peak ≈ 0.8–1.5 g
//    • Deliberate hook motion:  peak ≈ 1.8–4.0 g
//
//  We set the "strong" threshold at 1.8 g and "weak" at 0.9 g.
//  Adjust these constants in `Thresholds` to tune sensitivity per device.
//

import Foundation
import simd

// MARK: - HookGestureResult

/// Classification returned by GestureAnalyzer for a given sample window.
enum HookGestureResult {
    /// Clear, well-formed hook gesture: strong upward+backward arc.
    case strongValidHook

    /// Hook-like motion detected but below the strong threshold.
    /// May be a hesitant cast or device held at an unusual angle.
    case weakHook

    /// Sufficient acceleration detected but in the wrong direction
    /// (e.g., a downward slam or a sideways swipe).
    case wrongDirection

    /// No significant motion detected; device is still or only drifting.
    case noMotion
}

// MARK: - GestureAnalyzer

/// Stateless service. Call `analyze(_:)` with any slice of MotionSamples.
/// Suitable for dependency injection and unit testing without hardware.
struct GestureAnalyzer {

    // MARK: Tunable thresholds

    private enum Thresholds {
        /// Minimum peak acceleration magnitude (g) to qualify as *any* gesture.
        /// Below this the motion is considered noise or idle drift.
        static let noiseFloor: Double = 0.4

        /// Peak magnitude (g) required for a `weakHook` classification.
        static let weakHookMagnitude: Double = 0.9

        /// Peak magnitude (g) required for a `strongValidHook` classification.
        static let strongHookMagnitude: Double = 1.8

        /// The Y component (upward) of the dominant acceleration vector must
        /// exceed this fraction of the total magnitude to be "upward".
        /// 0.45 means "at least 45% of the force goes upward" — allows ~65° tilt.
        static let upwardFraction: Double = 0.45

        /// The Z component (backward from screen) contribution that qualifies
        /// the motion as having a backward component.
        /// Negative Z = away from the player (forward-cast arc).
        /// We use a relaxed threshold (−0.15) so angled casts still qualify.
        static let backwardZThreshold: Double = -0.15

        /// Maximum analysis window duration in seconds.
        /// We focus on the most recent second, which is tight enough to reject
        /// slow incidental phone movements but generous enough for a deliberate cast.
        static let analysisWindow: TimeInterval = 1.0

        /// Minimum Y-axis angle change (degrees) between the early phase and
        /// the peak sample to satisfy the "curved / arc" criterion.
        /// 30° means the wrist must have visibly changed direction — it's not
        /// just a single straight impulse.
        static let minCurveAngleDeg: Double = 30.0
    }

    // MARK: - Public API

    /// Analyze the provided motion buffer and return a gesture classification.
    ///
    /// - Parameter samples: The rolling buffer from `MotionManager`. May be
    ///   any length; the analyzer trims to the last `Thresholds.analysisWindow`
    ///   seconds internally.
    /// - Returns: A `HookGestureResult` enum case.
    func analyze(_ samples: [MotionSample]) -> HookGestureResult {
        // ── 1. Trim to analysis window ────────────────────────────────
        let window = trimToWindow(samples)
        guard window.count >= 5 else {
            debugLog("Too few samples in window (\(window.count)). Skipping.")
            return .noMotion
        }

        // ── 2. Find peak acceleration in window ───────────────────────
        let peakSample = window.max(by: { $0.accelerationMagnitude < $1.accelerationMagnitude })!
        let peakMag = peakSample.accelerationMagnitude

        debugLog("Peak magnitude: \(String(format: "%.3f", peakMag)) g")

        guard peakMag >= Thresholds.noiseFloor else {
            debugLog("Below noise floor. → noMotion")
            return .noMotion
        }

        // ── 3. Direction check ────────────────────────────────────────
        // Decompose peak acceleration into its axis fractions.
        let acc = peakSample.userAcceleration
        let upwardFraction = acc.y / peakMag      // positive = upward
        let backwardContrib = acc.z               // negative = away from screen

        debugLog("""
            Direction: Y-fraction=\(String(format: "%.2f", upwardFraction)), \
            Z=\(String(format: "%.3f", backwardContrib))
            """)

        let isUpward   = upwardFraction  >= Thresholds.upwardFraction
        let isBackward = backwardContrib <= Thresholds.backwardZThreshold

        guard isUpward else {
            debugLog("Not predominantly upward. → wrongDirection")
            return .wrongDirection
        }

        // ── 4. Curved-arc check ───────────────────────────────────────
        // Split the window into an "early" phase (first 40%) and a
        // "late / peak" phase (last 40%), then compute the angle between
        // their average acceleration vectors.
        //
        // A genuine arc gesture swings from a neutral or downward prep
        // into a sharp upward finish, so the angle between early and
        // peak vectors should be at least `minCurveAngleDeg` degrees.
        let hasCurve = detectCurve(in: window)
        debugLog("Curve detected: \(hasCurve)")

        // ── 5. Classify ───────────────────────────────────────────────
        switch peakMag {
        case Thresholds.strongHookMagnitude...:
            if hasCurve && isBackward {
                debugLog("→ strongValidHook ✓")
                return .strongValidHook
            } else if hasCurve || isBackward {
                // Strong force + upward + partial arc → still a strong hook
                debugLog("→ strongValidHook (partial arc) ✓")
                return .strongValidHook
            } else {
                // Strong straight jab upward — not quite a hook arc
                debugLog("→ weakHook (strong but no arc/backward)")
                return .weakHook
            }

        case Thresholds.weakHookMagnitude...:
            debugLog("→ weakHook")
            return .weakHook

        default:
            debugLog("→ wrongDirection (sufficient direction but low force)")
            return .wrongDirection
        }
    }

    // MARK: - Private helpers

    /// Slices the sample array to the most recent `Thresholds.analysisWindow` seconds.
    private func trimToWindow(_ samples: [MotionSample]) -> [MotionSample] {
        guard let newest = samples.last else { return [] }
        let cutoff = newest.timestamp - Thresholds.analysisWindow
        return samples.filter { $0.timestamp >= cutoff }
    }

    /// Returns `true` if the acceleration vector rotates by at least
    /// `minCurveAngleDeg` degrees between the early and late phase of the window.
    ///
    /// How the curve approximation works:
    ///   • Split the window into equal thirds; use the first third as "early"
    ///     and the last third as "late".
    ///   • Average the acceleration vectors in each phase to reduce per-frame noise.
    ///   • Compute the angle between those two average vectors using the dot-product
    ///     formula:  θ = acos( a⃗·b⃗ / (|a⃗||b⃗|) )
    ///   • A large angle = the wrist changed direction = curved arc ✓
    private func detectCurve(in window: [MotionSample]) -> Bool {
        let count = window.count
        guard count >= 9 else { return false }   // need at least 3 samples per phase

        let thirdLen = count / 3
        let earlySlice = Array(window.prefix(thirdLen))
        let lateSlice  = Array(window.suffix(thirdLen))

        let earlyAvg = averageAcceleration(earlySlice)
        let lateAvg  = averageAcceleration(lateSlice)

        let earlyLen = simd_length(earlyAvg)
        let lateLen  = simd_length(lateAvg)

        // If either phase is essentially motionless, we can't measure an angle.
        guard earlyLen > 0.05, lateLen > 0.05 else { return false }

        // Cosine similarity → angle
        let cosTheta = simd_dot(earlyAvg, lateAvg) / (earlyLen * lateLen)
        // clamp to [-1, 1] to guard against floating-point rounding
        let clamped  = max(-1.0, min(1.0, cosTheta))
        let angleDeg = acos(clamped) * (180.0 / .pi)

        debugLog("Arc angle between early↔late phases: \(String(format: "%.1f", angleDeg))°")
        return angleDeg >= Thresholds.minCurveAngleDeg
    }

    /// Computes the element-wise average of `userAcceleration` across an array
    /// of samples.
    private func averageAcceleration(_ samples: [MotionSample]) -> SIMD3<Double> {
        guard !samples.isEmpty else { return .zero }
        let sum = samples.reduce(SIMD3<Double>.zero) { $0 + $1.userAcceleration }
        return sum / Double(samples.count)
    }

    // MARK: - Debug logging

    /// Logs to the console only in DEBUG builds to avoid shipping noise.
    private func debugLog(_ message: String) {
        #if DEBUG
        print("[GestureAnalyzer] \(message)")
        #endif
    }
}
