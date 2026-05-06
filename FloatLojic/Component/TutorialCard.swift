//
//  TutorialCard.swift
//  FloatLojic
//
//  Created by Feivel Qutby on 30/04/26.
//

import SwiftUI

struct TutorialCard: View {
    let disturbances: [DisturbanceInfo]
    @Binding var selectedIndex: Int
    var onStart: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            tabIndicator
                .padding(.bottom, 17)

            TabView(selection: $selectedIndex) {
                ForEach(Array(disturbances.enumerated()), id: \.offset) { index, disturbance in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(disturbance.title)
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .padding(.bottom, 4)

                        Text(disturbance.body)
                            .font(.system(size: 17, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                            .environment(\.layoutDirection, .leftToRight)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)

                        Spacer(minLength: 0)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 150)
            .padding(.bottom, 24)

            startButton
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Tab Indicator
    private var tabIndicator: some View {
        Picker("Disturbance", selection: $selectedIndex) {
            ForEach(disturbances.indices, id: \.self) { index in
                Image(systemName: disturbances[index].iconName)
                    .accessibilityLabel(disturbances[index].title)
                    .tag(index)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - CTA Button
    private var startButton: some View {
        Button {
            onStart()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "figure.fishing")
                    .font(.system(size: 16))
                Text("Start Now")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.label))
            .foregroundColor(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

#Preview {
    TutorialView()
}

private struct TutorialCardPreview: View {
    @State private var selectedIndex: Int = 0

    var body: some View {
        TutorialCard(disturbances: DisturbanceInfo.all, selectedIndex: $selectedIndex)
            .padding()
    }
}
