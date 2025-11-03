//
//  GameData.swift
//  DF729
//

import Foundation
import SwiftUI
import Combine

// MARK: - Game Data Manager
class GameDataManager: ObservableObject {
    @Published var totalFragments: Int {
        didSet {
            UserDefaults.standard.set(totalFragments, forKey: "totalFragments")
        }
    }
    @Published var totalGamesPlayed: Int {
        didSet {
            UserDefaults.standard.set(totalGamesPlayed, forKey: "totalGamesPlayed")
        }
    }
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    init() {
        self.totalFragments = UserDefaults.standard.integer(forKey: "totalFragments")
        self.totalGamesPlayed = UserDefaults.standard.integer(forKey: "totalGamesPlayed")
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func addFragments(_ count: Int) {
        totalFragments += count
        totalGamesPlayed += 1
    }
    
    func resetProgress() {
        totalFragments = 0
        totalGamesPlayed = 0
    }
}

// MARK: - Mini Game Types
enum MiniGameType: String, CaseIterable {
    case echoCatch = "Echo Catch"
    case pathAlign = "Path Align"
    case shadowShift = "Shadow Shift"
    
    var description: String {
        switch self {
        case .echoCatch:
            return "Tap to catch pulsing light spheres"
        case .pathAlign:
            return "Connect luminous points to match a pattern"
        case .shadowShift:
            return "Avoid moving shadow blocks"
        }
    }
    
    var icon: String {
        switch self {
        case .echoCatch:
            return "circle.circle"
        case .pathAlign:
            return "line.3.crossed.swirl.circle"
        case .shadowShift:
            return "square.3.layers.3d"
        }
    }
}

