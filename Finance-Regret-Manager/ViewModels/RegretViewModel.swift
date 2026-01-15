//
//  RegretViewModel.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import Foundation
import CoreData
import SwiftUI

@Observable
class RegretViewModel {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchAllRegrets() -> [FinancialRegret] {
        let request: NSFetchRequest<FinancialRegret> = FinancialRegret.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialRegret.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            ErrorHandler.logError(error, context: "fetchAllRegrets", severity: .medium)
            return []
        }
    }
    
    func fetchRegrets(by status: String) -> [FinancialRegret] {
        let request: NSFetchRequest<FinancialRegret> = FinancialRegret.fetchRequest()
        request.predicate = NSPredicate(format: "status == %@", status)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialRegret.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            ErrorHandler.logError(error, context: "fetchRegrets(by:)", severity: .medium)
            return []
        }
    }
    
    func createRegret(
        title: String,
        date: Date,
        category: String?,
        description: String,
        moneyImpact: Double?,
        emotionalIntensity: Int,
        initialFeeling: String?,
        status: String = "Active",
        categoryObject: Category? = nil
    ) {
        let regret = FinancialRegret(context: context)
        regret.id = UUID()
        regret.title = title
        regret.date = date
        regret.descriptionText = description
        regret.moneyImpact = moneyImpact ?? 0
        regret.emotionalIntensity = Int16(emotionalIntensity)
        regret.initialFeeling = initialFeeling
        regret.status = status
        regret.lessonLearned = nil
        regret.createdAt = Date()
        regret.updatedAt = Date()
        
        // Set category relationship if provided, otherwise use string for backward compatibility
        if let categoryObject = categoryObject {
            regret.categoryRelationship = categoryObject
            regret.category = categoryObject.name
        } else if let category = category {
            regret.category = category
            // Try to find and link category object if it exists
            let categoryRequest: NSFetchRequest<Category> = Category.fetchRequest()
            categoryRequest.predicate = NSPredicate(format: "name == %@", category)
            if let foundCategory = try? context.fetch(categoryRequest).first {
                regret.categoryRelationship = foundCategory
            }
        }
        
        save()
    }
    
    func updateRegret(
        _ regret: FinancialRegret,
        title: String? = nil,
        date: Date? = nil,
        category: String? = nil,
        description: String? = nil,
        moneyImpact: Double? = nil,
        emotionalIntensity: Int? = nil,
        initialFeeling: String? = nil,
        lessonLearned: String? = nil,
        status: String? = nil,
        categoryObject: Category? = nil
    ) {
        if let title = title { regret.title = title }
        if let date = date { regret.date = date }
        if let description = description { regret.descriptionText = description }
        if let moneyImpact = moneyImpact { regret.moneyImpact = moneyImpact }
        if let emotionalIntensity = emotionalIntensity { regret.emotionalIntensity = Int16(emotionalIntensity) }
        if let initialFeeling = initialFeeling { regret.initialFeeling = initialFeeling }
        if let lessonLearned = lessonLearned { regret.lessonLearned = lessonLearned }
        if let status = status { regret.status = status }
        
        // Update category relationship
        if let categoryObject = categoryObject {
            regret.categoryRelationship = categoryObject
            regret.category = categoryObject.name
        } else if let category = category {
            regret.category = category
            // Try to find and link category object if it exists
            let categoryRequest: NSFetchRequest<Category> = Category.fetchRequest()
            categoryRequest.predicate = NSPredicate(format: "name == %@", category)
            if let foundCategory = try? context.fetch(categoryRequest).first {
                regret.categoryRelationship = foundCategory
            } else {
                regret.categoryRelationship = nil
            }
        } else {
            regret.category = nil
            regret.categoryRelationship = nil
        }
        
        regret.updatedAt = Date()
        
        save()
    }
    
    func deleteRegret(_ regret: FinancialRegret) {
        context.delete(regret)
        save()
    }
    
    func getGrowthProgress() -> Double {
        let all = fetchAllRegrets()
        guard !all.isEmpty else { return 0 }
        let transformed = all.filter { RegretStatus.from($0.status).isTransformed }.count
        return Double(transformed) / Double(all.count)
    }
    
    private func save() {
        do {
            try context.save()
        } catch {
            ErrorHandler.handleCoreDataError(error, context: context, operation: "save regret")
        }
    }
    
    func saveWithError() throws {
        try context.save()
    }
    
    // Search functionality
    func searchRegrets(query: String) -> [FinancialRegret] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return fetchAllRegrets()
        }
        
        let request: NSFetchRequest<FinancialRegret> = FinancialRegret.fetchRequest()
        let searchTerm = trimmedQuery
        
        // Search in title and description (required fields)
        let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchTerm)
        let descriptionPredicate = NSPredicate(format: "descriptionText CONTAINS[cd] %@", searchTerm)
        
        // For optional fields, use a safer approach
        var predicates: [NSPredicate] = [titlePredicate, descriptionPredicate]
        
        // Add optional field predicates only if they might contain data
        let feelingPredicate = NSPredicate(format: "initialFeeling CONTAINS[cd] %@", searchTerm)
        let lessonPredicate = NSPredicate(format: "lessonLearned CONTAINS[cd] %@", searchTerm)
        predicates.append(contentsOf: [feelingPredicate, lessonPredicate])
        
        request.predicate = NSCompoundPredicate(type: .or, subpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialRegret.date, ascending: false)]
        
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            ErrorHandler.logError(error, context: "searchRegrets", severity: .medium)
            return []
        }
    }
    
    func searchRegrets(query: String, in category: Category) -> [FinancialRegret] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return fetchRegrets(by: category)
        }
        
        let request: NSFetchRequest<FinancialRegret> = FinancialRegret.fetchRequest()
        let searchTerm = trimmedQuery
        
        let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchTerm)
        let descriptionPredicate = NSPredicate(format: "descriptionText CONTAINS[cd] %@", searchTerm)
        let feelingPredicate = NSPredicate(format: "initialFeeling CONTAINS[cd] %@", searchTerm)
        let lessonPredicate = NSPredicate(format: "lessonLearned CONTAINS[cd] %@", searchTerm)
        
        let searchPredicate = NSCompoundPredicate(
            type: .or,
            subpredicates: [titlePredicate, descriptionPredicate, feelingPredicate, lessonPredicate]
        )
        
        let categoryPredicate = NSPredicate(format: "categoryRelationship == %@ OR category == %@", category, category.name)
        
        request.predicate = NSCompoundPredicate(
            type: .and,
            subpredicates: [searchPredicate, categoryPredicate]
        )
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialRegret.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            ErrorHandler.logError(error, context: "searchRegrets in category", severity: .medium)
            return []
        }
    }
    
    func fetchRegrets(by category: Category) -> [FinancialRegret] {
        let request: NSFetchRequest<FinancialRegret> = FinancialRegret.fetchRequest()
        request.predicate = NSPredicate(format: "categoryRelationship == %@ OR category == %@", category, category.name)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialRegret.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            ErrorHandler.logError(error, context: "fetchRegrets(by: Category)", severity: .medium)
            return []
        }
    }
}
