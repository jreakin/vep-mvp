//
//  User.swift
//  VEP
//
//  Created by Agent 3 on 2025-10-22.
//

import Foundation

/// User model representing campaign staff members
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
    
    var displayName: String {
        switch self {
        case .admin: return "Admin"
        case .manager: return "Manager"
        case .canvasser: return "Canvasser"
        }
    }
}
