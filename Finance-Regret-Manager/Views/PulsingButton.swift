//
//  PulsingButton.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI

struct PulsingButton: View {
    @State private var isPulsing = false
    
    var body: some View {
        Image(systemName: "plus")
            .font(.title2)
            .foregroundColor(.white)
            .frame(width: 64, height: 64)
            .background(AppTheme.primaryGradient)
            .clipShape(Circle())
            .shadow(color: AppTheme.deepRose.opacity(0.3), radius: 10)
            .scaleEffect(isPulsing ? 1.1 : 1.0)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
    }
}
