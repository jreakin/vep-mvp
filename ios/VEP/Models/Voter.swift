import Foundation

/// Voter model representing a registered voter
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
    var sequenceOrder: Int? // Order in assignment walk list
    var lastContact: LastContact? // Most recent contact with this voter
    
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
    
    /// Full name of the voter
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    /// Full address string
    var fullAddress: String {
        "\(address), \(city), \(state) \(zip)"
    }
    
    /// Support level description
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

/// Last contact summary for a voter
struct LastContact: Codable {
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
