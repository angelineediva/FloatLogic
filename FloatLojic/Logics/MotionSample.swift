//
//  MotionSample.swift
//  FloatLojic
//
//  Created by Graceila Natasya on 06/05/26.
//


//
//  MotionSample.swift
//  FloatLojic
//
//  A lightweight value type representing a single frame of IMU data.
//  Both acceleration and rotation are stored as SIMD3<Double> so we can
//  use built-in vector arithmetic (dot product, length, etc.) later in
//  GestureAnalyzer without rolling our own math helpers.
//

import Foundation
import simd

// MARK: - MotionSample

/// One snapshot of device motion captured at a specific point in time.
/// `userAcceleration` is gravity-free (Core Motion already subtracts gravity).
/// `rotationRate` is in rad/s around the device's x, y, z axes.
struct MotionSample {

    /// Monotonic timestamp sourced from `CMDeviceMotion.timestamp`
    /// (seconds since last boot, not wall-clock time).
    let timestamp: TimeInterval

    /// Gravity-subtracted linear acceleration in g-force units (device frame).
    /// +Y  = toward the top of the device (upward when held in portrait)
    /// +X  = toward the right side
    /// +Z  = toward the screen face
    let userAcceleration: SIMD3<Double>

    /// Angular velocity in radians per second (device frame).
    let rotationRate: SIMD3<Double>

    // MARK: Computed helpers

    /// Euclidean magnitude of linear acceleration (scalar g-force).
    var accelerationMagnitude: Double {
        simd_length(userAcceleration)
    }

    /// Euclidean magnitude of rotation rate (total angular speed in rad/s).
    var rotationMagnitude: Double {
        simd_length(rotationRate)
    }
}
