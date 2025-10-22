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
    }
    
    /// Full name of the voter
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    /// Full address string
    var fullAddress: String {
        "\(address), \(city), \(state) \(zip)"
    }
}
