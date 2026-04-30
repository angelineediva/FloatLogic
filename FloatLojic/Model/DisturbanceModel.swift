//
//  DisturbanceModel.swift
//  FloatLojic
//
//  Created by Feivel Qutby on 30/04/26.
//

import Foundation

enum DisturbanceType: CaseIterable {
    case wind
    case wave
    case fishNibble
    case strike
}

struct DisturbanceInfo {
    let type: DisturbanceType
    let title: String
    let body: String
    let iconName: String
}

extension DisturbanceInfo {
    static let all: [DisturbanceInfo] = [
        DisturbanceInfo(
            type: .wind,
            title: "Wind",
            body: "Angin menciptakan tarikan horizontal pada pelampung, menyebabkannya bergeser perlahan ke satu arah. Tali pancing miring dan pelampung condong — ini bukan gigitan ikan.",
            iconName: "wind"
        ),
        DisturbanceInfo(
            type: .wave,
            title: "Wave",
            body: "Ombak menciptakan gerakan naik-turun yang berirama dan konsisten. Pelampung bergerak secara periodik mengikuti pola gelombang air.",
            iconName: "water.waves"
        ),
        DisturbanceInfo(
            type: .fishNibble,
            title: "Fish Nibble",
            body: "Ikan menyentuh umpan dari bawah, menyebabkan pelampung turun tiba-tiba lalu berhenti sejenak. Tunggu jeda itu sebelum menarik — itulah momen yang tepat.",
            iconName: "fish"
        ),
        DisturbanceInfo(
            type: .strike,
            title: "Strike",
            body: "Arus bawah air mendorong pelampung secara perlahan dan konsisten. Berbeda dengan angin, pergerakannya lebih halus dan berasal dari bawah permukaan.",
            iconName: "arrow.left.and.right.wave"
        )
    ]
}
