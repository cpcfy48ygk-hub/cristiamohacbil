//
//  CategoryViewModel.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import Foundation
import CoreData
import SwiftUI

@Observable
class CategoryViewModel {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchAllCategories() -> [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.order, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            ErrorHandler.logError(error, context: "fetchAllCategories", severity: .medium)
            return []
        }
    }
    
    func createCategory(name: String, iconName: String?, customColor: String?) {
        let category = Category(context: context)
        category.id = UUID()
        category.name = name
        category.iconName = iconName
        category.customColor = customColor
        category.order = Int16(fetchAllCategories().count)
        
        save()
    }
    
    func updateCategory(_ category: Category, name: String? = nil, iconName: String? = nil, customColor: String? = nil) {
        if let name = name { category.name = name }
        if let iconName = iconName { category.iconName = iconName }
        if let customColor = customColor { category.customColor = customColor }
        
        save()
    }
    
    func deleteCategory(_ category: Category) {
        // Clear category relationship from all related regrets before deleting
        if let regrets = category.regrets as? Set<FinancialRegret> {
            for regret in regrets {
                regret.categoryRelationship = nil
                regret.category = nil // Also clear legacy string field
            }
        }
        
        // Also clear regrets that reference this category by name (backward compatibility)
        let request: NSFetchRequest<FinancialRegret> = FinancialRegret.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category.name)
        
        do {
            let regretsWithCategory = try context.fetch(request)
            for regret in regretsWithCategory {
                regret.category = nil
                regret.categoryRelationship = nil
            }
        } catch {
            ErrorHandler.logError(error, context: "deleteCategory - clear regrets", severity: .medium)
        }
        
        context.delete(category)
        save()
    }
    
    func getCategoryStats(_ categoryName: String, regrets: [FinancialRegret]) -> (count: Int, transformationRate: Double) {
        let categoryRegrets = regrets.filter { 
            $0.categoryRelationship?.name == categoryName || $0.category == categoryName 
        }
        guard !categoryRegrets.isEmpty else { return (0, 0) }
        let transformed = categoryRegrets.filter { RegretStatus.from($0.status).isTransformed }.count
        return (categoryRegrets.count, Double(transformed) / Double(categoryRegrets.count))
    }
    
    func getCategoryStats(_ category: Category, regrets: [FinancialRegret]) -> (count: Int, transformationRate: Double) {
        let categoryRegrets = regrets.filter { 
            $0.categoryRelationship == category || $0.category == category.name 
        }
        guard !categoryRegrets.isEmpty else { return (0, 0) }
        let transformed = categoryRegrets.filter { RegretStatus.from($0.status).isTransformed }.count
        return (categoryRegrets.count, Double(transformed) / Double(categoryRegrets.count))
    }
    
    private func save() {
        do {
            try context.save()
        } catch {
            ErrorHandler.handleCoreDataError(error, context: context, operation: "save category")
        }
    }
}
