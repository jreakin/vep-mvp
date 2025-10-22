import Foundation

/// Contact log model representing a voter contact event
struct ContactLog: Codable, Identifiable {
    let id: UUID
    let assignmentId: UUID
    let voterId: UUID
    let contactType: ContactType
    let result: String?
    let supportLevel: Int?
    let location: Coordinate
    let contactedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case assignmentId = "assignment_id"
        case voterId = "voter_id"
        case contactType = "contact_type"
        case result
        case supportLevel = "support_level"
        case location
        case contactedAt = "contacted_at"
    }
    
    /// Initialize a new contact log (for creating new contacts)
    init(id: UUID = UUID(),
         assignmentId: UUID,
         voterId: UUID,
         contactType: ContactType,
         result: String?,
         supportLevel: Int?,
         location: Coordinate,
         contactedAt: Date = Date()) {
        self.id = id
        self.assignmentId = assignmentId
        self.voterId = voterId
        self.contactType = contactType
        self.result = result
        self.supportLevel = supportLevel
        self.location = location
        self.contactedAt = contactedAt
    }
}

/// Contact type enumeration
enum ContactType: String, Codable, CaseIterable {
    case knocked
    case phone
    case text
    case email
    case notHome = "not_home"
    case refused
    case moved
    case deceased
    
    var displayName: String {
        switch self {
        case .knocked: return "Knocked"
        case .phone: return "Phone"
        case .text: return "Text"
        case .email: return "Email"
        case .notHome: return "Not Home"
        case .refused: return "Refused"
        case .moved: return "Moved"
        case .deceased: return "Deceased"
        }
    }
    
    var isSuccessfulContact: Bool {
        switch self {
        case .knocked, .phone, .text, .email:
            return true
        case .notHome, .refused, .moved, .deceased:
            return false
        }
    }
}
