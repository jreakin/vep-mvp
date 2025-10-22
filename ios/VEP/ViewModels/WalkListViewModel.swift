//
//  WalkListViewModel.swift
//  VEP
//
//  Created by Agent 3 on 2025-10-22.
//

import Foundation
import CoreLocation
import Combine

/// ViewModel for managing the walk list view with map navigation
@MainActor
class WalkListViewModel: ObservableObject {
    @Published var assignment: Assignment
    @Published var currentVoterIndex = 0
    @Published var contactedVoters: Set<UUID> = []
    @Published var isOnline = true
    @Published var showingContactForm = false
    @Published var mapRegion: MapRegion?
    
    var currentVoter: Voter? {
        guard let voters = assignment.voters,
              currentVoterIndex < voters.count else {
            return nil
        }
        return voters[currentVoterIndex]
    }
    
    var nextVoter: Voter? {
        guard let voters = assignment.voters,
              currentVoterIndex + 1 < voters.count else {
            return nil
        }
        return voters[currentVoterIndex + 1]
    }
    
    var previousVoter: Voter? {
        guard currentVoterIndex > 0,
              let voters = assignment.voters,
              currentVoterIndex - 1 < voters.count else {
            return nil
        }
        return voters[currentVoterIndex - 1]
    }
    
    var progress: Double {
        guard assignment.voterCount > 0 else { return 0 }
        return Double(contactedVoters.count) / Double(assignment.voterCount)
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
    
    var remainingVoters: Int {
        assignment.voterCount - contactedVoters.count
    }
    
    init(assignment: Assignment) {
        self.assignment = assignment
        
        // Load assignment with voters if not already loaded
        if assignment.voters == nil {
            loadAssignmentDetails()
        }
    }
    
    func loadAssignmentDetails() {
        // For now, use mock data
        // Agent 4 will replace this with real API calls
        var updatedAssignment = assignment
        updatedAssignment.voters = MockData.voters
        self.assignment = updatedAssignment
        
        // Center map on first voter
        if let firstVoter = updatedAssignment.voters?.first {
            centerMapOnVoter(firstVoter)
        }
    }
    
    func nextVoter() {
        guard let voters = assignment.voters,
              currentVoterIndex + 1 < voters.count else {
            return
        }
        
        currentVoterIndex += 1
        
        if let voter = currentVoter {
            centerMapOnVoter(voter)
        }
    }
    
    func previousVoter() {
        guard currentVoterIndex > 0 else { return }
        currentVoterIndex -= 1
        
        if let voter = currentVoter {
            centerMapOnVoter(voter)
        }
    }
    
    func skipVoter() {
        nextVoter()
    }
    
    func showContactForm() {
        showingContactForm = true
    }
    
    func logContact(_ log: ContactLog) async {
        // Mark voter as contacted
        markVoterContacted(log.voterId)
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        // Agent 4 will replace this with real API calls
        // For now, just update local state
        
        // Move to next voter
        showingContactForm = false
        nextVoter()
    }
    
    func markVoterContacted(_ voterId: UUID) {
        contactedVoters.insert(voterId)
    }
    
    private func centerMapOnVoter(_ voter: Voter) {
        mapRegion = MapRegion(
            center: voter.location,
            span: MapSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
}

/// Map region helper
struct MapRegion {
    let center: Coordinate
    let span: MapSpan
}

struct MapSpan {
    let latitudeDelta: Double
    let longitudeDelta: Double
}
