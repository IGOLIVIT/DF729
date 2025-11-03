//
//  EchoCatchView.swift
//  DF729
//

import SwiftUI

struct EchoCatchView: View {
    @EnvironmentObject var gameData: GameDataManager
    @Binding var isPresented: Bool
    let difficulty: GameDifficulty
    
    @State private var spheres: [PulsingSphere] = []
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var gameActive = true
    @State private var showReward = false
    @State private var fragmentsEarned = 0
    @State private var countdownTimer: Timer?
    @State private var spawnTimer: Timer?
    @State private var spawnInterval: Double = 1.5
    @State private var sphereLifetime: Double = 5.0
    
    private var initialSettings: (spawn: Double, lifetime: Double) {
        switch difficulty {
        case .easy: return (2.0, 6.0)
        case .medium: return (1.5, 5.0)
        case .hard: return (1.0, 4.0)
        }
    }
    
    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { 
                        cleanup()
                        isPresented = false 
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("Time: \(timeRemaining)s")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Caught: \(score)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                Text(getDifficultyText())
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(ThemeColors.textSecondary)
                    .padding(.bottom, 20)
                
                // Game area
                ZStack {
                    ForEach(spheres) { sphere in
                        PulsingSphereView(sphere: sphere)
                            .position(sphere.position)
                            .onTapGesture {
                                catchSphere(sphere)
                            }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
            }
            
            // Reward overlay
            if showReward {
                RewardOverlay(fragmentsEarned: fragmentsEarned) {
                    isPresented = false
                }
            }
        }
        .onAppear {
            startGame()
        }
        .onDisappear {
            cleanup()
        }
    }
    
    private func getDifficultyText() -> String {
        if timeRemaining > 20 {
            return "Easy - Tap the spheres!"
        } else if timeRemaining > 10 {
            return "Medium - Getting faster!"
        } else {
            return "Hard - Quick reflexes!"
        }
    }
    
    private func startGame() {
        gameActive = true
        
        // Set initial difficulty
        spawnInterval = initialSettings.spawn
        sphereLifetime = initialSettings.lifetime
        
        // Spawn initial spheres
        spawnSphere()
        spawnSphere()
        
        // Countdown timer with difficulty increase
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.gameActive && self.timeRemaining > 0 {
                self.timeRemaining -= 1
                
                // Increase difficulty over time (except in easy mode)
                if self.difficulty != .easy {
                    if self.timeRemaining == 20 {
                        self.increaseDifficulty()
                    } else if self.timeRemaining == 10 {
                        self.increaseDifficulty()
                    }
                }
            } else if self.timeRemaining == 0 && self.gameActive {
                self.endGame()
            }
        }
        
        // Spawn timer
        startSpawnTimer()
    }
    
    private func startSpawnTimer() {
        spawnTimer?.invalidate()
        spawnTimer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: true) { _ in
            if self.gameActive {
                self.spawnSphere()
            }
        }
    }
    
    private func increaseDifficulty() {
        // Spawn faster
        spawnInterval = max(0.8, spawnInterval - 0.3)
        // Spheres disappear faster
        sphereLifetime = max(3.0, sphereLifetime - 1.0)
        
        startSpawnTimer()
        
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
    }
    
    private func cleanup() {
        gameActive = false
        countdownTimer?.invalidate()
        countdownTimer = nil
        spawnTimer?.invalidate()
        spawnTimer = nil
    }
    
    private func spawnSphere() {
        guard gameActive else { return }
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let x = CGFloat.random(in: 80...(screenWidth - 80))
        let y = CGFloat.random(in: 250...(screenHeight - 200))
        
        let sphere = PulsingSphere(position: CGPoint(x: x, y: y))
        
        DispatchQueue.main.async {
            self.spheres.append(sphere)
        }
        
        // Auto-remove based on difficulty
        DispatchQueue.main.asyncAfter(deadline: .now() + sphereLifetime) {
            self.spheres.removeAll { $0.id == sphere.id }
        }
    }
    
    private func catchSphere(_ sphere: PulsingSphere) {
        guard gameActive else { return }
        
        score += 1
        spheres.removeAll { $0.id == sphere.id }
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    private func endGame() {
        cleanup()
        spheres.removeAll()
        
        fragmentsEarned = max(1, min(3, score / 5))
        gameData.addFragments(fragmentsEarned)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                self.showReward = true
            }
        }
    }
}

struct PulsingSphere: Identifiable, Equatable {
    let id = UUID()
    let position: CGPoint
    
    static func == (lhs: PulsingSphere, rhs: PulsingSphere) -> Bool {
        lhs.id == rhs.id
    }
}

struct PulsingSphereView: View {
    let sphere: PulsingSphere
    @State private var pulse = false
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ThemeColors.primaryAccent.opacity(0.8),
                            ThemeColors.secondaryAccent.opacity(0.6),
                            ThemeColors.secondaryAccent.opacity(0.1)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 40
                    )
                )
                .frame(width: 80, height: 80)
                .scaleEffect(pulse ? 1.2 : 1.0)
                .shadow(color: ThemeColors.primaryAccent.opacity(0.6), radius: 20, x: 0, y: 0)
            
            Circle()
                .stroke(ThemeColors.primaryAccent, lineWidth: 2)
                .frame(width: 80, height: 80)
                .scaleEffect(pulse ? 1.3 : 1.0)
                .opacity(pulse ? 0.3 : 0.8)
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1.0
            }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
