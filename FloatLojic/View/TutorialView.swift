//
//  TutorialView.swift
//  FloatLojic
//
//  Created by Feivel on 30/04/26

import SwiftUI

struct TutorialView: View {
    @StateObject private var vm = TutorialViewModel()
    @State private var selectedIndex: Int = 0
    @State private var showsPracticeView = false
    
    
    private var bubbleImageName: String {
        switch vm.bubbleState {
        case .none: return ""
        case .one: return "bubblestate1"
        case .two: return "bubblestate2"
        case .three: return "bubblestate3"
        case .four: return "bubblestate4"
        }
    }
    
    private var bubbleStrikeImageName: String {
        switch vm.bubbleStrikeState {
        case .none:
            return ""
        case .one:
            return "Splash1"
        case .two:
            return "Splash2"
        case .three:
            return "Splash3"
        case .four:
            return "Splash4"
        case .five:
            return "Splash5"
        }
    }
    
    var body: some View {
        
        
        VStack(spacing: 0) {
            animationFrame
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            TutorialCard(
                disturbances: DisturbanceInfo.all,
                selectedIndex: $selectedIndex,
                onStart: { showsPracticeView = true }
            )
            //                .padding(.horizontal, 20)
                            .padding(.top, 12)
//                            .padding(.bottom, 24)
        }
        .navigationDestination(isPresented: $showsPracticeView) {
            PracticeView()
        }
        .onAppear {
            vm.startLoop(for: selectedDisturbance.type)
        }
        
        .onChange(of: selectedIndex) { _, _ in
            vm.startLoop(for: selectedDisturbance.type)
        }
    }
    
    private var selectedDisturbance: DisturbanceInfo {
        DisturbanceInfo.all[selectedIndex]
    }
    
    private var animationFrame: some View {
        GeometryReader { geometry in
            let frameWidth = geometry.size.width + 80
            let frameHeight = geometry.size.height
            
            ZStack {
                
                
                
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameWidth, height: frameHeight)
                
                Image("Water")
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameWidth, height: frameHeight)
                
                Image("BobberFull")
                    .resizable()
                    .frame(width: 40, height: 80)
                    .rotationEffect(.degrees(vm.rotation))
                    .offset(x: vm.offsetX, y: vm.offsetY + 70)
                
                Image("airnew")
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameWidth, height: frameHeight)
                    .offset(x: -5)
                
                if vm.bubbleState != .none {
                    Image(bubbleImageName)
                        .resizable()
                        .frame(width: frameWidth, height: frameHeight)
                        .offset(x: 0, y: 55)
                    
                }
                
                if vm.bubbleStrikeState != .none {
                    Image(bubbleStrikeImageName)
                        .resizable()
                        .frame(width: frameWidth, height: frameHeight)
                        .offset(x: 0, y: 55 )
                }
                
                
                
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .ignoresSafeArea(edges: [.top, .horizontal])
    }
}




#Preview {
    TutorialView()
}
