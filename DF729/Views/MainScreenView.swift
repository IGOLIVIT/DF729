//
//  MainScreenView.swift
//  DF729
//

import SwiftUI

struct MainScreenView: View {
    @EnvironmentObject var gameData: GameDataManager
    @State private var selectedGame: MiniGameType? = nil
    @State private var showDifficultySelection = false
    @State private var selectedDifficulty: GameDifficulty? = nil
    @State private var showSettings = false
    @State private var fragmentsAnimation = false
    
    var body: some View {
        ZStack {
            // Background
            ThemeColors.background
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    ThemeColors.secondaryAccent.opacity(0.15),
                    ThemeColors.background,
                    ThemeColors.primaryAccent.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header with fragments counter
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Fragments Collected")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(ThemeColors.textSecondary)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 24))
                                    .foregroundColor(ThemeColors.primaryAccent)
                                    .shadow(color: ThemeColors.primaryAccent.opacity(0.6), radius: 10, x: 0, y: 0)
                                    .scaleEffect(fragmentsAnimation ? 1.2 : 1.0)
                                
                                Text("\(gameData.totalFragments)")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundColor(ThemeColors.textSecondary)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(ThemeColors.cardBackground)
                                        .overlay(
                                            Circle()
                                                .stroke(ThemeColors.secondaryAccent.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    
                    // Mini games section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Pathways")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 20) {
                            ForEach(MiniGameType.allCases, id: \.self) { game in
                                GameCard(game: game) {
                                    selectedGame = game
                                    showDifficultySelection = true
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            
            // Difficulty selection
            if showDifficultySelection, let game = selectedGame {
                DifficultySelectionView(
                    gameType: game,
                    isPresented: $showDifficultySelection,
                    selectedDifficulty: $selectedDifficulty
                )
            }
            
            // Full screen navigation
            if let game = selectedGame, let difficulty = selectedDifficulty {
                NavigationDestination(
                    game: game,
                    difficulty: difficulty,
                    isPresented: Binding(
                        get: { selectedGame != nil && selectedDifficulty != nil },
                        set: { if !$0 { 
                            selectedGame = nil
                            selectedDifficulty = nil
                        } }
                    ))
                .environmentObject(gameData)
            }
            
            if showSettings {
                SettingsView(isPresented: $showSettings)
                    .environmentObject(gameData)
            }
        }
        .onChange(of: gameData.totalFragments) { _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                fragmentsAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    fragmentsAnimation = false
                }
            }
        }
    }
}

struct NavigationDestination: View {
    @EnvironmentObject var gameData: GameDataManager
    let game: MiniGameType
    let difficulty: GameDifficulty
    @Binding var isPresented: Bool
    @State private var slideIn = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissView()
                }
            
            Group {
                switch game {
                case .echoCatch:
                    EchoCatchView(isPresented: $isPresented, difficulty: difficulty)
                        .environmentObject(gameData)
                case .pathAlign:
                    PathAlignView(isPresented: $isPresented, difficulty: difficulty)
                        .environmentObject(gameData)
                case .shadowShift:
                    ShadowShiftView(isPresented: $isPresented, difficulty: difficulty)
                        .environmentObject(gameData)
                }
            }
            .offset(y: slideIn ? 0 : UIScreen.main.bounds.height)
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

