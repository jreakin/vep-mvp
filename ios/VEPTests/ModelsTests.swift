/*
 VEP MVP - Models Tests
 
 Unit tests for data models including:
 - User
 - Voter
 - Assignment
 - ContactLog
 
 Tests cover:
 - Model initialization
 - Codable conformance (JSON encoding/decoding)
 - Computed properties
 - Validation
 */

import XCTest
@testable import VEP

// MARK: - User Model Tests

final class UserTests: XCTestCase {
    
    func testUserInitialization() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Given
        let id = UUID()
        let email = "test@example.com"
        let fullName = "Test User"
        let role = UserRole.canvasser
        
        // When
        let user = User(
            id: id,
            email: email,
            fullName: fullName,
            role: role,
            phone: "555-1234"
        )
        
        // Then
        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.email, email)
        XCTAssertEqual(user.fullName, fullName)
        XCTAssertEqual(user.role, role)
        XCTAssertEqual(user.phone, "555-1234")
    }
    
    func testUserRoleEnum() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Test all role cases
        XCTAssertEqual(UserRole.admin.rawValue, "admin")
        XCTAssertEqual(UserRole.manager.rawValue, "manager")
        XCTAssertEqual(UserRole.canvasser.rawValue, "canvasser")
    }
    
    func testUserCodable() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Given
        let user = User(
            id: UUID(),
            email: "test@example.com",
            fullName: "Test User",
            role: .manager,
            phone: nil
        )
        
        // When - Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)
        
        // Then - Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(User.self, from: data)
        
        XCTAssertEqual(decoded.id, user.id)
        XCTAssertEqual(decoded.email, user.email)
        XCTAssertEqual(decoded.fullName, user.fullName)
        XCTAssertEqual(decoded.role, user.role)
    }
}

// MARK: - Voter Model Tests

final class VoterTests: XCTestCase {
    
    func testVoterInitialization() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Given/When
        let voter = Voter(
            id: UUID(),
            voterId: "TX12345678",
            firstName: "John",
            lastName: "Doe",
            address: "123 Main St",
            city: "Austin",
            state: "TX",
            zip: "78701",
            location: Coordinate(latitude: 30.2672, longitude: -97.7431),
            partyAffiliation: "D",
            supportLevel: 3
        )
        
        // Then
        XCTAssertEqual(voter.voterId, "TX12345678")
        XCTAssertEqual(voter.firstName, "John")
        XCTAssertEqual(voter.lastName, "Doe")
        XCTAssertEqual(voter.city, "Austin")
        XCTAssertEqual(voter.state, "TX")
        XCTAssertEqual(voter.supportLevel, 3)
    }
    
    func testVoterFullName() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Given
        let voter = Voter(
            id: UUID(),
            voterId: "TX12345678",
            firstName: "Jane",
            lastName: "Smith",
            address: "456 Oak Ave",
            city: "Austin",
            state: "TX",
            zip: "78701",
            location: Coordinate(latitude: 30.2672, longitude: -97.7431),
            partyAffiliation: nil,
            supportLevel: nil
        )
        
        // When/Then
        XCTAssertEqual(voter.fullName, "Jane Smith")
    }
    
    func testVoterCodable() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Given
        let voter = Voter(
            id: UUID(),
            voterId: "TX87654321",
            firstName: "Test",
            lastName: "Voter",
            address: "789 Test Rd",
            city: "Houston",
            state: "TX",
            zip: "77001",
            location: Coordinate(latitude: 29.7604, longitude: -95.3698),
            partyAffiliation: "R",
            supportLevel: 4
        )
        
        // When - Encode
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(voter)
        
        // Then - Decode
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoded = try decoder.decode(Voter.self, from: data)
        
        XCTAssertEqual(decoded.id, voter.id)
        XCTAssertEqual(decoded.voterId, voter.voterId)
        XCTAssertEqual(decoded.supportLevel, voter.supportLevel)
    }
    
    func testSupportLevelValidation() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Support level should be 1-5 or nil
        let validLevels = [1, 2, 3, 4, 5]
        
        for level in validLevels {
            let voter = Voter(
                id: UUID(),
                voterId: "TX\(level)",
                firstName: "Test",
                lastName: "Voter",
                address: "123 St",
                city: "Austin",
                state: "TX",
                zip: "78701",
                location: Coordinate(latitude: 30.0, longitude: -97.0),
                partyAffiliation: nil,
                supportLevel: level
            )
            XCTAssertEqual(voter.supportLevel, level)
        }
    }
}

// MARK: - Coordinate Model Tests

final class CoordinateTests: XCTestCase {
    
    func testCoordinateInitialization() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Given/When
        let coordinate = Coordinate(latitude: 30.2672, longitude: -97.7431)
        
        // Then
        XCTAssertEqual(coordinate.latitude, 30.2672)
        XCTAssertEqual(coordinate.longitude, -97.7431)
    }
    
    func testCoordinateCodable() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Given
        let coordinate = Coordinate(latitude: 40.7128, longitude: -74.0060)
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(coordinate)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Coordinate.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.latitude, coordinate.latitude, accuracy: 0.0001)
        XCTAssertEqual(decoded.longitude, coordinate.longitude, accuracy: 0.0001)
    }
}

// MARK: - Assignment Model Tests

final class AssignmentTests: XCTestCase {
    
    func testAssignmentInitialization() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Given/When
        let assignment = Assignment(
            id: UUID(),
            name: "Morning Walk",
            description: "Residential area",
            assignedDate: Date(),
            dueDate: Date().addingTimeInterval(86400),
            status: .pending,
            voterCount: 25,
            completedCount: 0
        )
        
        // Then
        XCTAssertEqual(assignment.name, "Morning Walk")
        XCTAssertEqual(assignment.status, .pending)
        XCTAssertEqual(assignment.voterCount, 25)
        XCTAssertEqual(assignment.completedCount, 0)
    }
    
    func testAssignmentStatusEnum() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Test all status cases
        XCTAssertEqual(AssignmentStatus.pending.rawValue, "pending")
        XCTAssertEqual(AssignmentStatus.inProgress.rawValue, "in_progress")
        XCTAssertEqual(AssignmentStatus.completed.rawValue, "completed")
        XCTAssertEqual(AssignmentStatus.cancelled.rawValue, "cancelled")
    }
    
    func testAssignmentWithVoters() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Given
        let voters = [
            Voter(
                id: UUID(),
                voterId: "TX1",
                firstName: "Voter",
                lastName: "One",
                address: "1 St",
                city: "Austin",
                state: "TX",
                zip: "78701",
                location: Coordinate(latitude: 30.0, longitude: -97.0),
                partyAffiliation: nil,
                supportLevel: nil
            ),
            Voter(
                id: UUID(),
                voterId: "TX2",
                firstName: "Voter",
                lastName: "Two",
                address: "2 St",
                city: "Austin",
                state: "TX",
                zip: "78701",
                location: Coordinate(latitude: 30.0, longitude: -97.0),
                partyAffiliation: nil,
                supportLevel: nil
            )
        ]
        
        // When
        let assignment = Assignment(
            id: UUID(),
            name: "Test Assignment",
            description: nil,
            assignedDate: Date(),
            dueDate: nil,
            status: .pending,
            voterCount: 2,
            completedCount: 0,
            voters: voters
        )
        
        // Then
        XCTAssertEqual(assignment.voters?.count, 2)
        XCTAssertEqual(assignment.voterCount, 2)
    }
    
    func testAssignmentCodable() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Given
        let assignment = Assignment(
            id: UUID(),
            name: "Test",
            description: "Description",
            assignedDate: Date(),
            dueDate: nil,
            status: .inProgress,
            voterCount: 10,
            completedCount: 5
        )
        
        // When
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(assignment)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Assignment.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.id, assignment.id)
        XCTAssertEqual(decoded.name, assignment.name)
        XCTAssertEqual(decoded.status, assignment.status)
    }
}

// MARK: - ContactLog Model Tests

final class ContactLogTests: XCTestCase {
    
    func testContactLogInitialization() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Given/When
        let contactLog = ContactLog(
            id: UUID(),
            assignmentId: UUID(),
            voterId: UUID(),
            contactType: .knocked,
            result: "Strong supporter, wants yard sign",
            supportLevel: 5,
            location: Coordinate(latitude: 30.2672, longitude: -97.7431),
            contactedAt: Date()
        )
        
        // Then
        XCTAssertEqual(contactLog.contactType, .knocked)
        XCTAssertEqual(contactLog.result, "Strong supporter, wants yard sign")
        XCTAssertEqual(contactLog.supportLevel, 5)
    }
    
    func testContactTypeEnum() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Test all contact type cases
        XCTAssertEqual(ContactType.knocked.rawValue, "knocked")
        XCTAssertEqual(ContactType.phone.rawValue, "phone")
        XCTAssertEqual(ContactType.text.rawValue, "text")
        XCTAssertEqual(ContactType.email.rawValue, "email")
        XCTAssertEqual(ContactType.notHome.rawValue, "not_home")
        XCTAssertEqual(ContactType.refused.rawValue, "refused")
        XCTAssertEqual(ContactType.moved.rawValue, "moved")
        XCTAssertEqual(ContactType.deceased.rawValue, "deceased")
    }
    
    func testContactTypeDisplayName() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Test display names
        XCTAssertEqual(ContactType.knocked.displayName, "Knocked")
        XCTAssertEqual(ContactType.phone.displayName, "Phone")
        XCTAssertEqual(ContactType.notHome.displayName, "Not Home")
        XCTAssertEqual(ContactType.refused.displayName, "Refused")
    }
    
    func testContactTypeCaseIterable() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Test that all cases are iterable
        let allCases = ContactType.allCases
        XCTAssertEqual(allCases.count, 8)
        XCTAssertTrue(allCases.contains(.knocked))
        XCTAssertTrue(allCases.contains(.phone))
        XCTAssertTrue(allCases.contains(.notHome))
    }
    
    func testContactLogCodable() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Given
        let contactLog = ContactLog(
            id: UUID(),
            assignmentId: UUID(),
            voterId: UUID(),
            contactType: .phone,
            result: "Answered, supports candidate",
            supportLevel: 4,
            location: Coordinate(latitude: 30.0, longitude: -97.0),
            contactedAt: Date()
        )
        
        // When
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(contactLog)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(ContactLog.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.id, contactLog.id)
        XCTAssertEqual(decoded.contactType, contactLog.contactType)
        XCTAssertEqual(decoded.supportLevel, contactLog.supportLevel)
    }
    
    func testContactLogOptionalFields() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Given - Contact log with minimal fields
        let contactLog = ContactLog(
            id: UUID(),
            assignmentId: UUID(),
            voterId: UUID(),
            contactType: .notHome,
            result: nil,
            supportLevel: nil,
            location: Coordinate(latitude: 30.0, longitude: -97.0),
            contactedAt: Date()
        )
        
        // Then
        XCTAssertNil(contactLog.result)
        XCTAssertNil(contactLog.supportLevel)
        XCTAssertEqual(contactLog.contactType, .notHome)
    }
}

// MARK: - JSON Parsing Tests

final class JSONParsingTests: XCTestCase {
    
    func testParseVoterFromBackendJSON() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Given - JSON from backend API
        let json = """
        {
            "id": "123e4567-e89b-12d3-a456-426614174000",
            "voter_id": "TX12345678",
            "first_name": "John",
            "last_name": "Doe",
            "address": "123 Main St",
            "city": "Austin",
            "state": "TX",
            "zip": "78701",
            "location": {
                "latitude": 30.2672,
                "longitude": -97.7431
            },
            "party_affiliation": "D",
            "support_level": 3
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let voter = try decoder.decode(Voter.self, from: json)
        
        // Then
        XCTAssertEqual(voter.voterId, "TX12345678")
        XCTAssertEqual(voter.firstName, "John")
        XCTAssertEqual(voter.supportLevel, 3)
    }
    
    func testParseAssignmentFromBackendJSON() throws {
        // TODO: Implement when Agent 3 completes Models
        throw XCTSkip("Model implementation pending from Agent 3")
        
        // Given - JSON from backend API
        let json = """
        {
            "id": "223e4567-e89b-12d3-a456-426614174000",
            "name": "Downtown Austin - Oct 22",
            "description": "Walk list for downtown",
            "assigned_date": "2025-10-22",
            "due_date": "2025-10-25",
            "status": "in_progress",
            "voter_count": 47,
            "completed_count": 12
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let assignment = try decoder.decode(Assignment.self, from: json)
        
        // Then
        XCTAssertEqual(assignment.name, "Downtown Austin - Oct 22")
        XCTAssertEqual(assignment.status, .inProgress)
        XCTAssertEqual(assignment.voterCount, 47)
        XCTAssertEqual(assignment.completedCount, 12)
    }
}
