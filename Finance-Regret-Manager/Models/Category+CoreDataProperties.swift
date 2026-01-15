//
//  Category+CoreDataProperties.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import Foundation
import CoreData

extension Category {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var iconName: String?
    @NSManaged public var customColor: String?
    @NSManaged public var order: Int16
    @NSManaged public var regrets: NSSet?
}

extension Category : Identifiable {
    
}
