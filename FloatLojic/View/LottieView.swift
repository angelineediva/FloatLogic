//
//  LottieView.swift
//  FloatLojic
//
//  Created by Angeline on 05/05/26.
//


import SwiftUI
import DotLottie

struct LottieView: View {
    let lottieFile: String
    
    var body: some View {
        DotLottieAnimation(
            fileName: lottieFile,
            config: AnimationConfig(
                autoplay: true,
                loop: true
            )
        ).view()
    }
}

#Preview {
    LottieView(lottieFile: "BubbleNibble")
}
