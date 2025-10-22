//
//  Voter.swift
//  VEP
//
//  Created by Agent 3 on 2025-10-22.
//

import Foundation
import CoreLocation

/// Coordinate model for geographic locations
struct Coordinate: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// Voter model representing individual voters in the database
struct Voter: Codable, Identifiable {
    let id: UUID
    let voterId: String
    let firstName: String
    let lastName: String
    let address: String
    let city: String
    let state: String
    let zip: String
    let location: Coordinate
    let partyAffiliation: String?
    let supportLevel: Int?
    let phone: String?
    let email: String?
    var sequenceOrder: Int?
    var lastContact: ContactSummary?
    
    enum CodingKeys: String, CodingKey {
        case id
        case voterId = "voter_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case address
        case city
        case state
        case zip
        case location
        case partyAffiliation = "party_affiliation"
        case supportLevel = "support_level"
        case phone
        case email
        case sequenceOrder = "sequence_order"
        case lastContact = "last_contact"
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var fullAddress: String {
        "\(address), \(city), \(state) \(zip)"
    }
    
    var supportLevelDescription: String {
        guard let level = supportLevel else { return "Unknown" }
        switch level {
        case 1: return "Strong Opponent"
        case 2: return "Lean Opponent"
        case 3: return "Undecided"
        case 4: return "Lean Support"
        case 5: return "Strong Support"
        default: return "Unknown"
        }
    }
}

/// Summary of last contact with a voter
struct ContactSummary: Codable {
    let date: String
    let type: String
    let result: String?
    
    var displayDate: String {
        // Parse ISO date string and format for display
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: date) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return date
    }
}
