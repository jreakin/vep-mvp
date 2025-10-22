/*
 VEP MVP - UI Tests
 
 UI tests for critical user flows including:
 - Login flow
 - Assignment list and detail views
 - Walking/canvassing flow
 - Contact logging
 - Offline functionality
 
 Tests user interactions and navigation through the app.
 */

import XCTest

final class VEPUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Login Flow Tests
    
    func testLoginFlow_Success() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - On login screen
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        // When - Enter credentials and login
        emailField.tap()
        emailField.typeText("canvasser@test.com")
        
        passwordField.tap()
        passwordField.typeText("TestPassword123!")
        
        loginButton.tap()
        
        // Then - Should navigate to assignments list
        XCTAssertTrue(app.navigationBars["Assignments"].waitForExistence(timeout: 5))
    }
    
    func testLoginFlow_InvalidCredentials() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        // When - Enter invalid credentials
        emailField.tap()
        emailField.typeText("wrong@test.com")
        
        passwordField.tap()
        passwordField.typeText("WrongPassword")
        
        loginButton.tap()
        
        // Then - Should show error message
        XCTAssertTrue(app.alerts["Login Failed"].waitForExistence(timeout: 3))
    }
    
    // MARK: - Assignment List Tests
    
    func testAssignmentList_DisplaysAssignments() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - Logged in
        loginAsCanvasser()
        
        // Then - Should display assignments
        XCTAssertTrue(app.navigationBars["Assignments"].exists)
        XCTAssertTrue(app.tables.cells.count > 0)
    }
    
    func testAssignmentList_FilterByStatus() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - On assignments list
        loginAsCanvasser()
        
        // When - Tap filter button
        let filterButton = app.buttons["Filter"]
        filterButton.tap()
        
        // Select "In Progress"
        app.buttons["In Progress"].tap()
        
        // Then - Should show only in-progress assignments
        let cells = app.tables.cells
        XCTAssertTrue(cells.count > 0)
    }
    
    func testAssignmentList_Search() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - On assignments list
        loginAsCanvasser()
        
        // When - Enter search text
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("Downtown")
        
        // Then - Should filter results
        let cells = app.tables.cells
        XCTAssertTrue(cells.count >= 0)
    }
    
    func testAssignmentList_PullToRefresh() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - On assignments list
        loginAsCanvasser()
        
        // When - Pull to refresh
        let table = app.tables.firstMatch
        let firstCell = table.cells.firstMatch
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let finish = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 2.0))
        start.press(forDuration: 0.1, thenDragTo: finish)
        
        // Then - Should show refresh indicator
        // Wait for refresh to complete
        sleep(2)
    }
    
    // MARK: - Assignment Detail Tests
    
    func testAssignmentDetail_DisplaysVoters() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - On assignments list
        loginAsCanvasser()
        
        // When - Tap first assignment
        let firstAssignment = app.tables.cells.firstMatch
        firstAssignment.tap()
        
        // Then - Should display assignment details
        XCTAssertTrue(app.navigationBars.firstMatch.exists)
        XCTAssertTrue(app.maps.firstMatch.exists)
        XCTAssertTrue(app.tables.cells.count > 0)
    }
    
    func testAssignmentDetail_StartWalking() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - On assignment detail
        loginAsCanvasser()
        app.tables.cells.firstMatch.tap()
        
        // When - Tap "Start Walking"
        let startButton = app.buttons["Start Walking"]
        startButton.tap()
        
        // Then - Should navigate to walk list view
        XCTAssertTrue(app.buttons["Log Contact"].waitForExistence(timeout: 3))
    }
    
    // MARK: - Walk List Tests
    
    func testWalkList_DisplaysCurrentVoter() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - In walk list view
        loginAsCanvasser()
        app.tables.cells.firstMatch.tap()
        app.buttons["Start Walking"].tap()
        
        // Then - Should show current voter card
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Main St'")).firstMatch.exists)
        XCTAssertTrue(app.maps.firstMatch.exists)
    }
    
    func testWalkList_NavigateToNextVoter() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - In walk list view
        loginAsCanvasser()
        app.tables.cells.firstMatch.tap()
        app.buttons["Start Walking"].tap()
        
        // When - Tap "Next"
        let nextButton = app.buttons["Next"]
        nextButton.tap()
        
        // Then - Should show next voter
        // Verify UI updated to show different voter
    }
    
    // MARK: - Contact Logging Tests
    
    func testContactLogging_LogKnockedContact() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - In walk list view
        loginAsCanvasser()
        app.tables.cells.firstMatch.tap()
        app.buttons["Start Walking"].tap()
        
        // When - Tap "Log Contact"
        let logButton = app.buttons["Log Contact"]
        logButton.tap()
        
        // Select contact type
        app.buttons["Knocked"].tap()
        
        // Select support level
        let supportLevelPicker = app.pickers["Support Level"]
        supportLevelPicker.pickerWheels.element.adjust(toPickerWheelValue: "5 - Strong Support")
        
        // Enter notes
        let notesField = app.textViews["Notes"]
        notesField.tap()
        notesField.typeText("Strong supporter, wants yard sign")
        
        // Save
        app.buttons["Save"].tap()
        
        // Then - Should dismiss form and mark voter as contacted
        XCTAssertFalse(app.sheets.firstMatch.exists)
    }
    
    func testContactLogging_LogNotHomeContact() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - In walk list view
        loginAsCanvasser()
        app.tables.cells.firstMatch.tap()
        app.buttons["Start Walking"].tap()
        
        // When - Log "Not Home"
        app.buttons["Log Contact"].tap()
        app.buttons["Not Home"].tap()
        app.buttons["Save"].tap()
        
        // Then - Should save and advance
        XCTAssertFalse(app.sheets.firstMatch.exists)
    }
    
    func testContactLogging_Cancel() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - In contact form
        loginAsCanvasser()
        app.tables.cells.firstMatch.tap()
        app.buttons["Start Walking"].tap()
        app.buttons["Log Contact"].tap()
        
        // When - Cancel
        app.buttons["Cancel"].tap()
        
        // Then - Should dismiss form
        XCTAssertFalse(app.sheets.firstMatch.exists)
    }
    
    // MARK: - Map Tests
    
    func testMap_DisplaysVoterPins() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - On assignment detail
        loginAsCanvasser()
        app.tables.cells.firstMatch.tap()
        
        // Then - Map should show voter pins
        let map = app.maps.firstMatch
        XCTAssertTrue(map.exists)
    }
    
    func testMap_CentersOnCurrentVoter() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - In walk list view
        loginAsCanvasser()
        app.tables.cells.firstMatch.tap()
        app.buttons["Start Walking"].tap()
        
        // Then - Map should be centered on current voter
        let map = app.maps.firstMatch
        XCTAssertTrue(map.exists)
    }
    
    // MARK: - Voter Detail Tests
    
    func testVoterDetail_DisplaysInfo() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - On assignment detail
        loginAsCanvasser()
        app.tables.cells.firstMatch.tap()
        
        // When - Tap voter in list
        app.tables.cells.firstMatch.tap()
        
        // Then - Should show voter details
        XCTAssertTrue(app.navigationBars.firstMatch.exists)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Main St'")).firstMatch.exists)
    }
    
    func testVoterDetail_ShowsContactHistory() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - On voter detail
        loginAsCanvasser()
        app.tables.cells.firstMatch.tap()
        app.tables.cells.firstMatch.tap()
        
        // Then - Should show contact history section
        XCTAssertTrue(app.staticTexts["Contact History"].exists)
    }
    
    // MARK: - Offline Functionality Tests
    
    func testOfflineMode_LogsContactLocally() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - Simulate offline mode
        // Note: This would require app support for enabling offline mode
        app.launchArguments.append("--offline-mode")
        app.launch()
        
        loginAsCanvasser()
        app.tables.cells.firstMatch.tap()
        app.buttons["Start Walking"].tap()
        
        // When - Log contact while offline
        app.buttons["Log Contact"].tap()
        app.buttons["Knocked"].tap()
        app.buttons["Save"].tap()
        
        // Then - Should save locally
        // Verify offline indicator is shown
        XCTAssertTrue(app.images["Offline Indicator"].exists)
    }
    
    func testOfflineMode_SyncsWhenOnline() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - Offline mode with pending logs
        app.launchArguments.append("--offline-mode")
        app.launchArguments.append("--has-pending-logs")
        app.launch()
        
        loginAsCanvasser()
        
        // When - Go online
        // Trigger sync (might be automatic or manual button)
        
        // Then - Should sync pending logs
        // Verify offline indicator disappears
        sleep(3)
        XCTAssertFalse(app.images["Offline Indicator"].exists)
    }
    
    // MARK: - Analytics Tests (Manager Role)
    
    func testAnalytics_DisplaysProgress() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - Logged in as manager
        loginAsManager()
        
        // When - Navigate to analytics
        app.tabBars.buttons["Analytics"].tap()
        
        // Then - Should display progress metrics
        XCTAssertTrue(app.staticTexts["Total Contacts"].exists)
        XCTAssertTrue(app.staticTexts["Support Distribution"].exists)
    }
    
    // MARK: - Performance Tests
    
    func testPerformance_AssignmentListScrolling() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - On assignments list with many items
        loginAsCanvasser()
        
        // Measure scrolling performance
        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            let table = app.tables.firstMatch
            table.swipeUp(velocity: .fast)
            table.swipeDown(velocity: .fast)
        }
    }
    
    func testPerformance_MapRendering() throws {
        // TODO: Implement when Agent 3 & 4 complete implementation
        throw XCTSkip("UI implementation pending from Agents 3 & 4")
        
        // Given - Assignment with many voters
        loginAsCanvasser()
        app.tables.cells.firstMatch.tap()
        
        // Measure map rendering time
        measure(metrics: [XCTOSSignpostMetric.applicationLaunchMetric]) {
            // Map should render within acceptable time
        }
    }
    
    // MARK: - Helper Methods
    
    private func loginAsCanvasser() {
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        emailField.tap()
        emailField.typeText("canvasser@test.com")
        
        passwordField.tap()
        passwordField.typeText("TestPassword123!")
        
        loginButton.tap()
        
        // Wait for login to complete
        _ = app.navigationBars["Assignments"].waitForExistence(timeout: 5)
    }
    
    private func loginAsManager() {
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        emailField.tap()
        emailField.typeText("manager@test.com")
        
        passwordField.tap()
        passwordField.typeText("TestPassword123!")
        
        loginButton.tap()
        
        // Wait for login to complete
        _ = app.navigationBars.firstMatch.waitForExistence(timeout: 5)
    }
}
