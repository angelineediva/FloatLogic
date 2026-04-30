//
//  TutorialCard.swift
//  FloatLojic
//
//  Created by Feivel Qutby on 30/04/26.
//

import SwiftUI

struct TutorialCard: View {
    let disturbances: [DisturbanceInfo]
    var onStartNow: () -> Void = {}

    @State private var selectedIndex: Int = 0

    private var selected: DisturbanceInfo {
        disturbances[selectedIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            tabIndicator
                .padding(.bottom, 20)

            Text(selected.title)
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundColor(.primary)
                .padding(.bottom, 8)

            Text(selected.body)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .padding(.bottom, 24)
                .environment(\.layoutDirection, .leftToRight)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)

            startButton
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(20)
    }

    // MARK: - Tab Indicator
    private var tabIndicator: some View {
        HStack(spacing: 0) {
            ForEach(disturbances.indices, id: \.self) { index in
                let item = disturbances[index]
                let isActive = index == selectedIndex

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedIndex = index
                    }
                } label: {
                    VStack(spacing: 6) {
                        Circle()
                            .fill(isActive ? Color.teal : Color(.label))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: item.iconName)
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(.white)
                            )

                        Text(item.title.components(separatedBy: " ").last ?? item.title)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(isActive ? .teal : Color(.secondaryLabel))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(width: 56)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(.clear)
        .clipShape(Capsule())
        .glassEffect(.regular.tint(.clear), in: Capsule())
    }

    // MARK: - CTA Button
    private var startButton: some View {
        Button {
            onStartNow()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "figure.fishing")
                    .font(.system(size: 16))
                Text("Start Now")
                    .font(.system(size: 16, weight: .medium, design: .serif))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.label))
            .foregroundColor(Color(.systemBackground))
            .cornerRadius(14)
        }
    }
}

#Preview {
    TutorialCard(disturbances: DisturbanceInfo.all)
        .padding()
}
