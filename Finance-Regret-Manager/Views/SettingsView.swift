//
//  SettingsView.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var appState: AppState
    @State private var showingResetConfirmation = false
    @State private var resetConfirmationCount = 0
    
    init(appState: AppState) {
        _appState = State(initialValue: appState)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        Picker("Theme", selection: Binding(
                            get: { appState.selectedTheme },
                            set: { appState.setTheme($0) }
                        )) {
                            ForEach(ThemeMode.allCases, id: \.self) { theme in
                                Text(theme.rawValue.capitalized).tag(theme)
                            }
                        }
                    } header: {
                        Text("Appearance")
                    }
                    
                    Section {
                        Toggle("Monthly Reflection Reminder", isOn: Binding(
                            get: { appState.monthlyReminderEnabled },
                            set: { appState.monthlyReminderEnabled = $0 }
                        ))
                    } header: {
                        Text("Notifications")
                    } footer: {
                        Text("Receive gentle reminders to reflect on your progress")
                    }
                    
                    Section {
                        NavigationLink("Custom Status Names") {
                            CustomStatusNamesView(appState: appState)
                        }
                    } header: {
                        Text("Customization")
                    }
                    
                    Section {
                        NavigationLink("Export Data") {
                            ExportView(context: viewContext)
                        }
                    } header: {
                        Text("Data")
                    }
                    
                    Section {
                        Text("This is a private personal journal for reflection. Not medical or financial advice.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } footer: {
                        Text("")
                    }
                    
                    Section {
                        Button(role: .destructive, action: {
                            resetConfirmationCount += 1
                            if resetConfirmationCount >= 3 {
                                resetAllData()
                            } else {
                                showingResetConfirmation = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Reset All Data")
                            }
                        }
                    } header: {
                        Text("Danger Zone")
                    } footer: {
                        Text("This will permanently delete all your reflections. This action cannot be undone.")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset All Data", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) {
                    resetConfirmationCount = 0
                }
                Button("Reset", role: .destructive) {
                    // Continue counting
                }
            } message: {
                Text("Are you sure? This will delete all your reflections permanently. Tap Reset \(3 - resetConfirmationCount) more times to confirm.")
            }
        }
    }
    
    private func resetAllData() {
        let request1: NSFetchRequest<NSFetchRequestResult> = FinancialRegret.fetchRequest()
        let delete1 = NSBatchDeleteRequest(fetchRequest: request1)
        delete1.resultType = .resultTypeObjectIDs
        
        let request2: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        let delete2 = NSBatchDeleteRequest(fetchRequest: request2)
        delete2.resultType = .resultTypeObjectIDs
        
        do {
            let result1 = try viewContext.execute(delete1) as? NSBatchDeleteResult
            let result2 = try viewContext.execute(delete2) as? NSBatchDeleteResult
            
            if let objectIDs1 = result1?.result as? [NSManagedObjectID],
               let objectIDs2 = result2?.result as? [NSManagedObjectID] {
                let changes = [NSDeletedObjectsKey: objectIDs1 + objectIDs2]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
            }
            
            try viewContext.save()
            resetConfirmationCount = 0
        } catch {
            ErrorHandler.logError(error, context: "resetAllData", severity: .high)
            viewContext.rollback()
        }
    }
}

struct CustomStatusNamesView: View {
    @State var appState: AppState
    
    var body: some View {
        Form {
            ForEach(RegretStatus.allCases) { status in
                Section {
                    TextField("Custom name", text: Binding(
                        get: { appState.customStatusNames[status.rawValue] ?? status.rawValue },
                        set: { appState.customStatusNames[status.rawValue] = $0.isEmpty ? nil : $0 }
                    ))
                } header: {
                    Text(status.rawValue)
                }
            }
        }
        .navigationTitle("Custom Status Names")
        .navigationBarTitleDisplayMode(.inline)
    }
}
