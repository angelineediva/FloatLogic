//
//  FeedbackModel.swift
//  FloatLojic
//
//  Created by Stephanie Vania Suwardi Data on 03/05/26.
//

import Foundation
import SwiftUI

enum FeedbackType: CaseIterable {
    case strike
    case fail
    case toolate
}

enum FeedbackCardState {
    case strike
    case failed
    case tooLate
}

struct FeedbackInfo {
    let type: FeedbackType
    let title: String
    let image: String
    let message: String
    let body: String
}

extension FeedbackCardState {
    var feedbackInfo: FeedbackInfo {
        switch self {
        case .strike:
            return .all[0]
        case .failed:
            return .all[1]
        case .tooLate:
            return .all[2]
        }
    }
}

extension FeedbackInfo {
    static let all: [FeedbackInfo] = [
        FeedbackInfo(
            type: .strike,
            title: "STRIKE!",
            image: "ikanaw",
            message: "You’ve got the fish!",
            body: "The wind creates a horizontal drag on the bobber, causing it to shift slowly in one direction. The line tilts and the float leans—this isn't a fish bite."
        ),
        FeedbackInfo(
            type: .fail,
            title: "You Lose",
            image: "ikanbye",
            message: "You’re too early!",
            body: "The wind creates a horizontal drag on the bobber, causing it to shift slowly in one direction. The line tilts and the float leans this isn't a fish bite."
        ),
        FeedbackInfo(
            type: .toolate,
            title: "To Late",
            image: "kail",
            message: "You’re too late!",
            body: "The wind creates a horizontal drag on the bobber, causing it to shift slowly in one direction. The line tilts and the float leans—this isn't a fish bite."
        )
    ]
}
