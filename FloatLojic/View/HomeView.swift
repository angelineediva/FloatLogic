//
//  HomeView.swift
//  FloatLojic
//
//  Created by Feivel Qutby on 04/05/26.
//

import AVFoundation
import SwiftUI
import UIKit

struct HomeView: View {
    @GestureState private var isPressed = false
    var body: some View {
        
        ZStack {
            LoopingVideoBackground(name: "HomepageAsset", fileExtension: "mov")
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            VStack {
                Spacer()
                    .frame(maxHeight: 50)
                Text("Float Logic")
                    .font(.system(size: 58, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.4), radius: 0, x: 3, y: 3) // hard shadow biar cartoon
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                Spacer()
                    .frame(maxHeight: 400)
               
                NavigationLink {
                    TutorialView()
                } label: {
                    HStack(spacing: 8) {
                        Text("START")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(.black.opacity(0.7))
                    .padding(.horizontal, 36)
                    .padding(.vertical, 16)
                }
                .glassEffect(.clear, in: Capsule())
                .buttonStyle(.plain)
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                .scaleEffect(isPressed ? 1.12 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .updating($isPressed) { _, state, _ in
                            state = true
                        }
                )            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}



#Preview {
    HomeView()
}
