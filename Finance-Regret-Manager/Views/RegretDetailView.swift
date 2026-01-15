//
//  RegretDetailView.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI
import CoreData

struct RegretDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let regret: FinancialRegret
    let context: NSManagedObjectContext
    
    @State private var regretViewModel: RegretViewModel
    @State private var showingEdit = false
    @State private var showingLessonUpdate = false
    @State private var lessonText: String = ""
    
    init(regret: FinancialRegret, context: NSManagedObjectContext) {
        self.regret = regret
        self.context = context
        _regretViewModel = State(initialValue: RegretViewModel(context: context))
        _lessonText = State(initialValue: regret.lessonLearned ?? "")
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 12) {
                            Text(regret.title)
                                .font(AppTheme.serifFontMedium)
                                .foregroundColor(AppTheme.primaryTextColor)
                            
                            HStack {
                                Text(regret.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if let category = regret.categoryName {
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    Text(category)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            StatusBadge(status: regret.status)
                        }
                        .padding(.horizontal, AppTheme.padding)
                        .padding(.top, 20)
                        
                        // Original story
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Original Story")
                                .font(.headline)
                                .foregroundColor(AppTheme.primaryTextColor)
                            
                            Text(regret.descriptionText)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .fill(AppTheme.secondaryBackgroundColor)
                        )
                        .padding(.horizontal, AppTheme.padding)
                        
                        // Money impact
                        if regret.moneyImpact > 0 {
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(AppTheme.primaryTextColor)
                                Text("Money Impact: $\(String(format: "%.2f", regret.moneyImpact))")
                                    .font(.headline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .fill(AppTheme.primaryTextColor.opacity(0.1))
                            )
                            .padding(.horizontal, AppTheme.padding)
                        }
                        
                        // Emotional gauge
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Emotional Intensity")
                                .font(.headline)
                                .foregroundColor(AppTheme.primaryTextColor)
                            
                            HStack {
                                ForEach(1...10, id: \.self) { index in
                                    Rectangle()
                                        .fill(index <= Int(regret.emotionalIntensity) ? intensityColor : Color.gray.opacity(0.2))
                                        .frame(height: 8)
                                        .cornerRadius(4)
                                }
                            }
                            
                            Text("\(Int(regret.emotionalIntensity)) / 10")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .fill(AppTheme.secondaryBackgroundColor)
                        )
                        .padding(.horizontal, AppTheme.padding)
                        
                        // Initial feeling
                        if let feeling = regret.initialFeeling, !feeling.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Initial Feeling")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.primaryTextColor)
                                
                                Text(feeling)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .fill(AppTheme.secondaryBackgroundColor)
                            )
                            .padding(.horizontal, AppTheme.padding)
                        }
                        
                        // Lesson learned
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Lesson Learned")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.primaryTextColor)
                                
                                Spacer()
                                
                                Button(action: {
                                    showingLessonUpdate = true
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(AppTheme.accentColor)
                                }
                            }
                            
                            if let lesson = regret.lessonLearned, !lesson.isEmpty {
                                Text(lesson)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            } else {
                                Text("No lesson recorded yet")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .fill(AppTheme.accentColor.opacity(0.1))
                        )
                        .padding(.horizontal, AppTheme.padding)
                        
                        // Action buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                showingEdit = true
                            }) {
                                Text("Edit Reflection")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppTheme.primaryGradient)
                                    .cornerRadius(AppTheme.cornerRadius)
                            }
                            
                            Button(action: {
                                regretViewModel.deleteRegret(regret)
                                dismiss()
                            }) {
                                Text("Archive")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.primaryTextColor)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppTheme.cardBackgroundColor)
                                    .cornerRadius(AppTheme.cornerRadius)
                            }
                        }
                        .padding(.horizontal, AppTheme.padding)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Reflection Details")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingEdit) {
                RegretFormView(
                    context: context,
                    regret: regret,
                    onSave: {
                        showingEdit = false
                    }
                )
            }
            .sheet(isPresented: $showingLessonUpdate) {
                LessonUpdateView(
                    regret: regret,
                    context: context,
                    onSave: {
                        showingLessonUpdate = false
                    }
                )
            }
    }
    
    private var intensityColor: Color {
        let intensity = Int(regret.emotionalIntensity)
        if intensity <= 3 {
            return AppTheme.accentColor
        } else if intensity <= 6 {
            return Color.orange
        } else {
            return AppTheme.primaryTextColor
        }
    }
}

struct LessonUpdateView: View {
    @Environment(\.dismiss) private var dismiss
    let regret: FinancialRegret
    let context: NSManagedObjectContext
    
    @State private var lessonText: String
    @State private var selectedStatus: String
    @State private var regretViewModel: RegretViewModel
    @State private var showingAnimation = false
    
    init(regret: FinancialRegret, context: NSManagedObjectContext, onSave: @escaping () -> Void) {
        self.regret = regret
        self.context = context
        self.onSave = onSave
        _lessonText = State(initialValue: regret.lessonLearned ?? "")
        _selectedStatus = State(initialValue: regret.status)
        _regretViewModel = State(initialValue: RegretViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("What I learned")
                        .font(AppTheme.serifFontSmall)
                        .foregroundColor(AppTheme.primaryTextColor)
                        .padding(.top, 20)
                    
                    TextEditor(text: $lessonText)
                        .frame(minHeight: 200)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .fill(AppTheme.secondaryBackgroundColor)
                        )
                        .padding(.horizontal, AppTheme.padding)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Status")
                            .font(.headline)
                            .foregroundColor(AppTheme.primaryTextColor)
                        
                        Picker("Status", selection: $selectedStatus) {
                            ForEach(RegretStatus.allCases) { status in
                                Text(status.rawValue).tag(status.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal, AppTheme.padding)
                    
                    Spacer()
                    
                    Button(action: {
                        regretViewModel.updateRegret(
                            regret,
                            lessonLearned: lessonText.isEmpty ? nil : lessonText,
                            status: selectedStatus
                        )
                        
                        if RegretStatus.from(selectedStatus).isTransformed {
                            withAnimation(AppTheme.slowAnimation) {
                                showingAnimation = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                onSave()
                                dismiss()
                            }
                        } else {
                            onSave()
                            dismiss()
                        }
                    }) {
                        Text("Update Lesson")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primaryGradient)
                            .cornerRadius(AppTheme.cornerRadius)
                    }
                    .padding(.horizontal, AppTheme.padding)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Update Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if showingAnimation {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 80))
                                .foregroundColor(AppTheme.accentColor)
                                .scaleEffect(showingAnimation ? 1.2 : 0.8)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatCount(2, autoreverses: true),
                                    value: showingAnimation
                                )
                            
                            Text("Transformation Complete")
                                .font(AppTheme.serifFontSmall)
                                .foregroundColor(AppTheme.primaryTextColor)
                        }
                        .padding(40)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                                .fill(AppTheme.backgroundColor)
                        )
                        .padding(40)
                    }
                }
            }
        }
    }
    
    var onSave: () -> Void
}
