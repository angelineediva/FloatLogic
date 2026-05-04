//
//  LoopVidCard.swift
//  FloatLojic
//
//  Created by Feivel Qutby on 04/05/26.
//

import AVFoundation
import SwiftUI
import UIKit

struct LoopVidCard: View {
    let name: String
    let fileExtension: String

    var body: some View {
        LoopingVideoBackground(name: name, fileExtension: fileExtension)
    }
}

struct LoopingVideoBackground: UIViewRepresentable {
    let name: String
    let fileExtension: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.playerLayer.videoGravity = .resizeAspectFill
        context.coordinator.configurePlayer(for: view.playerLayer, name: name, fileExtension: fileExtension)
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
    }

    final class Coordinator {
        private var player: AVQueuePlayer?
        private var looper: AVPlayerLooper?

        func configurePlayer(for layer: AVPlayerLayer, name: String, fileExtension: String) {
            guard let url = videoURL(name: name, fileExtension: fileExtension) else {
                return
            }

            let item = AVPlayerItem(url: url)
            let player = AVQueuePlayer()
            player.isMuted = true
            player.actionAtItemEnd = .none

            looper = AVPlayerLooper(player: player, templateItem: item)
            self.player = player
            layer.player = player
            player.play()
        }

        private func videoURL(name: String, fileExtension: String) -> URL? {
            if let bundledURL = Bundle.main.url(forResource: name, withExtension: fileExtension) {
                return bundledURL
            }

            guard let dataAsset = NSDataAsset(name: name) else {
                return nil
            }

            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(name).\(fileExtension)")

            if !FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try dataAsset.data.write(to: fileURL, options: .atomic)
                } catch {
                    return nil
                }
            }

            return fileURL
        }
    }
}

final class PlayerView: UIView {
    override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        guard let layer = layer as? AVPlayerLayer else {
            fatalError("Expected AVPlayerLayer backing layer")
        }
        return layer
    }
}

#Preview {
    LoopVidCard(name: "HomepageAsset", fileExtension: "mov")
}
