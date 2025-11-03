//
//  GlowingButton.swift
//  DF729
//

import SwiftUI

struct GlowingButton: View {
    let title: String
    let action: () -> Void
    var color: Color = ThemeColors.primaryAccent
    var isSecondary: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    ZStack {
                        if isSecondary {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(color, lineWidth: 2)
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(color)
                                .shadow(color: color.opacity(0.5), radius: 20, x: 0, y: 0)
                        }
                    }
                )
                .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct GameCard: View {
    let game: MiniGameType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: game.icon)
                    .font(.system(size: 50))
                    .foregroundColor(ThemeColors.primaryAccent)
                    .shadow(color: ThemeColors.primaryAccent.opacity(0.6), radius: 15, x: 0, y: 0)
                
                Text(game.rawValue)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(game.description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(ThemeColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ThemeColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [ThemeColors.primaryAccent, ThemeColors.secondaryAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: ThemeColors.secondaryAccent.opacity(0.3), radius: 15, x: 0, y: 5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

