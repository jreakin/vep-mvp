import Foundation

/// User model representing a campaign user
struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let fullName: String
    let role: UserRole
    let phone: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case role
        case phone
    }
}

/// User role enumeration
enum UserRole: String, Codable {
    case admin
    case manager
    case canvasser
}
