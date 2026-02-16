//
//  EmptyDashboardView.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI

struct EmptyDashboardView: View {
    let onAddRegret: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No reflections logged yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Tap + to start your first reflection")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button(action: onAddRegret) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create First Reflection")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(AppTheme.primaryGradient)
                .cornerRadius(AppTheme.cornerRadius)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
