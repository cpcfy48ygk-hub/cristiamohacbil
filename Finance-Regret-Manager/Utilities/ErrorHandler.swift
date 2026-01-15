//
//  ErrorHandler.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import Foundation
import CoreData
import OSLog

/// Centralized error handling for the application
struct ErrorHandler {
    private static let logger = Logger(subsystem: "com.financialregretmanager", category: "ErrorHandler")
    
    /// Logs an error with appropriate level and context
    static func logError(_ error: Error, context: String, severity: ErrorSeverity = .medium) {
        let errorMessage = "\(context): \(error.localizedDescription)"
        
        switch severity {
        case .low:
            logger.debug("\(errorMessage)")
        case .medium:
            logger.error("\(errorMessage)")
        case .high:
            logger.critical("\(errorMessage)")
        }
        
        // In production, you might want to send to crash reporting service
        #if DEBUG
        print("⚠️ \(errorMessage)")
        #endif
    }
    
    /// Handles Core Data errors with rollback
    static func handleCoreDataError(_ error: Error, context: NSManagedObjectContext, operation: String) {
        logError(error, context: "Core Data \(operation)", severity: .high)
        context.rollback()
    }
    
    /// Creates a user-friendly error message
    static func userFriendlyMessage(for error: Error) -> String {
        if let nsError = error as NSError? {
            switch nsError.domain {
            case NSCocoaErrorDomain:
                // Core Data validation error codes
                let validationErrorRange = 1550..<1600
                if validationErrorRange.contains(nsError.code) {
                    switch nsError.code {
                    case NSValidationErrorMinimum:
                        return "The value is too small. Please check your input."
                    case NSValidationErrorMaximum:
                        return "The value is too large. Please check your input."
                    case 1560: // NSValidationStringTooLongError
                        return "The text is too long. Please shorten it."
                    case 1561: // NSValidationStringTooShortError
                        return "The text is too short. Please provide more information."
                    default:
                        return "Validation error. Please check your input."
                    }
                }
                // Core Data persistent store error codes
                switch nsError.code {
                case NSPersistentStoreInvalidTypeError, NSPersistentStoreOperationError:
                    return "Unable to save data. Please try again."
                default:
                    return "Unable to save data. Please try again."
                }
            default:
                return "An error occurred: \(error.localizedDescription)"
            }
        }
        return "An unexpected error occurred. Please try again."
    }
}

enum ErrorSeverity {
    case low
    case medium
    case high
}
