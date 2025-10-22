import Foundation
import SwiftUI
import CoreLocation

/// ViewModel for the walk list view (canvassing flow)
@MainActor
class WalkListViewModel: ObservableObject {
    @Published var assignment: Assignment
    @Published var currentVoterIndex = 0
    @Published var contactedVoters: Set<UUID> = []
    @Published var isLoggingContact = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    private let storage = OfflineStorageService.shared
    private let syncService = SyncService.shared
    private let locationService = LocationService.shared
    
    init(assignment: Assignment) {
        self.assignment = assignment
        loadContactedVoters()
    }
    
    /// Current voter in the list
    var currentVoter: Voter? {
        guard let voters = assignment.voters,
              currentVoterIndex < voters.count else {
            return nil
        }
        return voters[currentVoterIndex]
    }
    
    /// Next voter in the list
    var nextVoter: Voter? {
        guard let voters = assignment.voters,
              currentVoterIndex + 1 < voters.count else {
            return nil
        }
        return voters[currentVoterIndex + 1]
    }
    
    /// Progress percentage (0.0 to 1.0)
    var progress: Double {
        guard let voters = assignment.voters, !voters.isEmpty else {
            return 0.0
        }
        return Double(contactedVoters.count) / Double(voters.count)
    }
    
    /// Number of remaining voters
    var remainingCount: Int {
        guard let voters = assignment.voters else { return 0 }
        return voters.count - contactedVoters.count
    }
    
    /// Whether all voters have been contacted
    var isComplete: Bool {
        guard let voters = assignment.voters else { return false }
        return contactedVoters.count == voters.count
    }
    
    // MARK: - Navigation
    
    /// Move to next voter
    func nextVoter() {
        guard let voters = assignment.voters,
              currentVoterIndex < voters.count - 1 else {
            return
        }
        currentVoterIndex += 1
    }
    
    /// Move to previous voter
    func previousVoter() {
        guard currentVoterIndex > 0 else { return }
        currentVoterIndex -= 1
    }
    
    /// Jump to a specific voter
    func jumpToVoter(index: Int) {
        guard let voters = assignment.voters,
              index >= 0 && index < voters.count else {
            return
        }
        currentVoterIndex = index
    }
    
    // MARK: - Contact Logging
    
    /// Log a contact for the current voter
    func logContact(
        contactType: ContactType,
        result: String?,
        supportLevel: Int?
    ) async {
        guard let voter = currentVoter else { return }
        
        isLoggingContact = true
        errorMessage = nil
        
        // Get current location
        let location = locationService.currentCoordinate ??
            Coordinate(latitude: 0, longitude: 0)
        
        let contactLog = ContactLog(
            assignmentId: assignment.id,
            voterId: voter.id,
            contactType: contactType,
            result: result,
            supportLevel: supportLevel,
            location: location
        )
        
        do {
            if syncService.isOnline {
                // Try to sync immediately if online
                _ = try await apiClient.createContactLog(contactLog)
            } else {
                // Queue for later sync if offline
                try storage.queueContactLog(contactLog)
            }
            
            // Mark voter as contacted
            contactedVoters.insert(voter.id)
            saveContactedVoters()
            
            // Auto-advance to next voter
            if !isComplete {
                nextVoter()
            } else {
                // Mark assignment as completed
                await markAssignmentComplete()
            }
            
        } catch {
            // Queue for sync even if API call failed
            try? storage.queueContactLog(contactLog)
            contactedVoters.insert(voter.id)
            saveContactedVoters()
            
            errorMessage = "Contact logged offline: \(error.localizedDescription)"
        }
        
        isLoggingContact = false
    }
    
    /// Mark a voter as contacted without details
    func markVoterContacted(_ voterId: UUID) {
        contactedVoters.insert(voterId)
        saveContactedVoters()
    }
    
    /// Skip current voter
    func skipVoter() {
        nextVoter()
    }
    
    // MARK: - Assignment Management
    
    /// Mark assignment as completed
    private func markAssignmentComplete() async {
        do {
            if syncService.isOnline {
                assignment = try await apiClient.updateAssignmentStatus(
                    id: assignment.id,
                    status: .completed
                )
            }
            // Cache the updated status
            try? storage.cacheAssignment(assignment)
        } catch {
            errorMessage = "Failed to mark assignment complete: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Distance Calculations
    
    /// Distance to current voter in meters
    func distanceToCurrentVoter() -> Double? {
        guard let voter = currentVoter,
              let currentLocation = locationService.currentCoordinate else {
            return nil
        }
        return locationService.distance(from: currentLocation, to: voter.location)
    }
    
    /// Distance to next voter in meters
    func distanceToNextVoter() -> Double? {
        guard let next = nextVoter,
              let current = currentVoter else {
            return nil
        }
        return locationService.distance(from: current.location, to: next.location)
    }
    
    // MARK: - Persistence
    
    private func loadContactedVoters() {
        let key = "contacted_voters_\(assignment.id.uuidString)"
        if let data = UserDefaults.standard.data(forKey: key),
           let ids = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            contactedVoters = ids
        }
    }
    
    private func saveContactedVoters() {
        let key = "contacted_voters_\(assignment.id.uuidString)"
        if let data = try? JSONEncoder().encode(contactedVoters) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
