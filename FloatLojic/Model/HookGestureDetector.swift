
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

@MainActor
final class HookGestureDetector: ObservableObject { //final class agar fungsi ini tidak bisa diubah lewat inherit (kalau mau class biasa aja jg bs)

//  knp pake private(set) ini buat anndain aja kalau avriable ini gabisa diubah di class lain
    
    @Published private(set) var latestResult: HookGestureResult = .noMotion
    @Published private(set) var isRunning: Bool = false

//    private let motionManager  = MotionManager()
    let motionManager = MotionManager()
    let gestureAnalyzer = GestureAnalyzer()

    var analysisTimer: AnyCancellable?
    let analysisHz: Double = 15 //analisis per 15hz/0.66 detik

//    start stop fucntion
    func start() {
        guard !isRunning else { return }
        motionManager.startUpdates()
        startAnalysisLoop()
        isRunning = true
    }

    func stop() {
        motionManager.stopUpdates()
        analysisTimer?.cancel()
        analysisTimer = nil
        latestResult = .noMotion
        isRunning = false
    }

    // MARK: - Private

    private func startAnalysisLoop() {
        analysisTimer = Timer.publish(every: 1.0 / analysisHz, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in //weak self agar tidakn terjadi memory leak
                guard let self else { return }
                let result = self.gestureAnalyzer.analyze(self.motionManager.samples)
                if result != self.latestResult {
                    self.latestResult = result
                }
            }
    }
}

// MARK: - HookGestureResult conveniences

//extension HookGestureResult: Equatable {}

extension HookGestureResult: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .strongValidHook: return "strike"
        case .weakHook:        return "u r too weaak!!"
        case .wrongDirection:  return "Wrong Direction"
        case .noMotion:        return "To loose"
        }
    }
}
