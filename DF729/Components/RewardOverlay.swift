//
//  RewardOverlay.swift
//  DF729
//

import SwiftUI

struct RewardOverlay: View {
    let fragmentsEarned: Int
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var particlesOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .opacity(opacity)
            
            VStack(spacing: 30) {
                // Particle effect
                ZStack {
                    ForEach(0..<12) { i in
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [ThemeColors.primaryAccent, ThemeColors.secondaryAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 8, height: 8)
                            .offset(
                                x: cos(Double(i) * .pi / 6) * 80,
                                y: sin(Double(i) * .pi / 6) * 80
                            )
                            .opacity(particlesOpacity)
                    }
                }
                
                // Main icon
                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ThemeColors.primaryAccent, ThemeColors.secondaryAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: ThemeColors.primaryAccent.opacity(0.8), radius: 30, x: 0, y: 0)
                
                VStack(spacing: 12) {
                    Text("Journey Complete!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("You collected")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(ThemeColors.textSecondary)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 28))
                            .foregroundColor(ThemeColors.primaryAccent)
                        
                        Text("\(fragmentsEarned)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(fragmentsEarned == 1 ? "Fragment" : "Fragments")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                }
                
                GlowingButton(title: "Continue", action: onDismiss)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(ThemeColors.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(
                                LinearGradient(
                                    colors: [ThemeColors.primaryAccent, ThemeColors.secondaryAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: ThemeColors.secondaryAccent.opacity(0.4), radius: 30, x: 0, y: 10)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                particlesOpacity = 1.0
            }
            
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
        }
    }
}

