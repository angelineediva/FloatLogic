//
//  TutorialView.swift
//  FloatLojic
//
//  Created by Angeline on 30/04/26.
//  Adjusted by Feivel on 30/04/26

import SwiftUI

struct TutorialView: View {
    var body: some View {
        ZStack(alignment: .bottom) {

            // Placeholder canvas
            TabView {
                ForEach(DisturbanceInfo.all.indices, id: \.self) { index in
                    let item = DisturbanceInfo.all[index]
                    ZStack {
                        // Background warna beda tiap disturbance
                        LinearGradient(
                            colors: gradientColors(for: index),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()

                        Text(item.title)
                            .font(.system(size: 18, weight: .medium, design: .serif))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // TutorialCard floating di bawah
            TutorialCard(disturbances: DisturbanceInfo.all) {
                print("Start Now tapped")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .ignoresSafeArea(edges: .top)
    }

    func gradientColors(for index: Int) -> [Color] {
        switch index {
        case 0: return [Color(hex: "1a6080"), Color(hex: "0a1e3a")] // Wind — biru gelap
        case 1: return [Color(hex: "1a5c6e"), Color(hex: "0d2535")] // Wave — teal gelap
        case 2: return [Color(hex: "1a3d5c"), Color(hex: "0a1628")] // Fish — navy
        default: return [Color(hex: "2a4858"), Color(hex: "0f2030")] // Current — slate
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    TutorialView()
}
