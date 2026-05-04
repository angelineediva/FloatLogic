//
//  HomeView.swift
//  FloatLojic
//
//  Created by Feivel Qutby on 04/05/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(maxHeight: 100)
            Text("Float Logic")
                .font(Font.largeTitle.bold())
            Spacer()
                .frame(maxHeight: 300)
            Button("Start") {
            }
            .fontWeight(.heavy)
            .padding(.horizontal, 30)
            .padding(.vertical, 10)
            .glassEffect()
            .foregroundStyle(Color(.black))
            .buttonBorderShape(.roundedRectangle)
            Text("P")
        }
    }
}

#Preview {
    HomeView()
}
