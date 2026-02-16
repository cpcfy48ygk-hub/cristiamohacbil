

import SwiftUI
import CoreData

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var appState = AppState()
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            
            TimelineView()
                .tabItem {
                    Label("Timeline", systemImage: "calendar")
                }
            
            ReflectionView()
                .tabItem {
                    Label("Reflection", systemImage: "sunrise.fill")
                }
            
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
            
            SettingsView(appState: appState)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(AppTheme.primaryTextColor)
        .preferredColorScheme(appState.selectedTheme == .light ? .light : appState.selectedTheme == .dark ? .dark : nil)
        .environment(appState)
    }
}
