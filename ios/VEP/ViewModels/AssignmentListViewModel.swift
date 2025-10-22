//
//  AssignmentListViewModel.swift
//  VEP
//
//  Created by Agent 3 on 2025-10-22.
//

import Foundation
import Combine

/// ViewModel for managing the assignment list view
@MainActor
class AssignmentListViewModel: ObservableObject {
    @Published var assignments: [Assignment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var filterStatus: AssignmentStatus?
    @Published var searchText: String = ""
    
    private var allAssignments: [Assignment] = []
    
    var filteredAssignments: [Assignment] {
        var result = allAssignments
        
        // Filter by status if selected
        if let status = filterStatus {
            result = result.filter { $0.status == status }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { assignment in
                assignment.name.localizedCaseInsensitiveContains(searchText) ||
                (assignment.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return result
    }
    
    init() {
        // Initialize with mock data
        loadMockData()
    }
    
    func loadAssignments() async {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // For now, use mock data
        // Agent 4 will replace this with real API calls
        allAssignments = MockData.assignments
        assignments = filteredAssignments
        
        isLoading = false
    }
    
    func refreshAssignments() async {
        await loadAssignments()
    }
    
    func filterByStatus(_ status: AssignmentStatus?) {
        filterStatus = status
        assignments = filteredAssignments
    }
    
    func updateSearchText(_ text: String) {
        searchText = text
        assignments = filteredAssignments
    }
    
    private func loadMockData() {
        allAssignments = MockData.assignments
        assignments = filteredAssignments
    }
}

/// Mock data for development
struct MockData {
    static let assignments: [Assignment] = [
        Assignment(
            id: UUID(),
            name: "Downtown Austin - Oct 22",
            description: "Focus on apartment buildings",
            assignedDate: Date(),
            dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
            status: .inProgress,
            voterCount: 47,
            completedCount: 12,
            voters: nil
        ),
        Assignment(
            id: UUID(),
            name: "East Austin - Oct 23",
            description: "Single family homes",
            assignedDate: Date(),
            dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
            status: .pending,
            voterCount: 32,
            completedCount: 0,
            voters: nil
        ),
        Assignment(
            id: UUID(),
            name: "South Austin - Completed",
            description: "Mixed residential",
            assignedDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            dueDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
            status: .completed,
            voterCount: 28,
            completedCount: 28,
            voters: nil
        )
    ]
    
    static let voters: [Voter] = [
        Voter(
            id: UUID(),
            voterId: "TX12345678",
            firstName: "Jane",
            lastName: "Smith",
            address: "123 Main St",
            city: "Austin",
            state: "TX",
            zip: "78701",
            location: Coordinate(latitude: 30.2672, longitude: -97.7431),
            partyAffiliation: "D",
            supportLevel: 3,
            phone: "512-555-0100",
            email: "jane.smith@example.com",
            sequenceOrder: 1,
            lastContact: ContactSummary(
                date: "2025-10-20T14:30:00Z",
                type: "knocked",
                result: "Not home"
            )
        ),
        Voter(
            id: UUID(),
            voterId: "TX87654321",
            firstName: "John",
            lastName: "Doe",
            address: "456 Oak Ave",
            city: "Austin",
            state: "TX",
            zip: "78702",
            location: Coordinate(latitude: 30.2642, longitude: -97.7251),
            partyAffiliation: "R",
            supportLevel: 2,
            phone: "512-555-0101",
            email: nil,
            sequenceOrder: 2,
            lastContact: nil
        ),
        Voter(
            id: UUID(),
            voterId: "TX11223344",
            firstName: "Alice",
            lastName: "Johnson",
            address: "789 Elm St",
            city: "Austin",
            state: "TX",
            zip: "78703",
            location: Coordinate(latitude: 30.2882, longitude: -97.7431),
            partyAffiliation: "D",
            supportLevel: 5,
            phone: "512-555-0102",
            email: "alice.j@example.com",
            sequenceOrder: 3,
            lastContact: ContactSummary(
                date: "2025-10-21T10:15:00Z",
                type: "knocked",
                result: "Strong supporter, wants yard sign"
            )
        )
    ]
}
