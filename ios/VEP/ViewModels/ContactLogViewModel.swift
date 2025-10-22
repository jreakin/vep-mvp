//
//  ContactLogViewModel.swift
//  VEP
//
//  Created by Agent 3 on 2025-10-22.
//

import Foundation
import CoreLocation
import Combine

/// ViewModel for managing contact log form
@MainActor
class ContactLogViewModel: ObservableObject {
    @Published var contactType: ContactType = .knocked
    @Published var result: String = ""
    @Published var supportLevel: Int?
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    
    let assignment: Assignment
    let voter: Voter
    private let locationService: LocationService
    
    var isValid: Bool {
        // Contact type is always selected (has default)
        // Result is optional
        return true
    }
    
    init(assignment: Assignment, voter: Voter, locationService: LocationService = LocationService.shared) {
        self.assignment = assignment
        self.voter = voter
        self.locationService = locationService
    }
    
    func submitContactLog() async throws -> ContactLog {
        guard isValid else {
            throw ContactLogError.invalidData
        }
        
        isSubmitting = true
        errorMessage = nil
        
        defer { isSubmitting = false }
        
        // Get current location or use voter's location as fallback
        let location = locationService.currentLocation ?? voter.location
        
        // Create contact log
        let log = ContactLog(
            id: UUID(),
            assignmentId: assignment.id,
            voterId: voter.id,
            userId: nil, // Will be set by backend based on auth token
            contactType: contactType,
            result: result.isEmpty ? nil : result,
            supportLevel: supportLevel,
            location: location,
            contactedAt: Date()
        )
        
        // Simulate API call
        try await Task.sleep(nanoseconds: 300_000_000)
        
        // Agent 4 will replace this with real API calls
        return log
    }
    
    func clearForm() {
        contactType = .knocked
        result = ""
        supportLevel = nil
        errorMessage = nil
    }
}

/// Location service mock for getting current user location
class LocationService {
    static let shared = LocationService()
    
    @Published var currentLocation: Coordinate?
    
    private init() {
        // Mock current location - Austin, TX
        currentLocation = Coordinate(latitude: 30.2672, longitude: -97.7431)
    }
    
    func requestLocationPermission() {
        // Will be implemented by Agent 4
    }
    
    func startUpdatingLocation() {
        // Will be implemented by Agent 4
    }
    
    func stopUpdatingLocation() {
        // Will be implemented by Agent 4
    }
}

enum ContactLogError: LocalizedError {
    case invalidData
    case networkError
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidData: return "Please fill in all required fields"
        case .networkError: return "Network error. Your contact will be synced when connection is restored."
        case .unauthorized: return "You are not authorized to perform this action"
        }
    }
}
