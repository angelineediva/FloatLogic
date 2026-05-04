//
//  HomeView.swift
//  FloatLojic
//
//  Created by Feivel Qutby on 04/05/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack{
            Image("Background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(maxHeight: 100)
                Text("Float Logic")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.black)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                Spacer()
                    .frame(maxHeight: 300)
                Button {
                    // Action here
                } label: {
                    Text("Start now")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 16)
                }
                .glassEffect(.regular, in: Capsule())
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    HomeView()
}
