//
//  EmptyReflectionView.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI

struct EmptyReflectionView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No transformed reflections yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add lessons to your reflections to see daily reflections here")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.warmBeige.opacity(0.3))
        )
    }
}
