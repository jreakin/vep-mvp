import Foundation
import SwiftUI

/// ViewModel for contact log form
@MainActor
class ContactLogViewModel: ObservableObject {
    @Published var selectedContactType: ContactType = .knocked
    @Published var result: String = ""
    @Published var supportLevel: Int?
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    
    let voter: Voter
    let assignmentId: UUID
    
    private let apiClient = APIClient.shared
    private let storage = OfflineStorageService.shared
    private let syncService = SyncService.shared
    private let locationService = LocationService.shared
    
    var onSuccess: (() -> Void)?
    
    init(voter: Voter, assignmentId: UUID) {
        self.voter = voter
        self.assignmentId = assignmentId
    }
    
    /// Whether the form is valid and can be submitted
    var canSubmit: Bool {
        // For successful contacts, require either result or support level
        if selectedContactType.isSuccessfulContact {
            return !result.isEmpty || supportLevel != nil
        }
        // For unsuccessful contacts, no additional data required
        return true
    }
    
    /// Submit the contact log
    func submit() async {
        guard canSubmit else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        // Get current location
        let location = locationService.currentCoordinate ??
            Coordinate(latitude: 0, longitude: 0)
        
        let contactLog = ContactLog(
            assignmentId: assignmentId,
            voterId: voter.id,
            contactType: selectedContactType,
            result: result.isEmpty ? nil : result,
            supportLevel: supportLevel,
            location: location
        )
        
        do {
            if syncService.isOnline {
                // Try to submit immediately
                _ = try await apiClient.createContactLog(contactLog)
            } else {
                // Queue for later sync
                try storage.queueContactLog(contactLog)
            }
            
            // Success - call completion handler
            onSuccess?()
            
        } catch {
            // Queue for sync even if API failed
            try? storage.queueContactLog(contactLog)
            errorMessage = "Contact logged offline: \(error.localizedDescription)"
            
            // Still call success after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.onSuccess?()
            }
        }
        
        isSubmitting = false
    }
    
    /// Clear the form
    func clear() {
        selectedContactType = .knocked
        result = ""
        supportLevel = nil
        errorMessage = nil
    }
    
    /// Quick contact types (for buttons)
    let quickContactTypes: [ContactType] = [
        .knocked,
        .notHome,
        .refused
    ]
    
    /// Support level options
    let supportLevels: [(Int, String, String)] = [
        (1, "Strong Opponent", "😠"),
        (2, "Lean Opponent", "😕"),
        (3, "Undecided", "😐"),
        (4, "Lean Support", "🙂"),
        (5, "Strong Support", "😄")
    ]
}
