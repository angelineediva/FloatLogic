//
//  TutorialView.swift
//  FloatLojic
//
//  Created by Angeline on 30/04/26.
//  Adjusted by Feivel on 30/04/26

import SwiftUI

struct TutorialView: View {
    var body: some View {
        
        Color(.gray).edgesIgnoringSafeArea(.all)
        
        TutorialCard(disturbances: DisturbanceInfo.all)
        //            .padding(.horizontal, 16)
        //            .padding(.bottom, 32)
    }
}

#Preview {
    TutorialView()
}
