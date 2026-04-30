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
            
            
            // TutorialCard floating di bawah
            TutorialCard(disturbances: DisturbanceInfo.all) {
                print("Start Now tapped")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    TutorialView()
}
