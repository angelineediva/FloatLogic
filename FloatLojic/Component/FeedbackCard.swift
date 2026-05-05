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
                .frame(width: 370, height: 550)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.top, 30)
                
            
            VStack{
//                Text(selectFeedback.title)
//                    .font(.system(size: 35, weight: .black, design: .rounded))
//                    .foregroundStyle(.black)
//                    .fontWeight(.bold)
//                    .foregroundColor(.black)
//                    .padding(.horizontal, 20)
//                    .padding(.top, 30)
//                 
                
                Image(selectFeedback.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 190)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                
                
                VStack{
                    
                    VStack{
                        Text(selectFeedback.message)
                            .font(.system(size: 24, weight: .black, design: .rounded))
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
                            
                            
                            
                            
                        
                    }
                    //.background(Color(.blue).opacity(0.15))
                    .cornerRadius(20)
                    .padding(.bottom, 20)
                    
                    
                    
                    
                    
                    
                    HStack{
                        
                        
                        Button(action: {
                            onStartNow()
                        }) {
                            Text("Home")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .padding()
                                .padding(.horizontal, 30)
                                .background(Color(.gray).opacity(0.15))
                                .cornerRadius(50)
                            
//                                .background(
//                                    Capsule()
//                                        .fill(Color.gray.opacity(0.05))
//                                        .overlay(
//                                            Capsule()
//                                                  .stroke(Color.black.opacity(0.2), lineWidth: 4)
//                                                .blur(radius: 3)
//                                                .offset(x: 2, y: 2)
//                                                .mask(Capsule())
//                                        )
//                                )
                            
                        }
                        
                        Button(action: {
                            onStartNow()
                        }) {
                            Text("Try Again")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .padding(.horizontal, 20)
                                .background(Color(.blue).opacity(0.8))
                                .cornerRadius(50)
                            
                            
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
