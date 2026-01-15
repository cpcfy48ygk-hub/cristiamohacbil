//
//  CategoryPickerView.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI
import CoreData

struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: String?
    let categories: [Category]
    
    var body: some View {
        List {
            Button(action: {
                selectedCategory = nil
                dismiss()
            }) {
                HStack {
                    Text("None")
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
    }
    
    private func categoryColor(_ category: Category) -> Color {
        if let colorHex = category.customColor {
            return Color(hex: colorHex)
        }
        return AppTheme.sageGreen
    }
}
