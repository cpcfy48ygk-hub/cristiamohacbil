//
//  SplashScreen.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI

struct SplashScreen: View {
    @State private var paperScale: CGFloat = 0.8
    @State private var paperRotation: Double = -15
    @State private var leafOpacity: Double = 0
    @State private var leafScale: CGFloat = 0.3
    @State private var textOpacity: Double = 0
    @State private var isComplete = false
    
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            AppTheme.offWhite
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Crumpled paper → leaf animation
                ZStack {
                    // Paper
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppTheme.deepRose.opacity(0.3))
                        .scaleEffect(paperScale)
                        .rotationEffect(.degrees(paperRotation))
                        .opacity(leafOpacity < 0.5 ? 1 : 0)
                    
                    // Leaf
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppTheme.sageGreen)
                        .scaleEffect(leafScale)
                        .opacity(leafOpacity)
                        .glow(color: AppTheme.sageGreen.opacity(0.6), radius: 20)
                }
                .frame(height: 120)
                
                // App name
                Text("Financial Regret Manager")
                    .font(AppTheme.serifFont)
                    .foregroundColor(AppTheme.deepRose)
                    .opacity(textOpacity)
                
                Text("This is a private personal journal for reflection. Not medical or financial advice.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(textOpacity * 0.7)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                paperScale = 1.0
                paperRotation = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 1.2)) {
                    leafOpacity = 1.0
                    leafScale = 1.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
                withAnimation(.easeIn(duration: 0.8)) {
                    textOpacity = 1.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                isComplete = true
                onComplete()
            }
        }
    }
}

extension View {
    func glow(color: Color, radius: CGFloat) -> some View {
        self
            .shadow(color: color, radius: radius)
            .shadow(color: color, radius: radius)
    }
}
