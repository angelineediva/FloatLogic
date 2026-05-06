//
//  Untitled.swift
//  FloatLojic
//
//  Created by Angeline on 30/04/26.
//

import Foundation
import SwiftUI

struct FeedbackCard: View {
    let state: FeedbackCardState
    var onHome: () -> Void = {}
    var onTryAgain: () -> Void = {}

    private var feedback: FeedbackInfo {
        state.feedbackInfo
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {}

            Rectangle()
                .fill(Color.white.opacity(1))
                .frame(width: 370, height: 550)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.top, 30)

            VStack {
                Image(feedback.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 190)
                    .padding(.bottom, 20)
                    .padding(.top, 20)

                VStack {
                    VStack {
                        Text(feedback.message)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .fontWeight(.bold)
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 10)

                        Text(feedback.body)
                            .font(.system(size: 15))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                    .cornerRadius(20)
                    .padding(.bottom, 20)

                    HStack {
                        Button(action: {
                            onHome()
                        }) {
                            Text("Home")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color(.gray).opacity(0.15))
                                .cornerRadius(50)
                        }

                        Button(action: {
                            onTryAgain()
                        }) {
                            Text("Try Again")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
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
    FeedbackCard(state: .strike)
}
