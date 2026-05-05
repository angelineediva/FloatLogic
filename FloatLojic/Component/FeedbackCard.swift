//
//  FeedbackCard.swift
//  FloatLojic
//
//  Created by Angeline on 30/04/26.
//

// ini di bawah hanya sementara buat logic nya aja
import SwiftUI

enum FeedbackCardState: CaseIterable {
    case failed
    case strike
    case tooLate

    var title: String {
        switch self {
        case .failed:
            return "Failed"
        case .strike:
            return "Strike"
        case .tooLate:
            return "Too Late"
        }
    }

    var message: String {
        switch self {
        case .failed:
            return "The movement was not a fish bite. Watch the bobber again and wait for the right signal."
        case .strike:
            return "Nice read. That was the right moment to react to the bobber movement."
        case .tooLate:
            return "You waited too long. Pull right after the pause so the fish does not get away."
        }
    }

    var iconName: String {
        switch self {
        case .failed:
            return "xmark.circle.fill"
        case .strike:
            return "checkmark.circle.fill"
        case .tooLate:
            return "clock.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .failed:
            return Color(red: 0.83, green: 0.36, blue: 0.33)
        case .strike:
            return Color(red: 0.22, green: 0.60, blue: 0.43)
        case .tooLate:
            return Color(red: 0.89, green: 0.60, blue: 0.22)
        }
    }
}

struct FeedbackCard: View {
    let state: FeedbackCardState
    var onTryAgain: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: state.iconName)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(state.accentColor)

                VStack(alignment: .leading, spacing: 6) {
                    Text(state.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))

                    Text(state.message)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button {
                onTryAgain()
            } label: {
                Text("Try Again")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(state.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(20)
        .background(.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(state.accentColor.opacity(0.2), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 18, y: 8)
    }
}

#Preview {
    FeedbackCardPreview()
        .padding()
        .background(Color(red: 0.75, green: 0.88, blue: 0.96))
}

private struct FeedbackCardPreview: View {
    @State private var selectedState: FeedbackCardState = .failed

    var body: some View {
        VStack(spacing: 20) {
            Picker("Feedback", selection: $selectedState) {
                Text("Failed").tag(FeedbackCardState.failed)
                Text("Strike").tag(FeedbackCardState.strike)
                Text("Too Late").tag(FeedbackCardState.tooLate)
            }
            .pickerStyle(.segmented)

            FeedbackCard(state: selectedState)
        }
    }
}
