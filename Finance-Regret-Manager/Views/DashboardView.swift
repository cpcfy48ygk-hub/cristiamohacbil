//
//  DashboardView.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FinancialRegret.date, ascending: false)],
        animation: .default
    ) private var allRegrets: FetchedResults<FinancialRegret>
    
    @State private var selectedRegret: FinancialRegret?
    @State private var showingNewReflection = false
    @State private var searchText = ""
    
    private var displayedRegrets: [FinancialRegret] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedSearch.isEmpty {
            return Array(allRegrets.prefix(5))
        } else {
            let viewModel = RegretViewModel(context: viewContext)
            let results = viewModel.searchRegrets(query: trimmedSearch)
            return results
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Progress circle
                        progressSection
                        
                        // Recent regrets
                        recentRegretsSection
                    }
                    .padding(AppTheme.padding)
                    
                    Text("This is a private personal journal for reflection. Not medical or financial advice.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.padding)
                        .padding(.bottom, 100)
                }
                
                // Floating add button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: RegretFormView(
                            context: viewContext,
                            regret: nil,
                            onSave: {}
                        )) {
                            PulsingButton()
                        }
                        .padding(.trailing, AppTheme.padding)
                        .padding(.bottom, AppTheme.padding)
                    }
                }
            }
            .navigationTitle("Financial Regret Manager")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search reflections...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        NavigationLink("Categories") {
                            CategoriesView()
                        }
                        NavigationLink("Healed Gallery") {
                            HealedGalleryView()
                        }
                        NavigationLink("Export") {
                            ExportView(context: viewContext)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .navigationDestination(item: $selectedRegret) { regret in
                RegretDetailView(regret: regret, context: viewContext)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(allRegrets.count) financial regrets logged")
                .font(AppTheme.serifFontSmall)
                .foregroundColor(AppTheme.primaryTextColor.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var progressSection: some View {
        VStack(spacing: 16) {
            let progress = getGrowthProgress()
            let percentage = Int(progress * 100)
            
            ZStack {
                Circle()
                    .stroke(Color(light: AppTheme.lightGray, dark: AppTheme.lightGrayDark), lineWidth: 12)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AppTheme.primaryGradient,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(AppTheme.slowAnimation, value: progress)
                
                VStack(spacing: 4) {
                    Text("\(percentage)%")
                        .font(AppTheme.serifFont)
                        .foregroundColor(AppTheme.primaryTextColor)
                    Text("turned into lessons")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    private var recentRegretsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Recent Reflections" : "Search Results")
                .font(AppTheme.serifFontSmall)
                .foregroundColor(AppTheme.primaryTextColor)
            
            if displayedRegrets.isEmpty {
                if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    NavigationLink(destination: RegretFormView(
                        context: viewContext,
                        regret: nil,
                        onSave: {}
                    )) {
                        EmptyDashboardView {
                            // Empty action - navigation handled by NavigationLink
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("No results found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Try a different search term")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            } else {
                ForEach(displayedRegrets) { regret in
                    RegretCard(regret: regret)
                        .onTapGesture {
                            selectedRegret = regret
                        }
                }
            }
        }
    }
    
    private func getGrowthProgress() -> Double {
        guard !allRegrets.isEmpty else { return 0 }
        let transformed = allRegrets.filter { RegretStatus.from($0.status).isTransformed }.count
        return Double(transformed) / Double(allRegrets.count)
    }
}

struct RegretCard: View {
    let regret: FinancialRegret
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(regret.title)
                    .font(.headline)
                    .foregroundColor(AppTheme.primaryTextColor)
                
                Spacer()
                
                StatusBadge(status: regret.status)
            }
            
            if let category = regret.categoryName {
                Text(category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(regret.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.cardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.borderColor, lineWidth: 1)
        )
        .scaleEffect(isAnimating ? 1.02 : 1.0)
        .onAppear {
            withAnimation(AppTheme.mediumAnimation.delay(Double.random(in: 0...0.3))) {
                isAnimating = true
            }
        }
    }
}

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        let statusEnum = RegretStatus.allCases.first { $0.rawValue == status } ?? .active
        
        HStack(spacing: 4) {
            Image(systemName: statusEnum.icon)
                .font(.caption2)
            Text(status)
                .font(.caption)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(hex: statusEnum.color))
        .cornerRadius(12)
    }
}
