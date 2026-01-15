//
//  CategoriesView.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI
import CoreData

struct CategoriesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.order, ascending: true)],
        animation: .default
    ) private var categories: FetchedResults<Category>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FinancialRegret.date, ascending: false)],
        animation: .default
    ) private var allRegrets: FetchedResults<FinancialRegret>
    
    @State private var showingAddCategory = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                if categories.isEmpty {
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
                        
                        Button(action: {
                            showingAddCategory = true
                        }) {
                            Text("Create Category")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(AppTheme.primaryGradient)
                                .cornerRadius(AppTheme.cornerRadius)
                        }
                    }
                } else {
                    List {
                        ForEach(categories) { category in
                            CategoryRowView(
                                category: category,
                                stats: getCategoryStats(category.name)
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .onDelete { indexSet in
                            let categoryViewModel = CategoryViewModel(context: viewContext)
                            for index in indexSet {
                                categoryViewModel.deleteCategory(categories[index])
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddCategory = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView(context: viewContext)
            }
        }
    }
    
    private func getCategoryStats(_ categoryName: String) -> (count: Int, transformationRate: Double) {
        let categoryRegrets = Array(allRegrets).filter { 
            $0.categoryRelationship?.name == categoryName || $0.category == categoryName 
        }
        guard !categoryRegrets.isEmpty else { return (0, 0) }
        let transformed = categoryRegrets.filter { RegretStatus.from($0.status).isTransformed }.count
        return (categoryRegrets.count, Double(transformed) / Double(categoryRegrets.count))
    }
}

struct CategoryRowView: View {
    let category: Category
    let stats: (count: Int, transformationRate: Double)
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: category.iconName ?? "folder.fill")
                    .foregroundColor(categoryColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                    .foregroundColor(AppTheme.primaryTextColor)
                
                Text("\(stats.count) reflections")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if stats.count > 0 {
                    HStack(spacing: 4) {
                        Text("\(Int(stats.transformationRate * 100))%")
                            .font(.caption)
                            .foregroundColor(AppTheme.accentColor)
                        Text("transformation rate")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.secondaryBackgroundColor)
        )
        .padding(.vertical, 4)
    }
    
    private var categoryColor: Color {
        if let colorHex = category.customColor {
            return Color(hex: colorHex)
        }
        return AppTheme.sageGreen
    }
}

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    let context: NSManagedObjectContext
    
    @State private var categoryViewModel: CategoryViewModel
    @State private var name: String = ""
    @State private var selectedIcon: String = "folder.fill"
    @State private var selectedColor: String = "#A8CABA"
    
    let availableIcons = ["folder.fill", "creditcard.fill", "cart.fill", "house.fill", "car.fill", "heart.fill", "star.fill", "tag.fill"]
    let availableColors = ["#A8CABA", "#C94B6C", "#E8A87C", "#6B8E7F", "#F5F0E1"]
    
    init(context: NSManagedObjectContext) {
        self.context = context
        _categoryViewModel = State(initialValue: CategoryViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Category Name", text: $name)
                    } header: {
                        Text("Name")
                    }
                    
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    Button(action: {
                                        selectedIcon = icon
                                    }) {
                                        let isSelected = selectedIcon == icon
                                        Image(systemName: icon)
                                            .font(.title2)
                                            .foregroundColor(isSelected ? .white : AppTheme.primaryTextColor)
                                            .frame(width: 50, height: 50)
                                            .background(
                                                Group {
                                                    if isSelected {
                                                        Circle()
                                                            .fill(AppTheme.primaryGradient)
                                                    } else {
                                                        Circle()
                                                            .fill(AppTheme.secondaryBackgroundColor)
                                                    }
                                                }
                                            )
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    } header: {
                        Text("Icon")
                    }
                    
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(availableColors, id: \.self) { colorHex in
                                    Button(action: {
                                        selectedColor = colorHex
                                    }) {
                                        Circle()
                                            .fill(Color(hex: colorHex))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(selectedColor == colorHex ? AppTheme.deepRose : Color.clear, lineWidth: 3)
                                            )
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    } header: {
                        Text("Color")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedName.isEmpty && trimmedName.count <= 50 else { return }
                        categoryViewModel.createCategory(
                            name: trimmedName,
                            iconName: selectedIcon,
                            customColor: selectedColor
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || name.count > 50)
                }
            }
        }
    }
}
