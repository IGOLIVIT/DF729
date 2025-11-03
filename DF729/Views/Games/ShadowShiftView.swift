//
//  ShadowShiftView.swift
//  DF729
//

import SwiftUI
import Combine

struct ShadowShiftView: View {
    @EnvironmentObject var gameData: GameDataManager
    @Binding var isPresented: Bool
    let difficulty: GameDifficulty
    
    @State private var playerX: CGFloat = UIScreen.main.bounds.width / 2
    @State private var obstacles: [MovingObstacle] = []
    @State private var score = 0
    @State private var gameActive = true
    @State private var showReward = false
    @State private var fragmentsEarned = 0
    @State private var gameOver = false
    @State private var obstacleSpeed: CGFloat = 3
    @State private var spawnInterval: Double = 1.5
    
    private var initialSpeed: CGFloat {
        switch difficulty {
        case .easy: return 2.5
        case .medium: return 3.5
        case .hard: return 5.0
        }
    }
    
    private var maxSpeed: CGFloat {
        switch difficulty {
        case .easy: return 5.0
        case .medium: return 7.0
        case .hard: return 10.0
        }
    }
    
    let obstacleTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    let moveTimer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("Survived: \(score)s")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(getDifficultyText())
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // Game instructions
                Text("Tap left or right side to dodge!")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(ThemeColors.textSecondary)
                    .padding(.bottom, 20)
                
                // Game area
                ZStack {
                    // Player
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    ThemeColors.primaryAccent,
                                    ThemeColors.primaryAccent.opacity(0.6)
                                ],
                                center: .center,
                                startRadius: 5,
                                endRadius: 25
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: ThemeColors.primaryAccent.opacity(0.8), radius: 15, x: 0, y: 0)
                        .position(x: playerX, y: UIScreen.main.bounds.height - 250)
                    
                    // Obstacles
                    ForEach(obstacles) { obstacle in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        ThemeColors.secondaryAccent.opacity(0.8),
                                        ThemeColors.secondaryAccent.opacity(0.4)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: ThemeColors.secondaryAccent.opacity(0.6), radius: 10, x: 0, y: 0)
                            .position(obstacle.position)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            handleTap(at: value.location)
                        }
                )
                
                Spacer()
            }
            
            // Reward overlay
            if showReward {
                RewardOverlay(fragmentsEarned: fragmentsEarned) {
                    isPresented = false
                }
            }
        }
        .onReceive(obstacleTimer) { _ in
            if gameActive {
                spawnObstacle()
            }
        }
        .onReceive(moveTimer) { _ in
            if gameActive {
                updateObstacles()
                checkCollisions()
            }
        }
        .onAppear {
            startScoreTimer()
        }
    }
    
    private func getDifficultyText() -> String {
        if score < 10 {
            return "Level 1"
        } else if score < 20 {
            return "Level 2 - Faster!"
        } else if score < 30 {
            return "Level 3 - Even faster!"
        } else {
            return "Level 4 - Maximum!"
        }
    }
    
    private func handleTap(at location: CGPoint) {
        guard gameActive else { return }
        
        let screenWidth = UIScreen.main.bounds.width
        let moveAmount: CGFloat = 100
        
        if location.x < screenWidth / 2 {
            // Tap on left side - move left
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                playerX = max(50, playerX - moveAmount)
            }
        } else {
            // Tap on right side - move right
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                playerX = min(screenWidth - 50, playerX + moveAmount)
            }
        }
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    private func spawnObstacle() {
        let screenWidth = UIScreen.main.bounds.width
        let x = CGFloat.random(in: 50...(screenWidth - 50))
        
        let obstacle = MovingObstacle(position: CGPoint(x: x, y: 100))
        obstacles.append(obstacle)
    }
    
    private func updateObstacles() {
        for index in obstacles.indices {
            obstacles[index].position.y += obstacleSpeed
        }
        
        // Remove off-screen obstacles
        obstacles.removeAll { $0.position.y > UIScreen.main.bounds.height }
    }
    
    private func checkCollisions() {
        let playerY = UIScreen.main.bounds.height - 250
        
        let playerRect = CGRect(
            x: playerX - 25,
            y: playerY - 25,
            width: 50,
            height: 50
        )
        
        for obstacle in obstacles {
            let obstacleRect = CGRect(
                x: obstacle.position.x - 30,
                y: obstacle.position.y - 30,
                width: 60,
                height: 60
            )
            
            if playerRect.intersects(obstacleRect) && !gameOver {
                endGame()
                return
            }
        }
    }
    
    private func startScoreTimer() {
        obstacleSpeed = initialSpeed
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if gameActive {
                score += 1
                
                // Increase difficulty every 10 seconds
                if score % 10 == 0 {
                    obstacleSpeed = min(maxSpeed, obstacleSpeed + 1)
                    
                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                    impact.impactOccurred()
                }
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func endGame() {
        gameActive = false
        gameOver = true
        obstacles.removeAll()
        
        let errorFeedback = UINotificationFeedbackGenerator()
        errorFeedback.notificationOccurred(.error)
        
        fragmentsEarned = max(1, min(3, score / 10))
        gameData.addFragments(fragmentsEarned)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showReward = true
            }
        }
    }
}

struct MovingObstacle: Identifiable {
    let id = UUID()
    var position: CGPoint
}
