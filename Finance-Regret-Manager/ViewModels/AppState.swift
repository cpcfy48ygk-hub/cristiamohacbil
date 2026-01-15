
import Foundation
import SwiftUI
import UserNotifications

@Observable
class AppState {
    var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    var selectedTheme: ThemeMode = ThemeMode(rawValue: UserDefaults.standard.string(forKey: "selectedTheme") ?? "system") ?? .system
    var monthlyReminderEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "monthlyReminderEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "monthlyReminderEnabled")
            if newValue {
                scheduleMonthlyReminder()
            } else {
                cancelMonthlyReminder()
            }
        }
    }
    
    var customStatusNames: [String: String] {
        get {
            if let data = UserDefaults.standard.data(forKey: "customStatusNames"),
               let dict = try? JSONDecoder().decode([String: String].self, from: data) {
                return dict
            }
            return [:]
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "customStatusNames")
            }
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    func setTheme(_ theme: ThemeMode) {
        selectedTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme")
    }
    
    private func scheduleMonthlyReminder() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Monthly Reflection"
                content.body = "Take a moment to reflect on your financial growth this month."
                content.sound = .default
                
                var dateComponents = DateComponents()
                dateComponents.day = 1
                dateComponents.hour = 10
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "monthlyReflection", content: content, trigger: trigger)
                
                    center.add(request) { error in
                        if let error = error {
                            ErrorHandler.logError(error, context: "scheduleMonthlyReminder", severity: .medium)
                        }
                    }
            }
        }
    }
    
    private func cancelMonthlyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["monthlyReflection"])
    }
}

enum ThemeMode: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
}
