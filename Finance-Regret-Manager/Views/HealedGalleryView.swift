//
//  HealedGalleryView.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI
import CoreData

struct HealedGalleryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FinancialRegret.date, ascending: false)],
        animation: .default
    ) private var allRegrets: FetchedResults<FinancialRegret>
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                let healedRegrets = Array(allRegrets)
                    .filter { RegretStatus.from($0.status).isTransformed }
                
                if healedRegrets.isEmpty {
                    EmptyHealedGalleryView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(healedRegrets) { regret in
                                HealedCard(regret: regret)
                            }
                        }
                        .padding(AppTheme.padding)
                    }
                }
            }
            .navigationTitle("Healed Gallery")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct HealedCard: View {
    let regret: FinancialRegret
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Before/After
            VStack(alignment: .leading, spacing: 8) {
                Text("Before")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text(regret.title)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.primaryTextColor.opacity(0.7))
                    .lineLimit(2)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.deepRose.opacity(0.1))
            )
            
            Image(systemName: "arrow.down")
                .foregroundColor(AppTheme.sageGreen)
                .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("After")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                if let lesson = regret.lessonLearned, !lesson.isEmpty {
                    Text(lesson)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.accentColor)
                        .lineLimit(4)
                } else {
                    Text("Lesson learned")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.accentColor.opacity(0.7))
                        .italic()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.accentColor.opacity(0.1))
            )
            
            Text(regret.date, style: .date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.cardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.accentColor.opacity(0.3), lineWidth: 2)
        )
        .glow(color: AppTheme.accentColor.opacity(0.2), radius: 10)
        .scaleEffect(isAnimating ? 1.0 : 0.95)
        .opacity(isAnimating ? 1.0 : 0.8)
        .onAppear {
            withAnimation(AppTheme.mediumAnimation.delay(Double.random(in: 0...0.5))) {
                isAnimating = true
            }
        }
    }
}
