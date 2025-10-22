# VEP iOS Test Suite

Comprehensive test suite for the VEP iOS application covering ViewModels, Services, Models, and UI flows.

## Overview

This test suite provides **1,660+ lines** of test code covering:
- **ViewModels**: State management and business logic
- **Services**: API client, offline storage, sync, and location
- **Models**: Data structures and Codable conformance
- **UI Tests**: Complete user flows and interactions

## Test Structure

```
ios/VEPTests/
├── ViewModelsTests.swift   # ViewModel unit tests (340+ lines)
├── ServicesTests.swift     # Service layer tests (380+ lines)
├── ModelsTests.swift       # Model and Codable tests (490+ lines)
└── UITests.swift          # UI and integration tests (450+ lines)
```

## Running Tests

### In Xcode

1. Open `VEP.xcodeproj`
2. Press `Cmd+U` to run all tests
3. Use Test Navigator (`Cmd+6`) to run specific tests
4. View test results in the Report Navigator (`Cmd+9`)

### Command Line

```bash
# Run all unit tests
xcodebuild test \
  -scheme VEP \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' \
  -enableCodeCoverage YES \
  -derivedDataPath DerivedData

# Run specific test class
xcodebuild test \
  -scheme VEP \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' \
  -only-testing:VEPTests/AssignmentListViewModelTests

# Run UI tests only
xcodebuild test \
  -scheme VEP \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' \
  -only-testing:VEPUITests

# Generate coverage report
xcrun xccov view --report --json DerivedData/Logs/Test/*.xcresult > coverage.json
```

### Test Targets

- **VEPTests**: Unit and integration tests
- **VEPUITests**: UI automation tests

## Test Coverage

### ViewModels Tests

**File**: `ViewModelsTests.swift`

Tests for all ViewModels including:

- **AssignmentListViewModel**
  - Loading assignments (success/failure)
  - Filtering by status
  - Searching assignments
  - Refreshing data

- **WalkListViewModel**
  - Current voter display
  - Navigation (next/previous)
  - Progress tracking
  - Contact logging
  - Auto-advance after contact

- **VoterDetailViewModel**
  - Voter information display
  - Contact history loading

- **ContactFormViewModel**
  - Contact type selection
  - Form validation
  - Support level selection

**Coverage Goal**: >80%

### Services Tests

**File**: `ServicesTests.swift`

Tests for service layer:

- **APIClient**
  - Authentication token management
  - GET requests (assignments, voters)
  - POST requests (contact logs)
  - Error handling (network, auth, parsing)

- **OfflineStorageService**
  - Caching assignments to Core Data
  - Queuing contact logs
  - Retrieving cached data
  - Clearing sync queue

- **SyncService**
  - Syncing pending logs
  - Handling network failures
  - Auto-sync scheduling
  - Sync status tracking

- **LocationService**
  - Permission requests
  - Current location retrieval
  - Location updates

**Coverage Goal**: >70%

### Models Tests

**File**: `ModelsTests.swift`

Tests for data models:

- **User Model**
  - Initialization
  - Role enum validation
  - Codable conformance

- **Voter Model**
  - Full name computed property
  - Support level validation (1-5)
  - Location coordinate encoding/decoding

- **Assignment Model**
  - Status enum (pending/in_progress/completed/cancelled)
  - Voter relationship
  - Date handling

- **ContactLog Model**
  - Contact type enum and display names
  - Optional fields (result, support_level)
  - Location capture

- **JSON Parsing**
  - Backend API response parsing
  - Snake case to camel case conversion
  - ISO8601 date parsing

**Coverage Goal**: >85%

### UI Tests

**File**: `UITests.swift`

End-to-end user flow tests:

- **Login Flow**
  - Successful login
  - Invalid credentials handling
  - Token persistence

- **Assignment List**
  - Displaying assignments
  - Filtering by status
  - Searching
  - Pull-to-refresh

- **Assignment Detail**
  - Voter list display
  - Map with pins
  - Starting walk mode

- **Walk List**
  - Current voter card
  - Navigation (next/previous)
  - Map centering
  - Progress indicator

- **Contact Logging**
  - Knocked contact
  - Not home contact
  - Refused contact
  - Support level selection
  - Notes entry
  - Form cancellation

- **Offline Functionality**
  - Logging contacts offline
  - Sync when online
  - Offline indicator

- **Performance**
  - List scrolling
  - Map rendering

**Coverage Goal**: >60% (UI tests focus on critical paths)

## Mock Objects

### MockAPIClient

Simulates API responses for testing ViewModels without network calls:

```swift
class MockAPIClient {
    var assignmentsToReturn: [Assignment] = []
    var shouldFail = false
    var getAssignmentsCalled = false
    
    func getAssignments() async throws -> [Assignment] {
        getAssignmentsCalled = true
        if shouldFail {
            throw APIError.networkError
        }
        return assignmentsToReturn
    }
}
```

### MockOfflineStorage

Simulates Core Data storage for testing sync logic:

```swift
class MockOfflineStorage {
    var pendingLogs: [ContactLog] = []
    var cachedAssignments: [UUID: Assignment] = [:]
    
    func queueContactLog(_ log: ContactLog) {
        pendingLogs.append(log)
    }
    
    func getPendingLogs() -> [ContactLog] {
        return pendingLogs
    }
}
```

## Test Data

### Sample Assignment

```swift
let mockAssignment = Assignment(
    id: UUID(),
    name: "Downtown Austin - Oct 22",
    description: "Residential walk list",
    assignedDate: Date(),
    dueDate: Date().addingTimeInterval(86400),
    status: .pending,
    voterCount: 25,
    completedCount: 0,
    voters: sampleVoters
)
```

### Sample Voter

```swift
let mockVoter = Voter(
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
```

## CI/CD Integration

### Automated Testing

Tests run automatically via GitHub Actions:

**Workflow**: `.github/workflows/ios-tests.yml`

**Triggers:**
- Pull requests to `main` or `develop`
- Pushes to `main` or `develop`
- Changes to `ios/**` files

**Steps:**
1. Set up Xcode 15.0 on macOS runner
2. Cache Swift Package Manager dependencies
3. Resolve package dependencies
4. Run unit tests with coverage
5. Run UI tests
6. Generate coverage reports
7. Upload to Codecov
8. Build for simulator and device

### Coverage Reports

Coverage is uploaded to Codecov and displayed in PR comments.

## Best Practices

### Writing Tests

1. **Use descriptive names**: `testLoadAssignments_Success()`
2. **Follow Given-When-Then**: Arrange, Act, Assert
3. **Test one behavior**: Each test should verify one thing
4. **Use XCTSkip()**: Skip tests waiting for implementation
5. **Mock dependencies**: Use MockAPIClient, not real network
6. **Test async code**: Use `async throws` and `await`
7. **Test edge cases**: Include error handling and boundary conditions

### Example Test

```swift
func testLoadAssignments_Success() async throws {
    // Given
    let mockAssignments = [
        Assignment(id: UUID(), name: "Test", status: .pending, voterCount: 10, completedCount: 0)
    ]
    mockAPIClient.assignmentsToReturn = mockAssignments
    
    // When
    await viewModel.loadAssignments()
    
    // Then
    XCTAssertEqual(viewModel.assignments.count, 1)
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertNil(viewModel.errorMessage)
}
```

## Test Implementation Status

All tests are **written and ready** but currently marked with `throw XCTSkip()` pending implementation from Agents 3 & 4.

| Test Suite | Lines | Status | When Ready |
|------------|-------|--------|------------|
| ViewModelsTests | 340+ | ⏸️ Ready | Remove `XCTSkip()` |
| ServicesTests | 380+ | ⏸️ Ready | Remove `XCTSkip()` |
| ModelsTests | 490+ | ⏸️ Ready | Remove `XCTSkip()` |
| UITests | 450+ | ⏸️ Ready | Remove `XCTSkip()` |

### Activating Tests

Once Agents 3 & 4 complete implementation:

1. **Remove skip statements**: Delete `throw XCTSkip("...")` lines
2. **Verify imports**: Ensure `@testable import VEP` works
3. **Update mocks**: Adjust mocks if API signatures changed
4. **Run tests**: Execute `Cmd+U` in Xcode
5. **Fix failures**: Address any API changes
6. **Check coverage**: Ensure >70% coverage goal is met

## Performance Benchmarks

Expected performance for tests:

- **ViewModel tests**: <1s per test
- **Service tests**: <2s per test (with mocks)
- **Model tests**: <0.5s per test
- **UI tests**: <30s per test

Total test suite should complete in <5 minutes.

## Troubleshooting

### Common Issues

**Issue**: "No such module 'VEP'"
```
Solution: Ensure scheme is set to VEP and build succeeds before testing
```

**Issue**: Simulator not booting
```bash
# Kill stuck simulators
pkill -9 Simulator

# Boot fresh simulator
xcrun simctl boot "iPhone 15"
```

**Issue**: Tests timing out
```swift
// Increase timeout for async operations
_ = await fulfillment(of: [expectation], timeout: 10.0)
```

**Issue**: Core Data errors in tests
```swift
// Use in-memory store for tests
let description = NSPersistentStoreDescription()
description.type = NSInMemoryStoreType
```

### Debug Tips

1. **Print statements**: Use `print()` for quick debugging
2. **Breakpoints**: Set breakpoints in test methods
3. **Test console**: View output in Xcode console (Cmd+Shift+Y)
4. **Test report**: Check detailed results in Report Navigator
5. **Coverage report**: View in Report Navigator -> Coverage tab

## Code Coverage

### Viewing Coverage

In Xcode:
1. Run tests with coverage enabled (Cmd+U)
2. Open Report Navigator (Cmd+9)
3. Select test run
4. Click Coverage tab
5. Expand VEP target to see file-level coverage

### Coverage Goals

| Component | Target | Critical Paths |
|-----------|--------|----------------|
| ViewModels | >80% | 100% for WalkListViewModel |
| Services | >70% | 100% for SyncService |
| Models | >85% | 100% for Codable |
| Views | >60% | 100% for ContactFormView |

## Performance Testing

### Metrics Measured

- **Scroll Deceleration**: List scrolling smoothness
- **Launch Metric**: App launch time
- **Memory**: Memory usage during operations
- **Animation**: UI animation performance

### Running Performance Tests

```swift
func testPerformance_AssignmentListScrolling() {
    measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
        // Scroll operations
    }
}
```

## Resources

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Testing iOS Apps](https://developer.apple.com/documentation/xcode/testing-your-apps-in-xcode)
- [UI Testing in Xcode](https://developer.apple.com/documentation/xctest/user_interface_tests)
- [Code Coverage in Xcode](https://developer.apple.com/documentation/xcode/code-coverage)

## Contributing

When adding new features:

1. **Write tests first** (TDD approach)
2. **Maintain coverage** above target thresholds
3. **Use mocks** for external dependencies
4. **Test offline mode** for any sync features
5. **Update this README** with new test information

## Contact

For questions about the iOS test suite, see:
- `.github/copilot/agent-5-testing.md` - Testing agent instructions
- `spec.md` Section 6 - Testing requirements
- `AGENT_INSTRUCTIONS.md` - Agent 5 section
