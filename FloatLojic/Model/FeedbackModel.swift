////
////  FeedbackModel.swift
////  FloatLojic
////
////  Created by Stephanie Vania Suwardi Data on 03/05/26.
////
//
//import Foundation
//import SwiftUI
//
////snake_case  feedback_Card_State
////camelcase     -> feedbackCardState -> non object -> var, func
////non camelcase -> FeedbackCardState -> object -> class/struct/enum/protocol
//
//enum FeedbackType: CaseIterable {
//    case strike
//    case fail
//    case toolate
//}
//
//enum FeedbackCardState {
//    case strike
//    case failed
//    case tooLate
//}
//
//struct FeedbackInfo {
//    let type: FeedbackType
//    let title: String
//    let image: String
//    let message: String
//    let body: String
//}
//
//extension FeedbackCardState {
//    var feedbackInfo: FeedbackInfo {
//        switch self {
//        case .strike:
//            return .all[0]
//        case .failed:
//            return .all[1]
//        case .tooLate:
//            return .all[2]
//        }
//    }
//}
//
//extension FeedbackInfo {
//    static let all: [FeedbackInfo] = [
//        FeedbackInfo(
//            type: .strike,
//            title: "STRIKE!",
//            image: "ikanaw",
//            message: "You’ve got the fish!",
//            body: "The wind creates a horizontal drag on the bobber, causing it to shift slowly in one direction. The line tilts and the float leans this isn't a fish bite."
//        ),
//        FeedbackInfo(
//            type: .fail,
//            title: "You Lose",
//            image: "ikanbye",
//            message: "You’re too early!",
//            body: "The bobber drifted slowly due to the wind. A real bite is quick and sudden! this wasn’t a fish yet."
//        ),
//        FeedbackInfo(
//            type: .toolate,
//            title: "Too Late",
//            image: "kail",
//            message: "You’re too late!",
//            body: "That sudden dip was a real bite, but you reacted too late. When a fish strikes, the bobber moves fast, timing is everything."
//        )
//    ]
//}

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
    let bodies: [String]

    // ambil random message
    var randomBody: String {
        bodies.randomElement() ?? ""
    }
}

extension FeedbackCardState {
    var feedbackInfo: FeedbackInfo {
        switch self {
        case .strike:
            return .strikeData
        case .failed:
            return .failData
        case .tooLate:
            return .tooLateData
        }
    }
}

extension FeedbackInfo {
    static let strikeData = FeedbackInfo(
        type: .strike,
        title: "STRIKE!",
        image: "ikanaw",
        message: "You’ve got the fish!",
        bodies: [
            "Boom! Perfect timing. Fish secured.",
            "HOOKED! That fish had zero chance.",
            "That fish really said 'EEAAATTT MEEE'",
            "Lunch just volunteered itself!"
        ]
    )

    static let failData = FeedbackInfo(
        type: .fail,
        title: "You Lose",
        image: "ikanbye",
        message: "You’re too early!",
        bodies: [
            "Relax… that was just the wind.. r u hungry yet?",
            "LOL what are you doing?",
            "Wind: 1, You: 0.",
            "Too early! The fish is still thinking about it."
        ]
    )

    static let tooLateData = FeedbackInfo(
        type: .toolate,
        title: "Too Late",
        image: "kail",
        message: "You’re too late!",
        bodies: [
            "That WAS a fish… you missed it??",
            "Too slow! The fish already left.",
            "Fish: 'bye!'",
            "You blinked. It’s gone."
        ]
    )
}
