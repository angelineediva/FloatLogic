//
//  HomeView.swift
//  FloatLojic
//
//  Created by Feivel Qutby on 04/05/26.
//
import SwiftUI

struct HomeView: View {
    @State private var opacity: Double = 1.0
    @State private var showTutorial = false

    var body: some View {
        ZStack {
            if showTutorial {
                TutorialView()
                    .transition(.opacity)
            } else {
                ZStack {
                    LoopingVideoBackground(name: "HomepageAsset", fileExtension: "mov")
                        .ignoresSafeArea()
                        .allowsHitTesting(false)

                    VStack {
                        Spacer()
                            .frame(maxHeight: 150)
                        Text("PLup!")
                            .font(.system(size: 58, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.4), radius: 0, x: 3, y: 3)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        Spacer()
                    }
                }
                .opacity(opacity)
                .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    opacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showTutorial = true
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
