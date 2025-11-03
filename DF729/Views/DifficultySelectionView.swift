//
//  DifficultySelectionView.swift
//  DF729
//

import SwiftUI

enum GameDifficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var description: String {
        switch self {
        case .easy:
            return "Perfect for beginners"
        case .medium:
            return "Balanced challenge"
        case .hard:
            return "Test your limits"
        }
    }
    
    var icon: String {
        switch self {
        case .easy:
            return "star.fill"
        case .medium:
            return "star.leadinghalf.filled"
        case .hard:
            return "flame.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .easy:
            return .green
        case .medium:
            return ThemeColors.secondaryAccent
        case .hard:
            return ThemeColors.primaryAccent
        }
    }
}

struct DifficultySelectionView: View {
    let gameType: MiniGameType
    @Binding var isPresented: Bool
    @Binding var selectedDifficulty: GameDifficulty?
    
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
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: gameType.icon)
                            .font(.system(size: 50))
                            .foregroundColor(ThemeColors.primaryAccent)
                            .shadow(color: ThemeColors.primaryAccent.opacity(0.6), radius: 15)
                        
                        Text(gameType.rawValue)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Choose Difficulty")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                    
                    // Difficulty options
                    VStack(spacing: 16) {
                        ForEach(GameDifficulty.allCases, id: \.self) { difficulty in
                            DifficultyButton(difficulty: difficulty) {
                                selectDifficulty(difficulty)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Cancel button
                    Button(action: { dismissView() }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    .padding(.top, 10)
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
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: ThemeColors.secondaryAccent.opacity(0.3), radius: 30, x: 0, y: -10)
                )
                .offset(y: slideIn ? 0 : 500)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                slideIn = true
            }
        }
    }
    
    private func selectDifficulty(_ difficulty: GameDifficulty) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        selectedDifficulty = difficulty
        dismissView()
    }
    
    private func dismissView() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            slideIn = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if selectedDifficulty == nil {
                isPresented = false
            }
        }
    }
}

struct DifficultyButton: View {
    let difficulty: GameDifficulty
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: difficulty.icon)
                    .font(.system(size: 28))
                    .foregroundColor(difficulty.color)
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.rawValue)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(difficulty.description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(ThemeColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(difficulty.color)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ThemeColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(difficulty.color.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

