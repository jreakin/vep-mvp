/*
 VEP MVP - ViewModel Tests
 
 Unit tests for all ViewModels including:
 - AssignmentListViewModel
 - WalkListViewModel
 - VoterDetailViewModel
 - ContactFormViewModel
 - AnalyticsViewModel
 
 Tests cover:
 - Data loading and state management
 - User interactions
 - Error handling
 - Async operations
 */

import XCTest
@testable import VEP

// MARK: - AssignmentListViewModel Tests

final class AssignmentListViewModelTests: XCTestCase {
    
    var viewModel: AssignmentListViewModel!
    var mockAPIClient: MockAPIClient!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        // TODO: Initialize when Agent 3 & 4 complete implementation
        // viewModel = AssignmentListViewModel(apiClient: mockAPIClient)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPIClient = nil
        super.tearDown()
    }
    
    func testLoadAssignments_Success() async throws {
        // TODO: Implement when Agent 3 completes ViewModels
        // Given
        let mockAssignments = [
            Assignment(
                id: UUID(),
                name: "Test Assignment 1",
                description: "Test",
                assignedDate: Date(),
                dueDate: nil,
                status: .pending,
                voterCount: 10,
                completedCount: 0
            ),
            Assignment(
                id: UUID(),
                name: "Test Assignment 2",
                description: "Test",
                assignedDate: Date(),
                dueDate: nil,
                status: .inProgress,
                voterCount: 5,
                completedCount: 2
            )
        ]
        mockAPIClient.assignmentsToReturn = mockAssignments
        
        // When
        await viewModel.loadAssignments()
        
        // Then
        XCTAssertEqual(viewModel.assignments.count, 2)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadAssignments_Failure() async throws {
        // TODO: Implement when Agent 3 completes ViewModels
        // Given
        mockAPIClient.shouldFail = true
        
        // When
        await viewModel.loadAssignments()
        
        // Then
        XCTAssertTrue(viewModel.assignments.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testFilterByStatus() throws {
        // TODO: Implement when Agent 3 completes ViewModels
        // Given
        viewModel.assignments = [
            Assignment(id: UUID(), name: "Pending", status: .pending, voterCount: 10, completedCount: 0),
            Assignment(id: UUID(), name: "In Progress", status: .inProgress, voterCount: 5, completedCount: 2),
            Assignment(id: UUID(), name: "Completed", status: .completed, voterCount: 8, completedCount: 8)
        ]
        
        // When
        viewModel.filterByStatus(.pending)
        
        // Then
        XCTAssertEqual(viewModel.filteredAssignments.count, 1)
        XCTAssertEqual(viewModel.filteredAssignments.first?.status, .pending)
    }
    
    func testRefreshAssignments() async throws {
        // TODO: Implement when Agent 3 completes ViewModels
        // When
        await viewModel.refreshAssignments()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(mockAPIClient.getAssignmentsCalled)
    }
}

// MARK: - WalkListViewModel Tests

final class WalkListViewModelTests: XCTestCase {
    
    var viewModel: WalkListViewModel!
    var mockAssignment: Assignment!
    var mockAPIClient: MockAPIClient!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        
        // Create mock assignment with voters
        let voters = (0..<5).map { i in
            Voter(
                id: UUID(),
                voterId: "TX\(1000000 + i)",
                firstName: "Voter\(i)",
                lastName: "Test",
                address: "\(100 + i) Main St",
                city: "Austin",
                state: "TX",
                zip: "78701",
                location: Coordinate(latitude: 30.2672, longitude: -97.7431),
                partyAffiliation: "D",
                supportLevel: 3
            )
        }
        
        mockAssignment = Assignment(
            id: UUID(),
            name: "Test Assignment",
            description: "Walking test",
            assignedDate: Date(),
            dueDate: nil,
            status: .inProgress,
            voterCount: 5,
            completedCount: 0,
            voters: voters
        )
        
        // TODO: Initialize when Agent 3 & 4 complete implementation
        // viewModel = WalkListViewModel(assignment: mockAssignment, apiClient: mockAPIClient)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAssignment = nil
        mockAPIClient = nil
        super.tearDown()
    }
    
    func testCurrentVoter() throws {
        // TODO: Implement when Agent 3 completes ViewModels
        // Then
        XCTAssertNotNil(viewModel.currentVoter)
        XCTAssertEqual(viewModel.currentVoterIndex, 0)
    }
    
    func testNextVoter() throws {
        // TODO: Implement when Agent 3 completes ViewModels
        // Given
        let initialIndex = viewModel.currentVoterIndex
        
        // When
        viewModel.nextVoter()
        
        // Then
        XCTAssertEqual(viewModel.currentVoterIndex, initialIndex + 1)
    }
    
    func testPreviousVoter() throws {
        // TODO: Implement when Agent 3 completes ViewModels
        // Given
        viewModel.currentVoterIndex = 2
        
        // When
        viewModel.previousVoter()
        
        // Then
        XCTAssertEqual(viewModel.currentVoterIndex, 1)
    }
    
    func testProgressCalculation() throws {
        // TODO: Implement when Agent 3 completes ViewModels
        // Given
        XCTAssertEqual(viewModel.progress, 0.0)
        
        // When
        viewModel.markVoterContacted(viewModel.assignment.voters![0].id)
        viewModel.markVoterContacted(viewModel.assignment.voters![1].id)
        
        // Then
        XCTAssertEqual(viewModel.progress, 0.4) // 2/5
        XCTAssertEqual(viewModel.contactedVoters.count, 2)
    }
    
    func testLogContact() async throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        // Given
        let voter = viewModel.currentVoter!
        let contactLog = ContactLog(
            id: UUID(),
            assignmentId: mockAssignment.id,
            voterId: voter.id,
            contactType: .knocked,
            result: "Strong supporter",
            supportLevel: 5,
            location: Coordinate(latitude: 30.2672, longitude: -97.7431),
            contactedAt: Date()
        )
        
        // When
        await viewModel.logContact(contactLog)
        
        // Then
        XCTAssertTrue(viewModel.contactedVoters.contains(voter.id))
        XCTAssertTrue(mockAPIClient.createContactLogCalled)
    }
    
    func testAutoAdvanceAfterContact() async throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        // Given
        let initialIndex = viewModel.currentVoterIndex
        let contactLog = ContactLog(
            id: UUID(),
            assignmentId: mockAssignment.id,
            voterId: viewModel.currentVoter!.id,
            contactType: .knocked,
            result: "Contacted",
            supportLevel: nil,
            location: Coordinate(latitude: 30.2672, longitude: -97.7431),
            contactedAt: Date()
        )
        
        // When
        await viewModel.logContact(contactLog)
        
        // Then - should auto-advance to next voter
        XCTAssertEqual(viewModel.currentVoterIndex, initialIndex + 1)
    }
}

// MARK: - VoterDetailViewModel Tests

final class VoterDetailViewModelTests: XCTestCase {
    
    var viewModel: VoterDetailViewModel!
    var mockVoter: Voter!
    var mockAPIClient: MockAPIClient!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        
        mockVoter = Voter(
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
        
        // TODO: Initialize when Agent 3 & 4 complete implementation
        // viewModel = VoterDetailViewModel(voter: mockVoter, apiClient: mockAPIClient)
    }
    
    func testLoadContactHistory() async throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        // Given
        let mockContacts = [
            ContactLog(
                id: UUID(),
                assignmentId: UUID(),
                voterId: mockVoter.id,
                contactType: .knocked,
                result: "Strong supporter",
                supportLevel: 5,
                location: mockVoter.location,
                contactedAt: Date()
            )
        ]
        mockAPIClient.contactHistoryToReturn = mockContacts
        
        // When
        await viewModel.loadContactHistory()
        
        // Then
        XCTAssertEqual(viewModel.contactHistory.count, 1)
        XCTAssertFalse(viewModel.isLoading)
    }
}

// MARK: - ContactFormViewModel Tests

final class ContactFormViewModelTests: XCTestCase {
    
    var viewModel: ContactFormViewModel!
    
    override func setUp() {
        super.setUp()
        // TODO: Initialize when Agent 3 completes ViewModels
        // viewModel = ContactFormViewModel()
    }
    
    func testContactTypeSelection() throws {
        // TODO: Implement when Agent 3 completes ViewModels
        // When
        viewModel.selectedContactType = .phone
        
        // Then
        XCTAssertEqual(viewModel.selectedContactType, .phone)
    }
    
    func testFormValidation() throws {
        // TODO: Implement when Agent 3 completes ViewModels
        // Given - Empty form
        XCTAssertFalse(viewModel.isValid)
        
        // When - Fill required fields
        viewModel.selectedContactType = .knocked
        viewModel.result = "Contacted"
        
        // Then
        XCTAssertTrue(viewModel.isValid)
    }
}

// MARK: - Mock Objects

class MockAPIClient {
    var assignmentsToReturn: [Assignment] = []
    var contactHistoryToReturn: [ContactLog] = []
    var shouldFail = false
    var getAssignmentsCalled = false
    var createContactLogCalled = false
    
    func getAssignments() async throws -> [Assignment] {
        getAssignmentsCalled = true
        if shouldFail {
            throw NSError(domain: "TestError", code: 1)
        }
        return assignmentsToReturn
    }
    
    func createContactLog(_ log: ContactLog) async throws -> ContactLog {
        createContactLogCalled = true
        if shouldFail {
            throw NSError(domain: "TestError", code: 1)
        }
        return log
    }
    
    func getContactHistory(voterId: UUID) async throws -> [ContactLog] {
        if shouldFail {
            throw NSError(domain: "TestError", code: 1)
        }
        return contactHistoryToReturn
    }
}
