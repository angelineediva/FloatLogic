//
//  DisturbanceModel.swift
//  FloatLojic
//
//  Created by Feivel Qutby on 30/04/26.
//

import Foundation

enum DisturbanceType: CaseIterable {
    case wind
    case noBait
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
            type: .noBait,
            title: "No Bait",
            body: "When the bait is gone, the float feels lighter and moves unnaturally either too stable or too buoyant. It's time to lift it and add a new bait.",
            iconName: "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90"
        ),
        DisturbanceInfo(
            type: .wind,
            title: "Wind",
            body: "The wind creates a horizontal drag on the bobber, causing it to shift slowly in one direction. The line tilts and the float leans this isn't a fish bite.",
            iconName: "wind"
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
            body: "When the bobber dips sharply and pauses the fish has taken the bait. Pull now with a firm snap of the wrist.",
            iconName: "checkmark"
        )
    ]
}
