//
//  OnboardingView.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var isComplete: Bool
    
    let pages = [
        OnboardingPage(
            icon: "doc.text.magnifyingglass",
            title: "A gentle space to reflect",
            description: "A gentle space to reflect on past financial choices"
        ),
        OnboardingPage(
            icon: "leaf.fill",
            title: "Turn regrets into wisdom",
            description: "Turn regrets into wisdom — privately and safely"
        ),
        OnboardingPage(
            icon: "heart.fill",
            title: "No judgments. Only growth.",
            description: "No judgments. Only growth."
        )
    ]
    
    var body: some View {
        ZStack {
            AppTheme.offWhite
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            VStack {
                Spacer()
                
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                } else {
                    withAnimation {
                        isComplete = true
                    }
                }
            }) {
                Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.primaryGradient)
                    .cornerRadius(AppTheme.cornerRadius)
                    .padding(.horizontal, AppTheme.padding)
                    .padding(.bottom, 40)
            }
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
    @State private var iconOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundColor(AppTheme.sageGreen)
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                .glow(color: AppTheme.sageGreen.opacity(0.4), radius: 30)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(AppTheme.serifFontMedium)
                    .foregroundColor(AppTheme.deepRose)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            Text("This is a private personal journal for reflection. Not medical or financial advice.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
        }
        .onAppear {
            withAnimation(AppTheme.slowAnimation) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
        }
    }
}
