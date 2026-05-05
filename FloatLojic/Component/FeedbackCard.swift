//
//  Untitled.swift
//  FloatLojic
//
//  Created by Angeline on 30/04/26.
//

import Foundation
import SwiftUI

struct FeedbackCard: View {
    
    let feedback: [FeedbackInfo]
    var onStartNow: () -> Void = {}
    
    @State private var selectFeedbackIndex: Int = 0
    
    
    private var selectFeedback: FeedbackInfo {
        feedback[selectFeedbackIndex]
    }
    
    
    var body: some View {
        
        ZStack{
            
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                }
            
            Rectangle()
                .fill(Color.white.opacity(1))
                .frame(width: 370, height: 560)
                .cornerRadius(20)
                .shadow(radius: 10)
            
            VStack{
                Text(selectFeedback.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                
                
                Image(selectFeedback.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .padding()
                
                
                
                
                VStack{
                    
                    VStack{
                        Text(selectFeedback.message)
                            .fontWeight(.bold)
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                        
                        
                        Text(selectFeedback.body)
                            .font(.system(size: 15))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .multilineTextAlignment(.center)
                        
                    }
                    .background(Color(.gray).opacity(0.2))
                    .cornerRadius(20)
                    .padding()
                    
                    
                    
                    
                    
                    
                    HStack{
                        
                        Button(action: {
                            onStartNow()
                        }) {
                            Text("Try Again")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(.blue).opacity(0.8))
                                .cornerRadius(10)
                            
                            
                        }
                        
                        
                        Button(action: {
                            onStartNow()
                        }) {
                            Text("Home")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .padding()
                                .padding(.horizontal, 15)
                                .background(Color(.white).opacity(0.05))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                            
                            
                        }
                        
                        
                    }
                    
                }
                
                
                
            }
            
            .padding(20)
            .cornerRadius(20)
            
            
            
            
        }
    }
    
}

#Preview {
    FeedbackCard(feedback: FeedbackInfo.all)
}
