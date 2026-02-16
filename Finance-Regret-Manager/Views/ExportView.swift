//
//  ExportView.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI
import CoreData

struct ExportView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var regretViewModel: RegretViewModel
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var errorMessage: String?
    
    init(context: NSManagedObjectContext) {
        _regretViewModel = State(initialValue: RegretViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Export & Closure")
                            .font(AppTheme.serifFontMedium)
                            .foregroundColor(AppTheme.primaryTextColor)
                            .padding(.top, 20)
                        
                        // PDF Export
                        exportButton(
                            icon: "doc.text.fill",
                            title: "Export PDF",
                            description: "Create a beautiful PDF of all your reflections",
                            action: exportPDF
                        )
                        
                        // JSON Export
                        exportButton(
                            icon: "square.and.arrow.down",
                            title: "Export JSON",
                            description: "Export all data as JSON file",
                            action: exportJSON
                        )
                        
                        // Share single regret
                        exportButton(
                            icon: "square.and.arrow.up",
                            title: "Share Reflection",
                            description: "Share a single reflection as a card",
                            action: shareSingleRegret
                        )
                        
                        Text("This is a private personal journal for reflection. Not medical or financial advice.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                    }
                    .padding(AppTheme.padding)
                }
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: shareItems)
            }
            .errorAlert(errorMessage: $errorMessage)
        }
        .onAppear {
            regretViewModel = RegretViewModel(context: viewContext)
        }
    }
    
    private func exportButton(icon: String, title: String, description: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(AppTheme.accentColor)
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(AppTheme.primaryTextColor)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(AppTheme.warmBeige.opacity(0.3))
            )
        }
    }
    
    private func exportPDF() {
        let allRegrets = regretViewModel.fetchAllRegrets()
        guard !allRegrets.isEmpty else {
            errorMessage = "No reflections to export. Add some reflections first."
            return
        }
        
        let pdfData = generatePDF(regrets: allRegrets)
        
        if let pdfData = pdfData {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Financial_Reflections_\(Date().formatted(date: .numeric, time: .omitted)).pdf")
            do {
                try pdfData.write(to: tempURL)
                shareItems = [tempURL]
                showingShareSheet = true
            } catch {
                errorMessage = "Failed to create PDF: \(error.localizedDescription)"
            }
        }
    }
    
    private func exportJSON() {
        let allRegrets = regretViewModel.fetchAllRegrets()
        guard !allRegrets.isEmpty else {
            errorMessage = "No reflections to export. Add some reflections first."
            return
        }
        
        let regretsData = allRegrets.map { regret in
            [
                "id": regret.id.uuidString,
                "title": regret.title,
                "date": ISO8601DateFormatter().string(from: regret.date),
                "category": regret.category ?? "",
                "description": regret.descriptionText,
                "moneyImpact": regret.moneyImpact,
                "emotionalIntensity": regret.emotionalIntensity,
                "initialFeeling": regret.initialFeeling ?? "",
                "lessonLearned": regret.lessonLearned ?? "",
                "status": regret.status
            ]
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: regretsData, options: .prettyPrinted)
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Financial_Reflections_\(Date().formatted(date: .numeric, time: .omitted)).json")
            try jsonData.write(to: tempURL)
            shareItems = [tempURL]
            showingShareSheet = true
        } catch {
            errorMessage = "Failed to export JSON: \(error.localizedDescription)"
        }
    }
    
    private func shareSingleRegret() {
        let allRegrets = regretViewModel.fetchAllRegrets()
        guard !allRegrets.isEmpty, let randomRegret = allRegrets.randomElement() else {
            errorMessage = "No reflections to share. Add some reflections first."
            return
        }
        
        let text = """
        Financial Reflection
        
        \(randomRegret.title)
        
        \(randomRegret.descriptionText)
        
        \(randomRegret.lessonLearned ?? "No lesson recorded yet")
        """
        
        shareItems = [text]
        showingShareSheet = true
    }
    
    private func generatePDF(regrets: [FinancialRegret]) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Financial Regret Manager",
            kCGPDFContextAuthor: "User",
            kCGPDFContextTitle: "My Financial Reflections"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 50
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Georgia", size: 28) ?? UIFont.systemFont(ofSize: 28),
                .foregroundColor: UIColor(AppTheme.deepRose)
            ]
            let title = NSAttributedString(string: "My Financial Reflections", attributes: titleAttributes)
            title.draw(at: CGPoint(x: 50, y: yPosition))
            yPosition += 50
            
            // Regrets
            for regret in regrets {
                if yPosition > pageHeight - 200 {
                    context.beginPage()
                    yPosition = 50
                }
                
                let text = "\(regret.title)\n\(regret.date.formatted(date: .long, time: .omitted))\n\n\(regret.descriptionText)\n\n\(regret.lessonLearned ?? "No lesson recorded")\n\n"
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.label
                ]
                let attributedText = NSAttributedString(string: text, attributes: attributes)
                let textRect = CGRect(x: 50, y: yPosition, width: pageWidth - 100, height: 200)
                attributedText.draw(in: textRect)
                yPosition += 200
            }
        }
        
        return data
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
