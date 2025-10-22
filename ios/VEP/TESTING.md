# Testing Guide for VEP iOS Integration Layer

This guide covers testing strategies for the service layer and ViewModels.

## Testing Overview

### Test Types

1. **Unit Tests** - Test individual components in isolation
2. **Integration Tests** - Test service interactions
3. **UI Tests** - Test user workflows
4. **Manual Tests** - Test offline/online scenarios

## Unit Testing

### Testing Models

Models are simple data structures, test JSON encoding/decoding:

```swift
import XCTest
@testable import VEP

class VoterTests: XCTestCase {
    func testVoterDecoding() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "voter_id": "TX12345",
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
            "support_level": 4
        }
        """.data(using: .utf8)!
        
        let voter = try JSONDecoder().decode(Voter.self, from: json)
        
        XCTAssertEqual(voter.firstName, "John")
        XCTAssertEqual(voter.lastName, "Doe")
        XCTAssertEqual(voter.fullName, "John Doe")
        XCTAssertEqual(voter.supportLevel, 4)
    }
    
    func testVoterEncoding() throws {
        let coordinate = Coordinate(latitude: 30.2672, longitude: -97.7431)
        let voter = Voter(
            id: UUID(),
            voterId: "TX12345",
            firstName: "John",
            lastName: "Doe",
            address: "123 Main St",
            city: "Austin",
            state: "TX",
            zip: "78701",
            location: coordinate,
            partyAffiliation: "D",
            supportLevel: 4,
            phone: nil,
            email: nil
        )
        
        let data = try JSONEncoder().encode(voter)
        let decoded = try JSONDecoder().decode(Voter.self, from: data)
        
        XCTAssertEqual(voter.id, decoded.id)
        XCTAssertEqual(voter.fullName, decoded.fullName)
    }
}
```

### Testing Services

Create mock services for testing:

```swift
import XCTest
@testable import VEP

class MockAPIClient: APIClient {
    var shouldFail = false
    var mockAssignments: [Assignment] = []
    
    override func getAssignments() async throws -> [Assignment] {
        if shouldFail {
            throw APIError.networkError(NSError(domain: "test", code: -1))
        }
        return mockAssignments
    }
}

class APIClientTests: XCTestCase {
    var apiClient: MockAPIClient!
    
    override func setUp() {
        super.setUp()
        apiClient = MockAPIClient()
    }
    
    func testGetAssignmentsSuccess() async throws {
        // Given
        let assignment = Assignment(...)
        apiClient.mockAssignments = [assignment]
        
        // When
        let result = try await apiClient.getAssignments()
        
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].id, assignment.id)
    }
    
    func testGetAssignmentsFailure() async {
        // Given
        apiClient.shouldFail = true
        
        // When/Then
        do {
            _ = try await apiClient.getAssignments()
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertTrue(error is APIError)
        }
    }
}
```

### Testing Offline Storage

Test Core Data operations:

```swift
import XCTest
import CoreData
@testable import VEP

class OfflineStorageTests: XCTestCase {
    var storage: OfflineStorageService!
    
    override func setUp() async throws {
        await super.setUp()
        storage = await OfflineStorageService.shared
        try await storage.clearAllCache()
    }
    
    func testCacheAssignment() async throws {
        // Given
        let assignment = Assignment(...)
        
        // When
        try await storage.cacheAssignment(assignment)
        
        // Then
        let cached = try await storage.getCachedAssignment(id: assignment.id)
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.id, assignment.id)
    }
    
    func testQueueContactLog() async throws {
        // Given
        let log = ContactLog(...)
        
        // When
        try await storage.queueContactLog(log)
        
        // Then
        let pending = try await storage.getPendingLogs()
        XCTAssertEqual(pending.count, 1)
        XCTAssertEqual(pending[0].id, log.id)
    }
    
    func testMarkLogAsSynced() async throws {
        // Given
        let log = ContactLog(...)
        try await storage.queueContactLog(log)
        
        // When
        try await storage.markLogAsSynced(id: log.id)
        
        // Then
        let pending = try await storage.getPendingLogs()
        XCTAssertEqual(pending.count, 0)
    }
}
```

### Testing ViewModels

Test ViewModel logic with mocked services:

```swift
import XCTest
@testable import VEP

@MainActor
class AssignmentListViewModelTests: XCTestCase {
    var viewModel: AssignmentListViewModel!
    var mockAPI: MockAPIClient!
    
    override func setUp() async throws {
        await super.setUp()
        viewModel = AssignmentListViewModel()
        mockAPI = MockAPIClient()
        // Inject mock (would need to modify ViewModel for dependency injection)
    }
    
    func testLoadAssignmentsSuccess() async throws {
        // Given
        let assignment = Assignment(...)
        mockAPI.mockAssignments = [assignment]
        
        // When
        await viewModel.loadAssignments()
        
        // Then
        XCTAssertEqual(viewModel.assignments.count, 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFilterByStatus() {
        // Given
        viewModel.assignments = [
            Assignment(..., status: .pending),
            Assignment(..., status: .completed)
        ]
        
        // When
        viewModel.filterByStatus(.pending)
        
        // Then
        XCTAssertEqual(viewModel.filteredAssignments.count, 1)
        XCTAssertEqual(viewModel.filteredAssignments[0].status, .pending)
    }
}
```

## Integration Testing

Test service interactions:

```swift
import XCTest
@testable import VEP

class IntegrationTests: XCTestCase {
    func testOfflineSyncFlow() async throws {
        let storage = await OfflineStorageService.shared
        let syncService = await SyncService.shared
        
        // 1. Queue a contact log offline
        let log = ContactLog(...)
        try await storage.queueContactLog(log)
        
        // 2. Verify it's pending
        let pending = try await storage.getPendingLogs()
        XCTAssertEqual(pending.count, 1)
        
        // 3. Sync when online
        await syncService.syncPendingLogs()
        
        // 4. Verify it's been synced
        let stillPending = try await storage.getPendingLogs()
        XCTAssertEqual(stillPending.count, 0)
    }
}
```

## Manual Testing Scenarios

### Scenario 1: Offline Functionality

**Steps:**
1. Enable Airplane Mode
2. Open app
3. Navigate to assignments list
4. Verify cached assignments load
5. Open an assignment
6. Log a contact
7. Verify contact is queued (pending indicator)
8. Disable Airplane Mode
9. Verify automatic sync occurs
10. Check pending count goes to 0

**Expected:**
- App works fully offline
- Data loads from cache
- Contact logs queue locally
- Auto-sync when online

### Scenario 2: Location Tracking

**Steps:**
1. First launch - location permission prompt
2. Grant "While Using App" permission
3. Navigate to walk list
4. Start canvassing
5. Log contacts at different locations
6. Verify location is captured

**Expected:**
- Permission requested once
- Current location shown
- Each contact has location data

### Scenario 3: Sync Retry Logic

**Steps:**
1. Queue multiple contact logs offline
2. Go online with poor connection
3. Observe sync attempts
4. Verify retry with backoff
5. Check all logs eventually sync

**Expected:**
- Failed logs retry automatically
- Exponential backoff (1s, 2s, 4s)
- Eventually all sync

### Scenario 4: Network Transitions

**Steps:**
1. Start online
2. Load assignments
3. Go offline mid-session
4. Continue using app
5. Come back online
6. Verify seamless transition

**Expected:**
- No crashes during transition
- Offline indicator appears
- Pending count updates
- Auto-sync on reconnect

## Performance Testing

### Test Large Datasets

```swift
func testLargeAssignmentList() async throws {
    // Create 1000 assignments
    let assignments = (0..<1000).map { i in
        Assignment(
            id: UUID(),
            name: "Assignment \(i)",
            ...
        )
    }
    
    // Measure caching performance
    measure {
        for assignment in assignments {
            try? storage.cacheAssignment(assignment)
        }
    }
}
```

### Test Sync Performance

```swift
func testMassiveSync() async throws {
    // Queue 500 contact logs
    let logs = (0..<500).map { i in
        ContactLog(...)
    }
    
    for log in logs {
        try await storage.queueContactLog(log)
    }
    
    // Measure sync time
    let start = Date()
    await syncService.syncPendingLogs()
    let duration = Date().timeIntervalSince(start)
    
    XCTAssertLessThan(duration, 60.0) // Should complete in under 1 minute
}
```

## UI Testing

Use XCUITest for user flow testing:

```swift
import XCTest

class VEPUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testCanvassFlow() {
        // Login
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("test@example.com")
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("password")
        app.buttons["Login"].tap()
        
        // Select assignment
        app.tables.cells.element(boundBy: 0).tap()
        
        // Start walking
        app.buttons["Start Walking"].tap()
        
        // Log contact
        app.buttons["Log Contact"].tap()
        app.buttons["Knocked"].tap()
        app.buttons["Strong Support"].tap()
        app.buttons["Submit"].tap()
        
        // Verify next voter
        XCTAssertTrue(app.staticTexts["Next Voter"].exists)
    }
}
```

## Test Coverage Goals

- **Models:** 100% (should be easy)
- **Services:** >80%
- **ViewModels:** >70%
- **UI:** Critical paths only

## Continuous Testing

### Pre-commit Tests
```bash
# Run before committing
swift test
```

### CI/CD Pipeline
```yaml
# .github/workflows/ios-tests.yml
name: iOS Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Tests
        run: |
          xcodebuild test \
            -scheme VEP \
            -destination 'platform=iOS Simulator,name=iPhone 14' \
            CODE_SIGNING_ALLOWED=NO
```

## Debugging Tips

1. **Use Breakpoints** in Xcode for stepping through code
2. **Print Statements** for async operations
3. **Network Link Conditioner** for testing poor connections
4. **Instruments** for memory leaks and performance
5. **Console.app** for system logs

## Common Issues

### Issue: Tests timeout
**Solution:** Increase timeout for async operations
```swift
let expectation = XCTestExpectation()
wait(for: [expectation], timeout: 10.0)
```

### Issue: Core Data conflicts
**Solution:** Use separate contexts for testing
```swift
let testContext = NSManagedObjectContext(.memory)
```

### Issue: Network mocking doesn't work
**Solution:** Use URLProtocol for mocking
```swift
class MockURLProtocol: URLProtocol {
    // Mock network responses
}
```

## Next Steps

1. Set up test targets in Xcode
2. Write unit tests for models
3. Write integration tests for services
4. Create UI test suite
5. Set up CI/CD pipeline
6. Achieve target code coverage

Remember: Test offline functionality thoroughly - it's the most critical feature!
