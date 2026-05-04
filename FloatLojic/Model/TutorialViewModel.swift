//
//  TutorialViewModel.swift
//  FloatLojic
//
//  Created by Angeline on 04/05/26.
//

import SwiftUI
import Combine

class TutorialViewModel: ObservableObject {
    
    
    //JANGAN DIHAPUS YANG BUBBLE KARENA AKAN KEPAKE
    enum BubbleState {
        case none, small, medium, large
    }
    
    @Published var bubbleState: BubbleState = .none
    @Published var offsetY: CGFloat = 0
    @Published var offsetX: CGFloat = 0
    @Published var rotation: Double = 0
    
    private var animationID = UUID()
    
    // MARK: - Reset
    func reset() {
        animationID = UUID()
        offsetX = 0
        offsetY = 0
        rotation = 0
        bubbleState = .none
    }
    
    // MARK: - Animations
    
    
    //kena angin
    func animateWind() {
        reset()
        
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            offsetX = 5
            rotation = 5
        }
    }
    
    //kenanibble
    func animateNibble() {
        reset()
        let currentID = animationID
        
        bubbleState = .small
        
        withAnimation(.easeInOut(duration: 0.2)) {
            offsetY = 6
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard currentID == self.animationID else { return }
            self.bubbleState = .medium
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            guard currentID == self.animationID else { return }
            self.offsetY = 0
            self.bubbleState = .none
        }
    }
    
    //kena umpan
    func animateStriker() {
        reset()
        let currentID = animationID
        
        bubbleState = .small
        
        withAnimation(.easeInOut(duration: 0.15)) {
            offsetY = 50
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            guard currentID == self.animationID else { return }
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.4)) {
                self.offsetY = 30
            }
        }
    }
    
    //umpan kosong
    func animateEmpty() {
        reset()
        
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            offsetX = 2
        }
    }
}
