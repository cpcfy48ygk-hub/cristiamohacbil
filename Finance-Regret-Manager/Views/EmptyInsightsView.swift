//
//  EmptyInsightsView.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI

struct EmptyInsightsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No insights yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add reflections and transform them into lessons to see insights here")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
