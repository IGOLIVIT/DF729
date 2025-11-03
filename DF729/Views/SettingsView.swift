//
//  SettingsView.swift
//  DF729
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameData: GameDataManager
    @Binding var isPresented: Bool
    @State private var showResetAlert = false
    @State private var slideIn = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissView()
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Statistics")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { dismissView() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(ThemeColors.textSecondary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30)
                    .padding(.bottom, 30)
                    
                    // Stats cards
                    VStack(spacing: 20) {
                        StatCard(
                            icon: "sparkles",
                            title: "Total Fragments",
                            value: "\(gameData.totalFragments)",
                            color: ThemeColors.primaryAccent
                        )
                        
                        StatCard(
                            icon: "gamecontroller.fill",
                            title: "Games Played",
                            value: "\(gameData.totalGamesPlayed)",
                            color: ThemeColors.secondaryAccent
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                    
                    // Reset button
                    VStack(spacing: 16) {
                        GlowingButton(
                            title: "Reset Progress",
                            action: { showResetAlert = true },
                            color: ThemeColors.secondaryAccent
                        )
                        .padding(.horizontal, 24)
                        
                        Button(action: { dismissView() }) {
                            Text("Close")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(ThemeColors.textSecondary)
                        }
                        .padding(.bottom, 10)
                    }
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(ThemeColors.background)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(
                                    LinearGradient(
                                        colors: [ThemeColors.primaryAccent.opacity(0.5), ThemeColors.secondaryAccent.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: ThemeColors.secondaryAccent.opacity(0.3), radius: 30, x: 0, y: -10)
                )
                .offset(y: slideIn ? 0 : 500)
            }
            .ignoresSafeArea()
            
            // Reset confirmation alert
            if showResetAlert {
                ResetAlertView(
                    isPresented: $showResetAlert,
                    onConfirm: {
                        gameData.resetProgress()
                        showResetAlert = false
                        
                        let successFeedback = UINotificationFeedbackGenerator()
                        successFeedback.notificationOccurred(.success)
                    }
                )
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                slideIn = true
            }
        }
    }
    
    private func dismissView() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            slideIn = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
                .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 0)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(ThemeColors.textSecondary)
                
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct ResetAlertView: View {
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .opacity(opacity)
            
            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(ThemeColors.secondaryAccent)
                    .shadow(color: ThemeColors.secondaryAccent.opacity(0.6), radius: 20, x: 0, y: 0)
                
                VStack(spacing: 12) {
                    Text("Reset Progress?")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("This will reset all fragments and statistics. This action cannot be undone.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(ThemeColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                VStack(spacing: 12) {
                    GlowingButton(
                        title: "Reset",
                        action: onConfirm,
                        color: ThemeColors.secondaryAccent
                    )
                    
                    GlowingButton(
                        title: "Cancel",
                        action: { isPresented = false },
                        isSecondary: true
                    )
                }
                .padding(.top, 10)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(ThemeColors.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(ThemeColors.secondaryAccent.opacity(0.5), lineWidth: 2)
                    )
                    .shadow(color: ThemeColors.secondaryAccent.opacity(0.4), radius: 30, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

