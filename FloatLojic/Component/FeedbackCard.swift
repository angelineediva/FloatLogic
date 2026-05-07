import SwiftUI

struct FeedbackCard: View {
    let feedback: FeedbackInfo
    
    @State private var bodyText: String = ""
    
    var onHome: () -> Void = {}
    var onTryAgain: () -> Void = {}
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Image
                Image(feedback.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 180)
                    .padding(.top, 28)
                    .padding(.bottom, 24)
                
                // Message title
                Text(feedback.message)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                
                // Body (RANDOM)
                Text(bodyText)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                
                Divider()
                
                // Buttons
                Button(action: onTryAgain) {
                    HStack(spacing: 8) {
                        Text("Try Again")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                        
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.label))
                    .foregroundColor(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
            .padding(.horizontal, 24)
            .padding(.top, 30)
        }
        .onAppear {
            bodyText = feedback.randomBody
        }
    }
}

#Preview {
    FeedbackCard(feedback: FeedbackInfo.strikeData)
}
