//
//  ErrorAlert.swift
//  Finance Regret Manager
//
//  Created for Financial Regret Manager
//

import SwiftUI

struct ErrorAlert: ViewModifier {
    @Binding var errorMessage: String?
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
    }
}

extension View {
    func errorAlert(errorMessage: Binding<String?>) -> some View {
        modifier(ErrorAlert(errorMessage: errorMessage))
    }
}
