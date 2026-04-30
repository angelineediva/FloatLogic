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
            body: "The wind creates a horizontal drag on the bobber, causing it to shift slowly in one direction. The line tilts and the float leans—this isn't a fish bite.",
            iconName: "wind"
        ),
        DisturbanceInfo(
            type: .wave,
            title: "Wave",
            body: "The waves create a rhythmic and consistent up-and-down motion. The bobber moves periodically following the wave pattern.",
            iconName: "water.waves"
        ),
        DisturbanceInfo(
            type: .fishNibble,
            title: "Fish Nibble",
            body: "The fish touches the bait from below, causing the bobber to drop suddenly and then pause. Wait for that pause before pulling.",
            iconName: "fish"
        ),
        DisturbanceInfo(
            type: .strike,
            title: "Strike",
            body: "Underwater currents push the bobber slowly and consistently. Unlike wind, their movement is smoother and originates from beneath the surface.",
            iconName: "checkmark"
        )
    ]
}
