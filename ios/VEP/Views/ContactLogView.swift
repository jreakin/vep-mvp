//
//  ContactLogView.swift
//  VEP
//
//  Created by Agent 3 on 2025-10-22.
//

import SwiftUI

/// Form view for logging voter contacts
struct ContactLogView: View {
    let assignment: Assignment
    let voter: Voter
    @Binding var isPresented: Bool
    let onSubmit: (ContactLog) -> Void
    
    @StateObject private var viewModel: ContactLogViewModel
    @State private var selectedSupportLevel: Int?
    
    init(assignment: Assignment, voter: Voter, isPresented: Binding<Bool>, onSubmit: @escaping (ContactLog) -> Void) {
        self.assignment = assignment
        self.voter = voter
        self._isPresented = isPresented
        self.onSubmit = onSubmit
        _viewModel = StateObject(wrappedValue: ContactLogViewModel(assignment: assignment, voter: voter))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Voter info section
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(voter.fullName)
                            .font(.headline)
                        Text(voter.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Contact type section
                Section("Contact Type") {
                    Picker("Type", selection: $viewModel.contactType) {
                        ForEach(ContactType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Support level section
                Section("Support Level") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How supportive is this voter?")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 16) {
                            ForEach(1...5, id: \.self) { level in
                                SupportLevelButton(
                                    level: level,
                                    isSelected: viewModel.supportLevel == level
                                ) {
                                    viewModel.supportLevel = level
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        if let level = viewModel.supportLevel {
                            Text(supportLevelDescription(level))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Notes section
                Section("Notes") {
                    TextEditor(text: $viewModel.result)
                        .frame(minHeight: 100)
                }
                
                // Error message
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Log Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await submitForm()
                        }
                    }
                    .disabled(viewModel.isSubmitting)
                }
            }
        }
    }
    
    private func submitForm() async {
        do {
            let log = try await viewModel.submitContactLog()
            onSubmit(log)
            isPresented = false
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }
    
    private func supportLevelDescription(_ level: Int) -> String {
        switch level {
        case 1: return "Strong Opponent"
        case 2: return "Lean Opponent"
        case 3: return "Undecided"
        case 4: return "Lean Support"
        case 5: return "Strong Support"
        default: return ""
        }
    }
}

/// Support level button component
struct SupportLevelButton: View {
    let level: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(isSelected ? color : Color(.systemGray5))
                        .frame(width: 50, height: 50)
                    
                    Text("\(level)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(isSelected ? color : .gray)
            }
        }
    }
    
    private var color: Color {
        switch level {
        case 1, 2: return .red
        case 3: return .yellow
        case 4, 5: return .green
        default: return .gray
        }
    }
}

#Preview {
    ContactLogView(
        assignment: MockData.assignments[0],
        voter: MockData.voters[0],
        isPresented: .constant(true),
        onSubmit: { _ in }
    )
}
