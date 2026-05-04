//
//  Tutorial2View.swift
//  FloatLojic
//
//  Created by Angeline on 02/05/26.
//

import SwiftUI

enum BobberState {
    case wind
    case nibble
    case strike
    case empty
}

enum BubbleState {
    case none, small, medium, large
}


struct MovingWaterView: View {
    @State private var offsetX: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            let height: CGFloat = 200
            
            HStack(spacing: 0) {
                Image("Air Atas Panjang")
                    .resizable()
                    .scaledToFill()
                    .frame(height: height)
                
                Image("Air Atas Panjang")
                    .resizable()
                    .scaledToFill()
                    .frame(height: height)
            }
            .background(
                GeometryReader { innerGeo in
                    Color.clear
                        .onAppear {
                            let contentWidth = innerGeo.size.width / 2
                            
                            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                                offsetX = -contentWidth
                            }
                        }
                }
            )
            .offset(x: offsetX)
            .clipped()
        }
        .frame(height: 100)
    }
}

struct Tutorial2View: View {
    @State private var bobberState: BobberState = .wind
    
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var rotation: Double = 0
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
                Image("Bobber Miring")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: 442)
                    .clipped()
                    .offset(x: offsetX, y: offsetY - 70)
                    .rotationEffect(.degrees(rotation))
                
                MovingWaterView()
                
                
                Image("Frame putih")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height:800)
                    .clipped()
                    .offset(y: 50)
                
                    .onTapGesture {
                        //                        animateWind()
                        //                        animateEmpty()
                                                animateNibble()
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
    Tutorial2View()
}
