//
//  PersistenceController.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        return controller
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FinancialRegretModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                // Log error but don't crash - allow app to continue
                ErrorHandler.logError(error, context: "Core Data store loading", severity: .high)
                // The app will continue but may have limited functionality
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.undoManager = nil
    }
    
    func save() throws {
        let context = container.viewContext
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            context.rollback()
            throw nsError
        }
    }
    
    func saveContext() {
        do {
            try save()
        } catch {
            ErrorHandler.logError(error, context: "PersistenceController.saveContext", severity: .high)
        }
    }
}
