//
//  ReflectionView.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI
import CoreData

struct ReflectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FinancialRegret.date, ascending: false)],
        animation: .default
    ) private var allRegrets: FetchedResults<FinancialRegret>
    
    @State private var dailyRegret: FinancialRegret?
    @State private var newInsight: String = ""
    @State private var showingSuccessMessage = false
    @State private var regretViewModel: RegretViewModel?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Daily prompt
                        dailyPromptSection
                        
                        // Random transformed regret
                        if let regret = dailyRegret {
                            dailyRegretSection(regret: regret)
                        } else {
                            EmptyReflectionView()
                        }
                        
                        // New insight
                        newInsightSection
                    }
                    .padding(AppTheme.padding)
                }
            }
            .navigationTitle("Daily Reflection")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadDailyRegret()
        }
        .onChange(of: allRegrets.count) { _, _ in
            loadDailyRegret()
        }
    }
    
    private var dailyPromptSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "sunrise.fill")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.accentColor)
                .glow(color: AppTheme.accentColor.opacity(0.4), radius: 20)
            
            Text("What would you tell your past self today?")
                .font(AppTheme.serifFontMedium)
                .foregroundColor(AppTheme.primaryTextColor)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.growthGradient)
        )
    }
    
    private func dailyRegretSection(regret: FinancialRegret) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Reflection")
                .font(AppTheme.serifFontSmall)
                .foregroundColor(AppTheme.primaryTextColor)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(regret.title)
                    .font(.headline)
                    .foregroundColor(AppTheme.primaryTextColor)
                
                Text(regret.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let lesson = regret.lessonLearned, !lesson.isEmpty {
                    Divider()
                    
                    Text(lesson)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(AppTheme.secondaryBackgroundColor)
            )
            
            Button(action: {
                loadDailyRegret()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Show Another")
                }
                .font(.subheadline)
                .foregroundColor(AppTheme.accentColor)
            }
        }
    }
    
    private var newInsightSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add New Insight")
                .font(AppTheme.serifFontSmall)
                .foregroundColor(AppTheme.primaryTextColor)
            
            TextEditor(text: $newInsight)
                .frame(minHeight: 120)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .fill(AppTheme.secondaryBackgroundColor)
                )
            
            Button(action: {
                let trimmedInsight = newInsight.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedInsight.isEmpty else { return }
                
                // Reuse viewModel instead of creating new one each time
                if regretViewModel == nil {
                    regretViewModel = RegretViewModel(context: viewContext)
                }
                
                regretViewModel?.createRegret(
                    title: "Daily Insight",
                    date: Date(),
                    category: nil,
                    description: trimmedInsight,
                    moneyImpact: nil,
                    emotionalIntensity: 5,
                    initialFeeling: nil,
                    status: RegretStatus.active.rawValue
                )
                
                newInsight = ""
                showingSuccessMessage = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showingSuccessMessage = false
                }
            }) {
                Text("Save Insight")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSaveInsight ? AppTheme.primaryGradient : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(AppTheme.cornerRadius)
            }
            .disabled(!canSaveInsight)
            .overlay {
                if showingSuccessMessage {
                    Text("Insight saved!")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .cornerRadius(16)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
    
    private var canSaveInsight: Bool {
        !newInsight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func loadDailyRegret() {
        let transformed = Array(allRegrets)
            .filter { RegretStatus.from($0.status).isTransformed }
            .filter { $0.lessonLearned != nil && !$0.lessonLearned!.isEmpty }
        
        if !transformed.isEmpty {
            dailyRegret = transformed.randomElement()
        }
    }
}
