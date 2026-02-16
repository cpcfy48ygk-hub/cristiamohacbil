//
//  EmptyCategoriesView.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI

struct EmptyCategoriesView: View {
    let onCreateCategory: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No categories yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Create your first category to organize reflections")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: onCreateCategory) {
                Text("Create Category")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(AppTheme.primaryGradient)
                    .cornerRadius(AppTheme.cornerRadius)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
