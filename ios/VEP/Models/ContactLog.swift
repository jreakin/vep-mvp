//
//  ContactLog.swift
//  VEP
//
//  Created by Agent 3 on 2025-10-22.
//

import Foundation

/// Contact log model representing voter interactions
struct ContactLog: Codable, Identifiable {
    let id: UUID
    let assignmentId: UUID
    let voterId: UUID
    let userId: UUID?
    let contactType: ContactType
    let result: String?
    let supportLevel: Int?
    let location: Coordinate
    let contactedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case assignmentId = "assignment_id"
        case voterId = "voter_id"
        case userId = "user_id"
        case contactType = "contact_type"
        case result
        case supportLevel = "support_level"
        case location
        case contactedAt = "contacted_at"
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
    
    var icon: String {
        switch self {
        case .knocked: return "hand.raised.fill"
        case .phone: return "phone.fill"
        case .text: return "message.fill"
        case .email: return "envelope.fill"
        case .notHome: return "house.fill"
        case .refused: return "hand.raised.slash.fill"
        case .moved: return "arrow.right.circle.fill"
        case .deceased: return "cross.fill"
        }
    }
}
