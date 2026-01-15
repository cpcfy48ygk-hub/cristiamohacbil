//
//  FinancialRegret+CoreDataProperties.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import Foundation
import CoreData

extension FinancialRegret {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FinancialRegret> {
        return NSFetchRequest<FinancialRegret>(entityName: "FinancialRegret")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var date: Date
    @NSManaged public var category: String? // Legacy field for backward compatibility
    @NSManaged public var descriptionText: String
    @NSManaged public var moneyImpact: Double
    @NSManaged public var emotionalIntensity: Int16
    @NSManaged public var initialFeeling: String?
    @NSManaged public var lessonLearned: String?
    @NSManaged public var status: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var categoryRelationship: Category?
}

extension FinancialRegret : Identifiable {
    /// Returns the category name, preferring the relationship over the legacy string field
    var categoryName: String? {
        return categoryRelationship?.name ?? category
    }
}
