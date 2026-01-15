
//
//  Finance_Regret_ManagerApp.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI
import CoreData

@main
struct Finance_Regret_ManagerApp: App {
    let persistenceController = PersistenceController.shared
    @State private var appState = AppState()
    @State private var showSplash = true
    @State private var showOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreen {
                        showSplash = false
                        if !appState.hasCompletedOnboarding {
                            showOnboarding = true
                        }
                    }
                } else if showOnboarding {
                    OnboardingView(isComplete: Binding(
                        get: { !showOnboarding },
                        set: { completed in
                            if completed {
                                appState.completeOnboarding()
                                showOnboarding = false
                            }
                        }
                    ))
                } else {
                    MainTabView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
            }
        }
    }
}
