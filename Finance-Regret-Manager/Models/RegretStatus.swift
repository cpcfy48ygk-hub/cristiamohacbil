//
//  RegretStatus.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import Foundation

enum RegretStatus: String, CaseIterable, Identifiable {
    case active = "Active"
    case healing = "Healing"
    case healed = "Healed"
    case accepted = "Accepted"
    
    var id: String { rawValue }
    
    var color: String {
        switch self {
        case .active: return "#C94B6C"
        case .healing: return "#E8A87C"
        case .healed: return "#A8CABA"
        case .accepted: return "#6B8E7F"
        }
    }
    
    var icon: String {
        switch self {
        case .active: return "exclamationmark.circle.fill"
        case .healing: return "leaf.fill"
        case .healed: return "checkmark.circle.fill"
        case .accepted: return "heart.fill"
        }
    }
    
    /// Returns true if the status represents a transformed/complete state
    var isTransformed: Bool {
        return self == .healed || self == .accepted
    }
    
    /// Helper to get status from string, with fallback to active
    static func from(_ string: String?) -> RegretStatus {
        guard let string = string else { return .active }
        return RegretStatus(rawValue: string) ?? .active
    }
}
