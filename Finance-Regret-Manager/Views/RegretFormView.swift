//
//  RegretFormView.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI
import CoreData

struct RegretFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    let regret: FinancialRegret?
    let onSave: () -> Void
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.order, ascending: true)],
        animation: .default
    ) private var categories: FetchedResults<Category>
    
    @State private var title: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedCategory: String? = nil
    @State private var selectedCategoryObject: Category? = nil
    @State private var description: String = ""
    @State private var moneyImpact: String = ""
    @State private var emotionalIntensity: Double = 5
    @State private var initialFeeling: String = ""
    @State private var status: String = "Active"
    
    @State private var regretViewModel: RegretViewModel
    @State private var errorMessage: String?
    
    init(context: NSManagedObjectContext, regret: FinancialRegret?, onSave: @escaping () -> Void) {
        self.regret = regret
        self.onSave = onSave
        _regretViewModel = State(initialValue: RegretViewModel(context: context))
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor
                .ignoresSafeArea()
            
            Form {
                Section {
                    TextField("Title", text: $title)
                        .font(.body)
                } header: {
                    Text("Title")
                }
                
                Section {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                }
                
                Section {
                    Picker("Category", selection: $selectedCategoryObject) {
                        Text("None").tag(nil as Category?)
                        ForEach(categories) { category in
                            Text(category.name).tag(category as Category?)
                        }
                    }
                    .onChange(of: selectedCategoryObject) { oldValue, newValue in
                        selectedCategory = newValue?.name
                    }
                } header: {
                    Text("Category")
                }
                    
                    Section {
                        TextEditor(text: $description)
                            .frame(minHeight: 120)
                    } header: {
                        Text("Description")
                    }
                    
                    Section {
                        HStack {
                            Text("$")
                            TextField("0.00", text: $moneyImpact)
                                .keyboardType(.decimalPad)
                        }
                    } header: {
                        Text("Money Impact (Optional)")
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Emotional Intensity")
                                Spacer()
                                Text("\(Int(emotionalIntensity))")
                                    .font(.headline)
                                    .foregroundColor(intensityColor)
                            }
                            
                            Slider(value: $emotionalIntensity, in: 1...10, step: 1)
                                .tint(intensityColor)
                        }
                    }
                    
                    Section {
                        TextEditor(text: $initialFeeling)
                            .frame(minHeight: 80)
                    } header: {
                        Text("Initial Feeling")
                    }
                    
                    Section {
                        Picker("Status", selection: $status) {
                            ForEach(RegretStatus.allCases) { status in
                                Text(status.rawValue).tag(status.rawValue)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(regret == nil ? "New Reflection" : "Edit Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRegret()
                    }
                    .disabled(!isValid)
                }
            }
            .errorAlert(errorMessage: $errorMessage)
            .onAppear {
            if let regret = regret {
                title = regret.title
                selectedDate = regret.date
                selectedCategory = regret.category
                selectedCategoryObject = regret.categoryRelationship
                description = regret.descriptionText
                moneyImpact = regret.moneyImpact > 0 ? String(format: "%.2f", regret.moneyImpact) : ""
                emotionalIntensity = Double(regret.emotionalIntensity)
                initialFeeling = regret.initialFeeling ?? ""
                status = regret.status
            }
        }
    }
    
    private var intensityColor: Color {
        let intensity = Int(emotionalIntensity)
        if intensity <= 3 {
            return AppTheme.accentColor
        } else if intensity <= 6 {
            return Color.orange
        } else {
            return AppTheme.primaryTextColor
        }
    }
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        title.count <= 100 &&
        description.count <= 5000
    }
    
    private func saveRegret() {
        guard isValid else {
            errorMessage = "Please fill in all required fields. Title and description cannot be empty."
            return
        }
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let money = Double(moneyImpact) ?? 0
        
        do {
            if let regret = regret {
                regretViewModel.updateRegret(
                    regret,
                    title: trimmedTitle,
                    date: selectedDate,
                    category: selectedCategory,
                    description: trimmedDescription,
                    moneyImpact: money > 0 ? money : nil,
                    emotionalIntensity: Int(emotionalIntensity),
                    initialFeeling: initialFeeling.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : initialFeeling.trimmingCharacters(in: .whitespacesAndNewlines),
                    status: status,
                    categoryObject: selectedCategoryObject
                )
                try regretViewModel.saveWithError()
            } else {
                regretViewModel.createRegret(
                    title: trimmedTitle,
                    date: selectedDate,
                    category: selectedCategory,
                    description: trimmedDescription,
                    moneyImpact: money > 0 ? money : nil,
                    emotionalIntensity: Int(emotionalIntensity),
                    initialFeeling: initialFeeling.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : initialFeeling.trimmingCharacters(in: .whitespacesAndNewlines),
                    status: status,
                    categoryObject: selectedCategoryObject
                )
            }
            
            onSave()
            dismiss()
        } catch {
            ErrorHandler.logError(error, context: "saveRegret", severity: .high)
            errorMessage = ErrorHandler.userFriendlyMessage(for: error)
        }
    }
}
