//
//  TimelineView.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI
import CoreData

struct TimelineView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FinancialRegret.date, ascending: false)],
        animation: .default
    ) private var allRegrets: FetchedResults<FinancialRegret>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.order, ascending: true)],
        animation: .default
    ) private var categories: FetchedResults<Category>
    
    @State private var selectedFilter: FilterType = .all
    @State private var selectedCategory: String? = nil
    @State private var showingCategoryPicker = false
    @State private var searchText = ""
    
    enum FilterType: String, CaseIterable {
        case all = "All"
        case year = "This Year"
        case category = "By Category"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(FilterType.allCases, id: \.self) { filter in
                                FilterChip(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter
                                ) {
                                    selectedFilter = filter
                                    if filter == .category && selectedCategory == nil {
                                        showingCategoryPicker = true
                                    }
                                }
                            }
                            
                            if selectedFilter == .category {
                                if let category = selectedCategory {
                                    Button(action: {
                                        showingCategoryPicker = true
                                    }) {
                                        HStack(spacing: 4) {
                                            Text(category)
                                                .font(.caption)
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption2)
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.sageGreen)
                                        .cornerRadius(16)
                                    }
                                } else {
                                    Button(action: {
                                        showingCategoryPicker = true
                                    }) {
                                        Text("Select Category")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.deepRose)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(AppTheme.warmBeige.opacity(0.5))
                                            .cornerRadius(16)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.padding)
                        .padding(.vertical, 12)
                    }
                    
                    // Timeline
                    ScrollView {
                        VStack(spacing: 0) {
                            let filteredRegrets = getFilteredRegrets()
                            
                            if filteredRegrets.isEmpty {
                                EmptyTimelineView(filterType: selectedFilter)
                                    .padding(.top, 60)
                            } else {
                                ForEach(Array(filteredRegrets.enumerated()), id: \.element.id) { index, regret in
                                    TimelineItemView(regret: regret, isLast: index == filteredRegrets.count - 1)
                                        .padding(.horizontal, AppTheme.padding)
                                        .padding(.vertical, 8)
                                }
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("Timeline")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search timeline...")
            .sheet(isPresented: $showingCategoryPicker) {
                CategorySelectionView(
                    categories: Array(categories),
                    selectedCategory: $selectedCategory
                )
            }
        }
    }
    
    private func getFilteredRegrets() -> [FinancialRegret] {
        var filtered: [FinancialRegret]
        let all = Array(allRegrets)
        
        switch selectedFilter {
        case .all:
            filtered = all
        case .year:
            let calendar = Calendar.current
            filtered = all.filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .year) }
        case .category:
            if let category = selectedCategory {
                filtered = all.filter { 
                    $0.categoryRelationship?.name == category || $0.category == category 
                }
            } else {
                filtered = []
            }
        }
        
        // Apply search if search text is provided
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearchText.isEmpty {
            let viewModel = RegretViewModel(context: viewContext)
            let searchResults = viewModel.searchRegrets(query: trimmedSearchText)
            // Intersect filtered results with search results
            let searchResultIds = Set(searchResults.map { $0.id })
            filtered = filtered.filter { searchResultIds.contains($0.id) }
        }
        
        return filtered
    }
}

struct EmptyTimelineView: View {
    let filterType: TimelineView.FilterType
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No reflections found")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(emptyStateMessage)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private var emptyStateMessage: String {
        switch filterType {
        case .all:
            return "Start adding reflections to see them here"
        case .year:
            return "No reflections for this year yet"
        case .category:
            return "No reflections in this category yet"
        }
    }
}

struct CategorySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    let categories: [Category]
    @Binding var selectedCategory: String?
    
    var body: some View {
        NavigationStack {
            List {
                Button(action: {
                    selectedCategory = nil
                    dismiss()
                }) {
                    HStack {
                        Text("All Categories")
                        Spacer()
                        if selectedCategory == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppTheme.sageGreen)
                        }
                    }
                }
                
                ForEach(categories) { category in
                    Button(action: {
                        selectedCategory = category.name
                        dismiss()
                    }) {
                        HStack {
                            if let iconName = category.iconName {
                                Image(systemName: iconName)
                                    .foregroundColor(categoryColor(category))
                            }
                            Text(category.name)
                            Spacer()
                            if selectedCategory == category.name {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.sageGreen)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func categoryColor(_ category: Category) -> Color {
        if let colorHex = category.customColor {
            return Color(hex: colorHex)
        }
        return AppTheme.sageGreen
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(isSelected ? .white : AppTheme.deepRose)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppTheme.primaryGradient)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppTheme.warmBeige.opacity(0.5))
                        }
                    }
                )
        }
    }
}

struct TimelineItemView: View {
    let regret: FinancialRegret
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline dot and line
            VStack(spacing: 0) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.offWhite, lineWidth: 3)
                    )
                
                if !isLast {
                    Rectangle()
                        .fill(statusColor.opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 16)
            
            // Content card
            VStack(alignment: .leading, spacing: 8) {
                Text(regret.title)
                    .font(.headline)
                    .foregroundColor(AppTheme.deepRose)
                
                Text(regret.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let category = regret.categoryName {
                    Text(category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                StatusBadge(status: regret.status)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(AppTheme.secondaryBackgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppTheme.borderColor, lineWidth: 1)
            )
        }
    }
    
    private var statusColor: Color {
        let statusEnum = RegretStatus.allCases.first { $0.rawValue == regret.status } ?? .active
        return Color(hex: statusEnum.color)
    }
}
