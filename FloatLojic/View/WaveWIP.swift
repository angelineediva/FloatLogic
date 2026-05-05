//
//  WaveWIP.swift
//  FloatLojic
//
//  Created by Angeline on 02/05/26.
//

import SwiftUI
import Combine

enum BobberState {
    case wind
    case nibble
    case strike
    case empty
}

enum BubbleState {
    case none, small, medium, large
}


//struct MovingWaterView: View {
//    @State private var offsetX: CGFloat = 0
//
//    var body: some View {
//        GeometryReader { geo in
//            let height: CGFloat = 200
//
//            HStack(spacing: 0) {
//                Image("Air Atas Panjang")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(height: height)
//
//                Image("Air Atas Panjang")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(height: height)
//            }
//            .background(
//                GeometryReader { innerGeo in
//                    Color.clear
//                        .onAppear {
//                            let contentWidth = innerGeo.size.width / 2
//
//                            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
//                                offsetX = -contentWidth
//                            }
//                        }
//                }
//            )
//            .offset(x: offsetX)
//            .clipped()
//        }
//        .frame(height: 100)
//    }
//}



struct WaveWIP: View {
    @State private var bobberState: BobberState = .wind
    
    
    @State private var isVisible = false
    @State private var wiggleOffset: CGFloat = 0.0
    
    
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var rotation: Double = 0
    
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    let timer2 = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: 442)
                    .clipped()
                    .offset(y: -75)
                    .scaleEffect(1.1)
                
                Image("Water")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: 442)
                    .clipped()
                    .offset(y: -75)
                    .scaleEffect(1.1)
                
                //                Image("Gelembung Air")
                //                    .resizable()
                //                    .scaledToFill()
                //                    .frame(width: geo.size.width, height: 442)
                //                    .clipped()
                //                    .offset(y: -70)
                //
                //                Image("Bobber Miring")
                //                    .resizable()
                //                    .scaledToFill()
                //                    .frame(width: geo.size.width, height: 442)
                //                    .clipped()
                //                    .offset(x: offsetX, y: offsetY - 70)
                //                    .rotationEffect(.degrees(rotation))
                
                
                ZStack {
                    Image("ombak")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                    // Menggunakan variabel punyamu
                        .offset(x: offsetX + wiggleOffset, y: offsetY)
                    //                                .rotationEffect(.degrees(rotation))
                    // Efek muncul hilang
                        .opacity(isVisible ? 1 : 0)
                    //                                .scaleEffect(isVisible ? 1 : 0.5)
                }
                .onReceive(timer) { _ in
                    // Setiap 2 detik, ombak hilang dulu, pindah posisi, baru muncul lagi
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isVisible = false
                    }
                    
                    // Delay sedikit untuk pindah posisi sebelum muncul lagi
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        offsetX = CGFloat.random(in: -150...150)
                        offsetY = CGFloat.random(in: -100...100)
                        
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                            isVisible = true
                        }
                    }
                }
                .onAppear {
                    // Animasi wiggle tetap jalan terus secara horizontal
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        wiggleOffset = 10
                    }
                }
                
                ZStack {
                    Image("ombak")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                    // Menggunakan variabel punyamu
                        .offset(x: offsetX + wiggleOffset, y: offsetY)
                    //                                .rotationEffect(.degrees(rotation))
                    // Efek muncul hilang
                        .opacity(isVisible ? 1 : 0)
                    //                                .scaleEffect(isVisible ? 1 : 0.5)
                }
                .onReceive(timer2) { _ in
                    // Setiap 2 detik, ombak hilang dulu, pindah posisi, baru muncul lagi
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isVisible = false
                    }
                    
                    // Delay sedikit untuk pindah posisi sebelum muncul lagi
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        offsetX = CGFloat.random(in: -150...150)
                        offsetY = CGFloat.random(in: -100...100)
                        
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                            isVisible = true
                        }
                    }
                }
                .onAppear {
                    // Animasi wiggle tetap jalan terus secara horizontal
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        wiggleOffset = 10
                    }
                }
                
                
                
                //                VStack {
                //                    Image("ombak")
                //                        .resizable()
                //                        .scaledToFit()
                //                        .frame(width: 150)
                //                        .offset(x: 80, y: -30)
                //
                //
                //                        .opacity(isVisible ? 1 : 0)
                //                        .scaleEffect(isVisible ? 1 : 0.5)
                //
                //                        .offset(x: wiggleOffset)
                //                }
                //                .onAppear {
                //
                //                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                //                        isVisible = true
                //                    }
                //
                //                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                //                        withAnimation(
                //                            .easeInOut(duration: 1.2)
                //                            .repeatForever(autoreverses: true)
                //                        ) {
                //                            wiggleOffset = 15.0
                //                        }
                //                    }
                //
                //                }
                ////                        Image("ombak")
                //                            .resizable()
                //                            .scaledToFit()
                //                            .frame(width: 250)
                //                            .opacity(isVisible ? 1 : 0) // Fade in
                //                            .scaleEffect(isVisible ? 1 : 0.5) // Pop
                
                
                
                Image("Frame putih")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height:800)
                    .clipped()
                    .offset(y: 50)
                
                    .onTapGesture {
                        //                        animateWind()
                        //                        animateEmpty()
                        //                        animateNibble()
                        //                        animateStrike()
                    }
            }
        }
        
        
        
        
    }
    
    func animateWind() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            offsetX = 8
            rotation = 5
        }
    }
    
    
    func animateEmpty() {
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            offsetX = 2
        }
    }
    
    func animateNibble() {
        withAnimation(.easeInOut(duration: 0.2)) {
            offsetY = 10
            rotation = -5
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                offsetY = 0
                rotation = 0
            }
        }
    }
    
    func animateStrike() {
        withAnimation(.easeIn(duration: 0.15)) {
            offsetY = 40
            rotation = -10
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring()) {
                offsetY = 0
                rotation = 0
            }
        }
    }
    
    
}



#Preview {
    WaveWIP()
}
