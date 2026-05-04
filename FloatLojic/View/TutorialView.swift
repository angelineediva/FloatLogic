//
//  TutorialView.swift
//  FloatLojic
//
//  Created by Feivel on 30/04/26

import SwiftUI

struct TutorialView: View {
    
    //     MARK: - Bobber & Bubble State
    
    enum BubbleState {
        case none, small, medium, large
    }
    
    let bobberImages = [
        "BobberFull", //STATE 1 SBLM KECEMPLUNG
        "BobberSt2",
        "BobberSt3",
        "BobberSt4",
        "BobberSt5"  // Kecemplung
    ]
    
    @State private var bobberIndex: Int = 0
    @State private var bubbleState: BubbleState = .none
    
    // motion
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var rotation: Double = 0
    
    // cancel previous animations
    @State private var animationID = UUID()
    
    var body: some View {
        ZStack {
            
            Image("Background")
                .resizable()
                .frame(width: 349, height: 380)
                .offset(y : -75)
            
            Image("Water")
                .resizable()
                .frame(width: 349, height: 442)
                .offset(y : -75)
            
            
            // GELEMBUNG AER
            if bubbleState != .none {
                Image("Bubble")
                    .resizable()
                    .frame(width: bubbleSize.width, height: bubbleSize.height)
                    .offset(x: offsetX + 3, y: offsetY + 10)
                    .opacity(0.7)
                    .animation(.easeInOut(duration: 0.2), value: bubbleState)
            }
            
            // BOBBER
            Image(bobberImages[bobberIndex])
                .resizable()
                .frame(width: 40, height: 80)
                .offset(x: offsetX, y: offsetY - 20)
                .rotationEffect(.degrees(rotation))
                .animation(.easeInOut(duration: 0.15), value: bobberIndex)
        }
        .onTapGesture {
            //            animateEmpty()
            animateWind()
            //            animateNibble()
            //            animateStriker()
        }
    }
    
    // MARK: - Bubble Size
    
    var bubbleSize: CGSize {
        switch bubbleState {
        case .none:
            return .zero
        case .small:
            return CGSize(width: 81, height: 33)
        case .medium:
            return CGSize(width: 123, height: 51)
        case .large:
            return CGSize(width: 169, height: 70)
        }
    }
    
    // MARK: - Reset
    
    func reset() {
        animationID = UUID() // invalidate previous sequence
        offsetX = 0
        offsetY = 0
        rotation = 0
        bobberIndex = 0
        bubbleState = .none
    }
    
    // MARK: - Animations
    
    // Wind
    func animateWind() {
        reset()
        
        bubbleState = .none
        
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            offsetX = 15
            rotation = 5
        }
    }
    
    //Nibble
    func animateNibble() {
        reset()
        let currentID = animationID
        
        bubbleState = .small
        
        withAnimation(.easeInOut(duration: 0.2)) {
            bobberIndex = 1
            offsetY = 6
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard currentID == animationID else { return }
            bubbleState = .medium
            bobberIndex = 2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            guard currentID == animationID else { return }
            bobberIndex = 0
            offsetY = 0
            bubbleState = .none
        }
    }
    
    func animateStriker() {
        reset()
        let currentID = animationID
        
        bubbleState = .small
        
        withAnimation(.easeInOut(duration: 0.2)) {
            bobberIndex = 1
            offsetY = 6
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard currentID == animationID else { return }
            bubbleState = .medium
            bobberIndex = 2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard currentID == animationID else { return }
            bubbleState = .medium
            bobberIndex = 3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard currentID == animationID else { return }
            bubbleState = .medium
            bobberIndex = 4
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            guard currentID == animationID else { return }
            bobberIndex = 0
            offsetY = 0
            bubbleState = .none
        }
    }
    // Strike
    func animateStrike() {
        reset()
        let currentID = animationID
        
        bubbleState = .small
        
        withAnimation(.easeIn(duration: 0.1)) {
            bobberIndex = 1
            //            offsetY = 10
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard currentID == animationID else { return }
            bubbleState = .medium
            bobberIndex = 2
            //            offsetY = 20
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard currentID == animationID else { return }
            bubbleState = .large
            bobberIndex = 3
            //            offsetY = 30
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard currentID == animationID else { return }
            bobberIndex = 4
            //            offsetY = 40
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            guard currentID == animationID else { return }
            bobberIndex = 0
            //            offsetY = 0
            bubbleState = .none
        }
    }
    
    // Nobait (umpan gone)
    func animateEmpty() {
        reset()
        
        bubbleState = .none
        
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            offsetX = 2
        }
    }
}

#Preview {
    TutorialView()
}
