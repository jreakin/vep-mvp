/*
 VEP MVP - Services Tests
 
 Unit tests for service layer including:
 - APIClient
 - OfflineStorageService
 - SyncService
 - LocationService
 
 Tests cover:
 - Network requests and error handling
 - Offline data persistence
 - Sync queue management
 - Location tracking
 */

import XCTest
import CoreData
@testable import VEP

// MARK: - APIClient Tests

final class APIClientTests: XCTestCase {
    
    var apiClient: APIClient!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        // TODO: Initialize when Agent 4 completes implementation
        // apiClient = APIClient(urlSession: mockURLSession)
    }
    
    override func tearDown() {
        apiClient = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    func testSetAuthToken() throws {
        // TODO: Implement when Agent 4 completes APIClient
        throw XCTSkip("APIClient implementation pending from Agent 4")
        
        // Given
        let token = "test-jwt-token"
        
        // When
        apiClient.setAuthToken(token)
        
        // Then
        XCTAssertEqual(apiClient.token, token)
    }
    
    func testGetAssignments_Success() async throws {
        // TODO: Implement when Agent 4 completes APIClient
        throw XCTSkip("APIClient implementation pending from Agent 4")
        
        // Given
        let mockData = """
        {
            "assignments": [
                {
                    "id": "123e4567-e89b-12d3-a456-426614174000",
                    "name": "Test Assignment",
                    "status": "pending",
                    "voter_count": 10,
                    "completed_count": 0
                }
            ]
        }
        """.data(using: .utf8)!
        
        mockURLSession.data = mockData
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        let assignments = try await apiClient.getAssignments()
        
        // Then
        XCTAssertEqual(assignments.count, 1)
        XCTAssertEqual(assignments[0].name, "Test Assignment")
    }
    
    func testGetAssignments_NetworkError() async throws {
        // TODO: Implement when Agent 4 completes APIClient
        throw XCTSkip("APIClient implementation pending from Agent 4")
        
        // Given
        mockURLSession.error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        
        // When/Then
        do {
            _ = try await apiClient.getAssignments()
            XCTFail("Should throw error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testGetAssignments_UnauthorizedError() async throws {
        // TODO: Implement when Agent 4 completes APIClient
        throw XCTSkip("APIClient implementation pending from Agent 4")
        
        // Given
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When/Then
        do {
            _ = try await apiClient.getAssignments()
            XCTFail("Should throw unauthorized error")
        } catch {
            // Verify it's an auth error
            XCTAssertTrue(error is APIError)
        }
    }
    
    func testGetAssignment_Success() async throws {
        // TODO: Implement when Agent 4 completes APIClient
        throw XCTSkip("APIClient implementation pending from Agent 4")
        
        // Given
        let assignmentId = UUID()
        let mockData = """
        {
            "id": "\(assignmentId.uuidString)",
            "name": "Detailed Assignment",
            "voters": [
                {
                    "id": "223e4567-e89b-12d3-a456-426614174000",
                    "voter_id": "TX12345678",
                    "first_name": "John",
                    "last_name": "Doe"
                }
            ]
        }
        """.data(using: .utf8)!
        
        mockURLSession.data = mockData
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        let assignment = try await apiClient.getAssignment(id: assignmentId)
        
        // Then
        XCTAssertEqual(assignment.id, assignmentId)
        XCTAssertEqual(assignment.voters?.count, 1)
    }
    
    func testCreateContactLog_Success() async throws {
        // TODO: Implement when Agent 4 completes APIClient
        throw XCTSkip("APIClient implementation pending from Agent 4")
        
        // Given
        let contactLog = ContactLog(
            id: UUID(),
            assignmentId: UUID(),
            voterId: UUID(),
            contactType: .knocked,
            result: "Strong supporter",
            supportLevel: 5,
            location: Coordinate(latitude: 30.2672, longitude: -97.7431),
            contactedAt: Date()
        )
        
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 201,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        let created = try await apiClient.createContactLog(contactLog)
        
        // Then
        XCTAssertEqual(created.id, contactLog.id)
    }
}

// MARK: - OfflineStorageService Tests

final class OfflineStorageServiceTests: XCTestCase {
    
    var storageService: OfflineStorageService!
    var testContainer: NSPersistentContainer!
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory Core Data store for testing
        testContainer = NSPersistentContainer(name: "VEP")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        testContainer.persistentStoreDescriptions = [description]
        
        testContainer.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        
        // TODO: Initialize when Agent 4 completes implementation
        // storageService = OfflineStorageService(container: testContainer)
    }
    
    override func tearDown() {
        storageService = nil
        testContainer = nil
        super.tearDown()
    }
    
    func testCacheAssignment() throws {
        // TODO: Implement when Agent 4 completes OfflineStorageService
        throw XCTSkip("OfflineStorageService implementation pending from Agent 4")
        
        // Given
        let assignment = Assignment(
            id: UUID(),
            name: "Test Assignment",
            description: "Cache test",
            assignedDate: Date(),
            dueDate: nil,
            status: .pending,
            voterCount: 5,
            completedCount: 0
        )
        
        // When
        storageService.cacheAssignment(assignment)
        
        // Then
        let cached = storageService.getCachedAssignment(id: assignment.id)
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.id, assignment.id)
        XCTAssertEqual(cached?.name, assignment.name)
    }
    
    func testQueueContactLog() throws {
        // TODO: Implement when Agent 4 completes OfflineStorageService
        throw XCTSkip("OfflineStorageService implementation pending from Agent 4")
        
        // Given
        let contactLog = ContactLog(
            id: UUID(),
            assignmentId: UUID(),
            voterId: UUID(),
            contactType: .knocked,
            result: "Test",
            supportLevel: nil,
            location: Coordinate(latitude: 30.0, longitude: -97.0),
            contactedAt: Date()
        )
        
        // When
        storageService.queueContactLog(contactLog)
        
        // Then
        let pending = storageService.getPendingLogs()
        XCTAssertEqual(pending.count, 1)
        XCTAssertEqual(pending[0].id, contactLog.id)
    }
    
    func testClearSyncedLog() throws {
        // TODO: Implement when Agent 4 completes OfflineStorageService
        throw XCTSkip("OfflineStorageService implementation pending from Agent 4")
        
        // Given
        let contactLog = ContactLog(
            id: UUID(),
            assignmentId: UUID(),
            voterId: UUID(),
            contactType: .knocked,
            result: "Test",
            supportLevel: nil,
            location: Coordinate(latitude: 30.0, longitude: -97.0),
            contactedAt: Date()
        )
        storageService.queueContactLog(contactLog)
        
        // When
        storageService.clearSyncedLog(id: contactLog.id)
        
        // Then
        let pending = storageService.getPendingLogs()
        XCTAssertEqual(pending.count, 0)
    }
    
    func testClearCache() throws {
        // TODO: Implement when Agent 4 completes OfflineStorageService
        throw XCTSkip("OfflineStorageService implementation pending from Agent 4")
        
        // Given
        let assignment = Assignment(
            id: UUID(),
            name: "Test",
            status: .pending,
            voterCount: 1,
            completedCount: 0
        )
        storageService.cacheAssignment(assignment)
        
        // When
        storageService.clearCache()
        
        // Then
        let cached = storageService.getCachedAssignment(id: assignment.id)
        XCTAssertNil(cached)
    }
}

// MARK: - SyncService Tests

final class SyncServiceTests: XCTestCase {
    
    var syncService: SyncService!
    var mockAPIClient: MockAPIClient!
    var mockStorage: MockOfflineStorage!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        mockStorage = MockOfflineStorage()
        // TODO: Initialize when Agent 4 completes implementation
        // syncService = SyncService(apiClient: mockAPIClient, storage: mockStorage)
    }
    
    override func tearDown() {
        syncService = nil
        mockAPIClient = nil
        mockStorage = nil
        super.tearDown()
    }
    
    func testSyncPendingLogs_Success() async throws {
        // TODO: Implement when Agent 4 completes SyncService
        throw XCTSkip("SyncService implementation pending from Agent 4")
        
        // Given
        let pendingLog = ContactLog(
            id: UUID(),
            assignmentId: UUID(),
            voterId: UUID(),
            contactType: .knocked,
            result: "Test",
            supportLevel: nil,
            location: Coordinate(latitude: 30.0, longitude: -97.0),
            contactedAt: Date()
        )
        mockStorage.pendingLogs = [pendingLog]
        
        // When
        await syncService.syncPendingLogs()
        
        // Then
        XCTAssertFalse(syncService.isSyncing)
        XCTAssertEqual(syncService.pendingCount, 0)
        XCTAssertTrue(mockAPIClient.createContactLogCalled)
    }
    
    func testSyncPendingLogs_NetworkFailure() async throws {
        // TODO: Implement when Agent 4 completes SyncService
        throw XCTSkip("SyncService implementation pending from Agent 4")
        
        // Given
        mockAPIClient.shouldFail = true
        mockStorage.pendingLogs = [
            ContactLog(
                id: UUID(),
                assignmentId: UUID(),
                voterId: UUID(),
                contactType: .knocked,
                result: "Test",
                supportLevel: nil,
                location: Coordinate(latitude: 30.0, longitude: -97.0),
                contactedAt: Date()
            )
        ]
        
        // When
        await syncService.syncPendingLogs()
        
        // Then
        XCTAssertFalse(syncService.isSyncing)
        XCTAssertEqual(syncService.pendingCount, 1) // Should still have pending
    }
    
    func testAutoSync() async throws {
        // TODO: Implement when Agent 4 completes SyncService
        throw XCTSkip("SyncService implementation pending from Agent 4")
        
        // When
        syncService.startAutoSync(interval: 1.0)
        
        // Then
        XCTAssertTrue(syncService.isAutoSyncEnabled)
        
        // Cleanup
        syncService.stopAutoSync()
        XCTAssertFalse(syncService.isAutoSyncEnabled)
    }
}

// MARK: - LocationService Tests

final class LocationServiceTests: XCTestCase {
    
    var locationService: LocationService!
    
    override func setUp() {
        super.setUp()
        // TODO: Initialize when Agent 4 completes implementation
        // locationService = LocationService()
    }
    
    func testRequestLocationPermission() throws {
        // TODO: Implement when Agent 4 completes LocationService
        throw XCTSkip("LocationService implementation pending from Agent 4")
        
        // When
        locationService.requestPermission()
        
        // Then - In real implementation, would check authorization status
        // For testing, might need to mock CLLocationManager
    }
    
    func testGetCurrentLocation() async throws {
        // TODO: Implement when Agent 4 completes LocationService
        throw XCTSkip("LocationService implementation pending from Agent 4")
        
        // When
        let location = try await locationService.getCurrentLocation()
        
        // Then
        XCTAssertNotNil(location)
    }
}

// MARK: - Mock Objects

class MockURLSession {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        return (data ?? Data(), response ?? URLResponse())
    }
}

class MockOfflineStorage {
    var pendingLogs: [ContactLog] = []
    var cachedAssignments: [UUID: Assignment] = [:]
    
    func getPendingLogs() -> [ContactLog] {
        return pendingLogs
    }
    
    func clearSyncedLog(id: UUID) {
        pendingLogs.removeAll { $0.id == id }
    }
    
    func queueContactLog(_ log: ContactLog) {
        pendingLogs.append(log)
    }
    
    func cacheAssignment(_ assignment: Assignment) {
        cachedAssignments[assignment.id] = assignment
    }
    
    func getCachedAssignment(id: UUID) -> Assignment? {
        return cachedAssignments[id]
    }
}
