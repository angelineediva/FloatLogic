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
        Picker("Disturbance", selection: $selectedIndex) {
            ForEach(disturbances.indices, id: \.self) { index in
                Image(systemName: disturbances[index].iconName)
                    .tag(index)
            }
        }
        .pickerStyle(.segmented)
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
