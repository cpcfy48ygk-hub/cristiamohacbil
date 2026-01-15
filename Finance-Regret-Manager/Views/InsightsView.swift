//
//  InsightsView.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI
import CoreData

struct InsightsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FinancialRegret.date, ascending: false)],
        animation: .default
    ) private var allRegrets: FetchedResults<FinancialRegret>
    
    @State private var categoryViewModelCache: CategoryViewModel?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        let allRegretsArray = Array(allRegrets)
                        
                        if allRegretsArray.isEmpty {
                            EmptyInsightsView()
                                .padding(.top, 60)
                        } else {
                            let progress = getGrowthProgress(regrets: allRegretsArray)
                            
                            // Overall progress ring
                            progressRingSection(progress: progress)
                            
                            // Regrets over time chart
                            regretsOverTimeSection(regrets: allRegretsArray)
                            
                            // Most transformed category
                            mostTransformedCategorySection(regrets: allRegretsArray)
                            
                            // Word cloud from lessons
                            wordCloudSection(regrets: allRegretsArray)
                        }
                    }
                    .padding(AppTheme.padding)
                }
            }
            .navigationTitle("Growth Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func progressRingSection(progress: Double) -> some View {
        VStack(spacing: 16) {
            Text("Overall Growth Progress")
                .font(AppTheme.serifFontSmall)
                .foregroundColor(AppTheme.primaryTextColor)
            
            ZStack {
                Circle()
                    .stroke(Color(light: AppTheme.lightGray, dark: AppTheme.lightGrayDark), lineWidth: 20)
                    .frame(width: 180, height: 180)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AppTheme.primaryGradient,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(AppTheme.slowAnimation, value: progress)
                
                VStack {
                    Text("\(Int(progress * 100))%")
                        .font(AppTheme.serifFont)
                        .foregroundColor(AppTheme.primaryTextColor)
                    Text("Transformed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .fill(AppTheme.secondaryBackgroundColor)
        )
    }
    
    private func regretsOverTimeSection(regrets: [FinancialRegret]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reflections Over Time")
                .font(AppTheme.serifFontSmall)
                .foregroundColor(AppTheme.primaryTextColor)
            
            // Simple bar chart representation
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(groupedByMonth(regrets).prefix(6)), id: \.key) { month, count in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(month)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(count)")
                                .font(.headline)
                                .foregroundColor(AppTheme.primaryTextColor)
                        }
                        
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(AppTheme.primaryGradient)
                                    .frame(width: geometry.size.width * min(CGFloat(count) / 10.0, 1.0), height: 8)
                                    .cornerRadius(4)
                                
                                Spacer()
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }
            .padding()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .fill(AppTheme.secondaryBackgroundColor)
        )
    }
    
    private func mostTransformedCategorySection(regrets: [FinancialRegret]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Most Transformed Category")
                .font(AppTheme.serifFontSmall)
                .foregroundColor(AppTheme.primaryTextColor)
            
            if let category = getMostTransformedCategory(regrets: regrets) {
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(AppTheme.accentColor)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.headline)
                            .foregroundColor(AppTheme.primaryTextColor)
                        
                        let stats = categoryViewModel.getCategoryStats(category, regrets: regrets)
                        Text("\(Int(stats.transformationRate * 100))% transformation rate")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .fill(AppTheme.accentColor.opacity(0.1))
                )
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("Not enough data yet")
                        .font(.body)
                        .foregroundColor(.secondary)
                    Text("Add more reflections with categories to see statistics")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .fill(AppTheme.secondaryBackgroundColor)
        )
    }
    
    private func wordCloudSection(regrets: [FinancialRegret]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Lessons Learned")
                .font(AppTheme.serifFontSmall)
                .foregroundColor(AppTheme.primaryTextColor)
            
            let lessons = regrets.compactMap { $0.lessonLearned }.filter { !$0.isEmpty }
            
            if lessons.isEmpty {
                Text("No lessons recorded yet")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(Array(Set(lessons.flatMap { $0.components(separatedBy: .whitespacesAndNewlines) })).prefix(20), id: \.self) { word in
                        Text(word)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(AppTheme.primaryGradient)
                            )
                    }
                }
                .padding()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .fill(AppTheme.secondaryBackgroundColor)
        )
    }
    
    private func groupedByMonth(_ regrets: [FinancialRegret]) -> [(key: String, value: Int)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        let grouped = Dictionary(grouping: regrets) { regret in
            formatter.string(from: regret.date)
        }
        
        return grouped.map { (key: $0.key, value: $0.value.count) }.sorted { $0.key < $1.key }
    }
    
    // Cache categoryViewModel to avoid recreating it on every call
    private var categoryViewModel: CategoryViewModel {
        if let cached = categoryViewModelCache {
            return cached
        }
        let new = CategoryViewModel(context: viewContext)
        categoryViewModelCache = new
        return new
    }
    
    private func getGrowthProgress(regrets: [FinancialRegret]) -> Double {
        guard !regrets.isEmpty else { return 0 }
        let transformed = regrets.filter { RegretStatus.from($0.status).isTransformed }.count
        return Double(transformed) / Double(regrets.count)
    }
    
    private func getMostTransformedCategory(regrets: [FinancialRegret]) -> Category? {
        let categories = categoryViewModel.fetchAllCategories()
        
        return categories.max { category1, category2 in
            let stats1 = categoryViewModel.getCategoryStats(category1, regrets: regrets)
            let stats2 = categoryViewModel.getCategoryStats(category2, regrets: regrets)
            return stats1.transformationRate < stats2.transformationRate
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}
