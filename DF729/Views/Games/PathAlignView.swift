//
//  PathAlignView.swift
//  DF729
//

import SwiftUI

struct PathAlignView: View {
    @EnvironmentObject var gameData: GameDataManager
    @Binding var isPresented: Bool
    let difficulty: GameDifficulty
    
    @State private var userTaps: [Int] = []
    @State private var score = 0
    @State private var round = 1
    @State private var showReward = false
    @State private var feedback = ""
    @State private var numberOfPoints = 4
    
    var maxRounds: Int {
        switch difficulty {
        case .easy: return 3
        case .medium: return 5
        case .hard: return 7
        }
    }
    
    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { 
                        isPresented = false 
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("Round \(round)/\(maxRounds)")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Score: \(score)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                Text("Tap points in order")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(ThemeColors.textSecondary)
                
                if !feedback.isEmpty {
                    Text(feedback)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(feedback.contains("Correct") ? ThemeColors.primaryAccent : .red)
                }
                
                Spacer()
                
                // Points grid - changes based on difficulty
                VStack(spacing: 50) {
                    if numberOfPoints == 4 {
                        // Round 1-2: 4 points
                        VStack(spacing: 50) {
                            HStack(spacing: 70) {
                                PointButton(number: 1, isActive: userTaps.count == 0, isCompleted: userTaps.contains(0)) {
                                    handleTap(0)
                                }
                                PointButton(number: 2, isActive: userTaps.count == 1, isCompleted: userTaps.contains(1)) {
                                    handleTap(1)
                                }
                            }
                            
                            HStack(spacing: 70) {
                                PointButton(number: 3, isActive: userTaps.count == 2, isCompleted: userTaps.contains(2)) {
                                    handleTap(2)
                                }
                                PointButton(number: 4, isActive: userTaps.count == 3, isCompleted: userTaps.contains(3)) {
                                    handleTap(3)
                                }
                            }
                        }
                    } else if numberOfPoints == 6 {
                        // Round 3-4: 6 points
                        VStack(spacing: 40) {
                            HStack(spacing: 50) {
                                PointButton(number: 1, isActive: userTaps.count == 0, isCompleted: userTaps.contains(0)) {
                                    handleTap(0)
                                }
                                PointButton(number: 2, isActive: userTaps.count == 1, isCompleted: userTaps.contains(1)) {
                                    handleTap(1)
                                }
                                PointButton(number: 3, isActive: userTaps.count == 2, isCompleted: userTaps.contains(2)) {
                                    handleTap(2)
                                }
                            }
                            
                            HStack(spacing: 50) {
                                PointButton(number: 4, isActive: userTaps.count == 3, isCompleted: userTaps.contains(3)) {
                                    handleTap(3)
                                }
                                PointButton(number: 5, isActive: userTaps.count == 4, isCompleted: userTaps.contains(4)) {
                                    handleTap(4)
                                }
                                PointButton(number: 6, isActive: userTaps.count == 5, isCompleted: userTaps.contains(5)) {
                                    handleTap(5)
                                }
                            }
                        }
                    } else {
                        // Round 5: 9 points
                        VStack(spacing: 30) {
                            HStack(spacing: 40) {
                                PointButton(number: 1, isActive: userTaps.count == 0, isCompleted: userTaps.contains(0)) {
                                    handleTap(0)
                                }
                                PointButton(number: 2, isActive: userTaps.count == 1, isCompleted: userTaps.contains(1)) {
                                    handleTap(1)
                                }
                                PointButton(number: 3, isActive: userTaps.count == 2, isCompleted: userTaps.contains(2)) {
                                    handleTap(2)
                                }
                            }
                            
                            HStack(spacing: 40) {
                                PointButton(number: 4, isActive: userTaps.count == 3, isCompleted: userTaps.contains(3)) {
                                    handleTap(3)
                                }
                                PointButton(number: 5, isActive: userTaps.count == 4, isCompleted: userTaps.contains(4)) {
                                    handleTap(4)
                                }
                                PointButton(number: 6, isActive: userTaps.count == 5, isCompleted: userTaps.contains(5)) {
                                    handleTap(5)
                                }
                            }
                            
                            HStack(spacing: 40) {
                                PointButton(number: 7, isActive: userTaps.count == 6, isCompleted: userTaps.contains(6)) {
                                    handleTap(6)
                                }
                                PointButton(number: 8, isActive: userTaps.count == 7, isCompleted: userTaps.contains(7)) {
                                    handleTap(7)
                                }
                                PointButton(number: 9, isActive: userTaps.count == 8, isCompleted: userTaps.contains(8)) {
                                    handleTap(8)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                if !userTaps.isEmpty && userTaps.count < numberOfPoints {
                    GlowingButton(title: "Reset", action: {
                        userTaps.removeAll()
                        feedback = ""
                    }, isSecondary: true)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            
            if showReward {
                RewardOverlay(fragmentsEarned: max(1, min(3, score / 15))) {
                    isPresented = false
                }
            }
        }
    }
    
    private func handleTap(_ index: Int) {
        if userTaps.count == index {
            userTaps.append(index)
            score += 2
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            // Check if round complete
            if userTaps.count == numberOfPoints {
                feedback = "Perfect! ✨"
                
                let success = UINotificationFeedbackGenerator()
                success.notificationOccurred(.success)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    nextRound()
                }
            }
        } else {
            feedback = "Wrong order! Try again"
            
            let error = UINotificationFeedbackGenerator()
            error.notificationOccurred(.error)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                userTaps.removeAll()
                feedback = ""
            }
        }
    }
    
    private func nextRound() {
        round += 1
        userTaps.removeAll()
        feedback = ""
        
        if round > maxRounds {
            completeGame()
        } else {
            // Increase difficulty based on mode and round
            switch difficulty {
            case .easy:
                numberOfPoints = 4 // Always 4 points
            case .medium:
                numberOfPoints = round <= 2 ? 4 : (round <= 4 ? 6 : 9)
            case .hard:
                numberOfPoints = round <= 2 ? 6 : 9
            }
        }
    }
    
    private func completeGame() {
        let fragmentsEarned = max(1, min(3, score / 15))
        gameData.addFragments(fragmentsEarned)
        showReward = true
    }
}

struct PointButton: View {
    let number: Int
    let isActive: Bool
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                pointColor,
                                pointColor.opacity(0.3)
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 30
                        )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: pointColor.opacity(0.8), radius: isActive ? 25 : 15)
                
                Text("\(number)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .scaleEffect(isActive ? 1.15 : (isCompleted ? 1.05 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCompleted)
        }
    }
    
    private var pointColor: Color {
        if isCompleted {
            return ThemeColors.primaryAccent
        } else if isActive {
            return ThemeColors.secondaryAccent
        } else {
            return Color.white.opacity(0.3)
        }
    }
}
