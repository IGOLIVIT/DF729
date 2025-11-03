//
//  OnboardingView.swift
//  DF729
//

import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    @State private var opacity: Double = 0
    
    let pages = [
        OnboardingPage(
            icon: "moon.stars.fill",
            title: "Journey Through Midnight",
            description: "Explore the depths of an endless night where light fragments await"
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "Collect Fragments",
            description: "Each challenge reveals hidden luminous fragments scattered across pathways"
        ),
        OnboardingPage(
            icon: "wand.and.stars",
            title: "Master the Paths",
            description: "Three unique challenges test your reflexes and perception in the dark"
        )
    ]
    
    var body: some View {
        ZStack {
            // Animated background
            ThemeColors.background
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    ThemeColors.secondaryAccent.opacity(0.2),
                    ThemeColors.background,
                    ThemeColors.primaryAccent.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 500)
                
                // Page indicators
                HStack(spacing: 12) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? ThemeColors.primaryAccent : Color.white.opacity(0.3))
                            .frame(width: currentPage == index ? 10 : 8, height: currentPage == index ? 10 : 8)
                            .shadow(color: currentPage == index ? ThemeColors.primaryAccent.opacity(0.6) : .clear, radius: 8, x: 0, y: 0)
                    }
                }
                .padding(.top, 30)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                
                Spacer()
                
                // Navigation buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        GlowingButton(title: "Begin Journey") {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                showOnboarding = false
                            }
                        }
                        .transition(.opacity)
                    } else {
                        GlowingButton(title: "Continue") {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        }
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                showOnboarding = false
                            }
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(ThemeColors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 1
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var iconScale: CGFloat = 0.5
    @State private var textOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ThemeColors.primaryAccent, ThemeColors.secondaryAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: ThemeColors.primaryAccent.opacity(0.6), radius: 30, x: 0, y: 0)
                .scaleEffect(iconScale)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(ThemeColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
            .opacity(textOpacity)
        }
        .padding(.horizontal, 20)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                textOpacity = 1
            }
        }
    }
}

