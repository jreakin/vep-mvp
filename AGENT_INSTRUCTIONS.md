# Multi-Agent Development Instructions

**READ THIS FIRST:** Each agent has a specific role and boundaries. Do NOT modify files outside your designated area.

---

## Agent 1: Database Engineer

### Your Mission
Create the complete PostgreSQL database schema with PostGIS support for the VEP MVP.

### Files You Own
- `backend/migrations/001_initial_schema.sql`

### What You Must Do

1. **Read First:**
   - `spec.md` Section 2 (Database Schema)
   - This file (your section)

2. **Create:** `backend/migrations/001_initial_schema.sql`

3. **Include:**
   - PostGIS extension setup
   - All 5 tables from spec.md exactly as defined:
     - `users`
     - `voters` (with PostGIS geometry column)
     - `assignments`
     - `assignment_voters`
     - `contact_logs`
   - All indexes specified in spec.md
   - All foreign key constraints
   - All check constraints
   - Row Level Security (RLS) policies
   - Database trigger for updating voter support levels
   - Comments explaining each table and design decision

4. **SQL Must:**
   - Run successfully on PostgreSQL 14+
   - Be idempotent (can run multiple times safely)
   - Follow PostgreSQL naming conventions
   - Use proper data types
   - Include `IF NOT EXISTS` where appropriate

### Critical Rules
- ❌ Do NOT add tables not in spec.md
- ❌ Do NOT change column names or types from spec.md
- ❌ Do NOT skip indexes
- ❌ Do NOT skip RLS policies
- ✅ DO add helpful comments
- ✅ DO follow PostgreSQL best practices
- ✅ DO test your SQL syntax

### Example Prompt for Cursor

```
You are Agent 1: Database Engineer.

CRITICAL: Read these files first:
1. spec.md (especially Section 2: Database Schema)
2. AGENT_INSTRUCTIONS.md (Agent 1 section)

Your task:
Create a complete, production-ready SQL migration file at:
backend/migrations/001_initial_schema.sql

Requirements from spec.md Section 2:
- Create PostGIS extension
- Create 5 tables exactly as specified
- Add all indexes from spec.md
- Add all foreign key constraints
- Add check constraints
- Implement RLS policies
- Add trigger for voter support level updates
- Include comments

Generate the complete file now.
```

---

## Agent 2: Backend Engineer

### Your Mission
Build the FastAPI backend with all REST endpoints following the API specification.

### Files You Own
- `backend/app/main.py`
- `backend/app/routes/auth.py`
- `backend/app/routes/assignments.py`
- `backend/app/routes/voters.py`
- `backend/app/routes/contact_logs.py`
- `backend/app/routes/analytics.py`
- `backend/app/models/user.py`
- `backend/app/models/voter.py`
- `backend/app/models/assignment.py`
- `backend/app/models/contact_log.py`
- `backend/app/dependencies.py`
- `backend/app/config.py`

### What You Must Do

1. **Read First:**
   - `spec.md` Section 3 (Backend API Specification)
   - `backend/migrations/001_initial_schema.sql` (Agent 1's work)
   - This file (your section)

2. **Create:**
   - FastAPI application with all routes
   - SQLModel models matching database schema
   - Authentication middleware (Supabase JWT)
   - Error handling
   - CORS configuration
   - Request/response validation

3. **Each Route Must:**
   - Match spec.md Section 3 exactly
   - Include type hints
   - Have docstrings
   - Handle errors properly (400, 401, 403, 404, 422, 500)
   - Validate input data
   - Return correct status codes
   - Follow RESTful conventions

4. **Tech Stack:**
   - FastAPI
   - SQLModel
   - Pydantic
   - Supabase Python client
   - asyncpg (for async PostgreSQL)

### Critical Rules
- ❌ Do NOT modify database schema
- ❌ Do NOT change API contracts from spec.md
- ❌ Do NOT skip authentication checks
- ❌ Do NOT skip error handling
- ❌ Do NOT write tests (Agent 5 owns testing)
- ✅ DO follow spec.md API exactly
- ✅ DO use SQLModel for all models
- ✅ DO implement proper JWT validation
- ✅ DO add helpful docstrings

### File Structure You Must Create

```
backend/app/
├── main.py                 # FastAPI app, CORS, startup
├── config.py              # Environment variables, settings
├── dependencies.py        # Auth dependencies, DB session
├── models/
│   ├── __init__.py
│   ├── user.py           # User SQLModel
│   ├── voter.py          # Voter SQLModel
│   ├── assignment.py     # Assignment SQLModel
│   └── contact_log.py    # ContactLog SQLModel
└── routes/
    ├── __init__.py
    ├── auth.py           # POST /auth/signup, /auth/login
    ├── assignments.py    # GET/POST/PATCH /assignments
    ├── voters.py         # GET /voters, /voters/{id}
    ├── contact_logs.py   # POST/GET /contact-logs
    └── analytics.py      # GET /analytics/progress
```

### Example Prompt for Cursor

```
You are Agent 2: Backend Engineer.

CRITICAL: Read these files first:
1. spec.md (Section 3: Backend API Specification)
2. backend/migrations/001_initial_schema.sql (to match your models)
3. AGENT_INSTRUCTIONS.md (Agent 2 section)

Your task:
Create a complete FastAPI backend in backend/app/ with:
- main.py (FastAPI app with CORS)
- All routes matching spec.md Section 3 exactly
- SQLModel models matching the database schema
- Authentication using Supabase JWT
- Proper error handling

Start with main.py and config.py, then create models, then routes.
Follow spec.md API contracts exactly - every endpoint, every field.

Generate the files now.
```

---

## Agent 3: Frontend Engineer

### Your Mission
Build all SwiftUI views and ViewModels for the iOS application.

### Files You Own
- `ios/VEP/Views/AssignmentListView.swift`
- `ios/VEP/Views/AssignmentDetailView.swift`
- `ios/VEP/Views/WalkListView.swift`
- `ios/VEP/Views/ContactFormView.swift`
- `ios/VEP/Views/VoterDetailView.swift`
- `ios/VEP/Views/MapView.swift`
- `ios/VEP/Views/AnalyticsView.swift`
- `ios/VEP/ViewModels/AssignmentListViewModel.swift`
- `ios/VEP/ViewModels/WalkListViewModel.swift`
- `ios/VEP/ViewModels/VoterDetailViewModel.swift`
- `ios/VEP/Models/User.swift`
- `ios/VEP/Models/Voter.swift`
- `ios/VEP/Models/Assignment.swift`
- `ios/VEP/Models/ContactLog.swift`

### What You Must Do

1. **Read First:**
   - `spec.md` Section 4 (iOS Application Specification)
   - This file (your section)

2. **Create:**
   - All SwiftUI views from spec.md Section 4.3
   - All ViewModels from spec.md Section 4.4
   - All data models from spec.md Section 4.2
   - Navigation structure
   - UI components

3. **Each View Must:**
   - Follow SwiftUI best practices
   - Use proper state management (@Published, @StateObject, etc.)
   - Have good accessibility (labels, hints)
   - Work in light and dark mode
   - Match spec.md design
   - Handle loading and error states

4. **Tech Stack:**
   - SwiftUI
   - iOS 17+
   - MapKit
   - Combine (for ViewModels)

### Critical Rules
- ❌ Do NOT implement APIClient (Agent 4 owns)
- ❌ Do NOT implement services (Agent 4 owns)
- ❌ Do NOT implement Core Data (Agent 4 owns)
- ❌ Do NOT change data models from spec.md
- ✅ DO follow spec.md Section 4 exactly
- ✅ DO use @Published for ViewModel state
- ✅ DO handle loading/error states
- ✅ DO use proper SwiftUI patterns

### File Structure You Must Create

```
ios/VEP/
├── Models/
│   ├── User.swift
│   ├── Voter.swift
│   ├── Assignment.swift
│   └── ContactLog.swift
├── Views/
│   ├── AssignmentListView.swift
│   ├── AssignmentDetailView.swift
│   ├── WalkListView.swift
│   ├── ContactFormView.swift
│   ├── VoterDetailView.swift
│   ├── MapView.swift
│   └── AnalyticsView.swift
└── ViewModels/
    ├── AssignmentListViewModel.swift
    ├── WalkListViewModel.swift
    └── VoterDetailViewModel.swift
```

### Example Prompt for Cursor

```
You are Agent 3: Frontend Engineer.

CRITICAL: Read these files first:
1. spec.md (Section 4: iOS Application Specification)
2. AGENT_INSTRUCTIONS.md (Agent 3 section)

Your task:
Create SwiftUI views and ViewModels in ios/VEP/ following spec.md Section 4.

Start with:
1. Data models (Section 4.2)
2. ViewModels (Section 4.4)
3. Views (Section 4.3)

For ViewModels, mock the service layer for now (Agent 4 will implement).
Example:
```swift
// Temporary mock - Agent 4 will replace
func loadAssignments() async {
    // Mock data for now
    self.assignments = [...]
}
```

Follow spec.md UI designs exactly.

Generate the files now.
```

---

## Agent 4: Integration Engineer

### Your Mission
Build the complete service layer that connects the frontend to the backend, including offline support.

### Files You Own
- `ios/VEP/Services/APIClient.swift`
- `ios/VEP/Services/OfflineStorageService.swift`
- `ios/VEP/Services/SyncService.swift`
- `ios/VEP/Services/LocationService.swift`
- `ios/VEP/CoreData/VEP.xcdatamodeld`
- `ios/VEP/CoreData/Models/*.swift` (Core Data entities)

### What You Must Do

1. **Read First:**
   - `spec.md` Section 3 (to understand API)
   - `spec.md` Section 4.5 & 4.6 (Services & Offline Strategy)
   - Agent 2's backend routes
   - Agent 3's models and ViewModels
   - This file (your section)

2. **Create:**
   - APIClient matching spec.md Section 3 API
   - OfflineStorageService with Core Data
   - SyncService for offline queue
   - LocationService for MapKit integration

3. **APIClient Must:**
   - Implement all API calls from spec.md Section 3
   - Handle authentication (JWT tokens)
   - Parse responses into Swift models
   - Handle errors properly
   - Support async/await
   - Have proper timeout handling

4. **OfflineStorageService Must:**
   - Set up Core Data stack
   - Cache assignments and voters
   - Queue contact logs for sync
   - Provide Core Data models matching API models

5. **SyncService Must:**
   - Process sync queue (FIFO)
   - Retry failed syncs (max 3 attempts)
   - Auto-sync every 5 minutes
   - Track pending count

### Critical Rules
- ❌ Do NOT modify Agent 3's views or ViewModels
- ❌ Do NOT modify Agent 2's backend
- ❌ Do NOT change API contracts
- ✅ DO implement offline-first strategy
- ✅ DO handle network errors gracefully
- ✅ DO follow spec.md Section 4.6 exactly
- ✅ DO integrate with Agent 3's ViewModels

### Integration Steps

1. **Replace Agent 3's mocks:**
   ```swift
   // Agent 3 had this mock:
   func loadAssignments() async {
       self.assignments = [mock data]
   }
   
   // You change it to:
   func loadAssignments() async {
       do {
           self.assignments = try await APIClient.shared.getAssignments()
       } catch {
           self.errorMessage = error.localizedDescription
       }
   }
   ```

2. **Add offline caching:**
   ```swift
   func loadAssignments() async {
       // Try online first
       do {
           let assignments = try await APIClient.shared.getAssignments()
           OfflineStorageService.shared.cacheAssignments(assignments)
           self.assignments = assignments
       } catch {
           // Fall back to cache if offline
           self.assignments = OfflineStorageService.shared.getCachedAssignments()
       }
   }
   ```

### Example Prompt for Cursor

```
You are Agent 4: Integration Engineer.

CRITICAL: Read these files first:
1. spec.md (Sections 3, 4.5, 4.6)
2. Agent 2's backend/app/routes/ (to match the API)
3. Agent 3's ios/VEP/ViewModels/ (to integrate with)
4. AGENT_INSTRUCTIONS.md (Agent 4 section)

Your task:
1. Create APIClient in ios/VEP/Services/APIClient.swift
   - Implement all endpoints from spec.md Section 3
   - Use async/await
   - Handle authentication with JWT

2. Create OfflineStorageService with Core Data
   - Cache assignments and voters
   - Queue contact logs for sync

3. Create SyncService
   - Process queue FIFO
   - Auto-sync every 5 minutes
   - Track pending count

4. Update Agent 3's ViewModels to use your services
   - Replace mock data with real API calls
   - Add offline fallback logic

Generate the files now.
```

---

## Agent 5: Testing Engineer

### Your Mission
Write comprehensive tests for both backend and iOS application.

### Files You Own
- `backend/tests/test_auth.py`
- `backend/tests/test_assignments.py`
- `backend/tests/test_voters.py`
- `backend/tests/test_contact_logs.py`
- `backend/tests/test_analytics.py`
- `backend/tests/conftest.py`
- `ios/VEPTests/ViewModelTests.swift`
- `ios/VEPTests/APIClientTests.swift`
- `ios/VEPTests/OfflineStorageTests.swift`
- `ios/VEPUITests/WalkListUITests.swift`
- `.github/workflows/ci.yml`

### What You Must Do

1. **Read First:**
   - `spec.md` Section 6 (Testing Requirements)
   - All agents' code (to test it)
   - This file (your section)

2. **Create Backend Tests:**
   - Unit tests for each route
   - Integration tests for full flows
   - Test database operations
   - Test RLS policies
   - Test error handling
   - Mock external dependencies

3. **Create iOS Tests:**
   - Unit tests for ViewModels
   - Unit tests for APIClient (mock server)
   - Unit tests for OfflineStorage
   - UI tests for critical flows
   - Test offline mode
   - Test sync logic

4. **Setup CI/CD:**
   - GitHub Actions workflow
   - Run tests on every PR
   - Check code coverage
   - Lint code

### Critical Rules
- ❌ Do NOT modify application code
- ❌ Do NOT skip edge cases
- ❌ Do NOT skip error cases
- ✅ DO achieve >80% backend coverage
- ✅ DO achieve >70% iOS coverage
- ✅ DO test offline scenarios
- ✅ DO test error handling
- ✅ DO use proper mocking

### Testing Tools

**Backend:**
- pytest
- pytest-asyncio
- httpx (for async client)
- pytest-cov (coverage)

**iOS:**
- XCTest
- XCTestExpectation (for async)
- Mock objects for services

### Example Test Structure

**Backend:**
```python
# test_assignments.py
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_get_assignments_success(client: AsyncClient, auth_token):
    """Test getting assignments for authenticated user."""
    response = await client.get(
        "/assignments",
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "assignments" in data
    assert isinstance(data["assignments"], list)

@pytest.mark.asyncio
async def test_get_assignments_unauthorized(client: AsyncClient):
    """Test getting assignments without auth token."""
    response = await client.get("/assignments")
    assert response.status_code == 401
```

**iOS:**
```swift
// ViewModelTests.swift
import XCTest
@testable import VEP

final class AssignmentListViewModelTests: XCTestCase {
    var viewModel: AssignmentListViewModel!
    var mockAPIClient: MockAPIClient!
    
    override func setUp() {
        mockAPIClient = MockAPIClient()
        viewModel = AssignmentListViewModel(apiClient: mockAPIClient)
    }
    
    func testLoadAssignments_Success() async {
        // Given
        mockAPIClient.assignmentsToReturn = [mockAssignment]
        
        // When
        await viewModel.loadAssignments()
        
        // Then
        XCTAssertEqual(viewModel.assignments.count, 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadAssignments_NetworkError() async {
        // Given
        mockAPIClient.shouldFail = true
        
        // When
        await viewModel.loadAssignments()
        
        // Then
        XCTAssertTrue(viewModel.assignments.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
```

### Example Prompt for Cursor

```
You are Agent 5: Testing Engineer.

CRITICAL: Read these files first:
1. spec.md (Section 6: Testing Requirements)
2. All backend routes (Agent 2's work)
3. All iOS ViewModels and Services (Agent 3 & 4's work)
4. AGENT_INSTRUCTIONS.md (Agent 5 section)

Your task:
Create comprehensive test suites for both backend and iOS.

Backend (pytest):
- test_auth.py
- test_assignments.py
- test_voters.py
- test_contact_logs.py
- conftest.py (fixtures)

iOS (XCTest):
- ViewModelTests.swift
- APIClientTests.swift
- OfflineStorageTests.swift

Target >80% backend coverage, >70% iOS coverage.
Test all happy paths and error cases.

Generate the files now.
```

---

## General Guidelines for ALL Agents

### Before You Start
1. ✅ Read `spec.md` (your relevant sections)
2. ✅ Read `AGENT_INSTRUCTIONS.md` (your section)
3. ✅ Read files from previous agents (if dependent)
4. ✅ Understand your boundaries

### While Working
1. ✅ Follow `spec.md` exactly - do NOT deviate
2. ✅ Stay within your file boundaries
3. ✅ Add comments explaining your decisions
4. ✅ Use proper type hints / type annotations
5. ✅ Handle errors properly
6. ✅ Follow language conventions (PEP 8 for Python, Swift style guide)

### Before You Finish
1. ✅ Review your code against `spec.md`
2. ✅ Ensure all requirements met
3. ✅ Check for syntax errors
4. ✅ Add helpful comments
5. ✅ Verify you didn't modify other agents' files

### If Something is Unclear
1. ✅ Check `spec.md` first
2. ✅ Ask the human for clarification
3. ✅ Do NOT guess or deviate from spec

---

## Agent Execution Order

**Sequential (must wait for previous):**
1. Agent 1 (Database) - blocks everyone
2. Agent 2 (Backend) - needs Agent 1's schema
3. Agent 3 (Frontend) - needs Agent 2's API contracts
4. Agent 4 (Integration) - needs Agent 2 & 3 complete

**Parallel (independent):**
- Agent 5 (Testing) - can start anytime after Agent 1

**Recommended Timeline:**
- Week 1: Agent 1 completes
- Week 2: Agent 2 completes
- Week 3: Agent 3 completes
- Week 3-4: Agent 4 integrates (while Agent 5 writes tests in parallel)
- Week 4: Agent 5 finalizes tests

---

## Success Criteria

**Agent 1 Done When:**
- ✅ SQL file runs without errors
- ✅ All tables created
- ✅ All indexes created
- ✅ RLS policies work
- ✅ Trigger works

**Agent 2 Done When:**
- ✅ FastAPI server starts
- ✅ All endpoints respond
- ✅ All endpoints match spec.md
- ✅ Authentication works
- ✅ Database queries work

**Agent 3 Done When:**
- ✅ All views compile
- ✅ All views match spec.md
- ✅ ViewModels compile
- ✅ Navigation works
- ✅ UI looks good

**Agent 4 Done When:**
- ✅ APIClient works with real backend
- ✅ Offline storage works
- ✅ Sync queue works
- ✅ ViewModels use real services
- ✅ App works offline

**Agent 5 Done When:**
- ✅ All tests pass
- ✅ Coverage >80% (backend) / >70% (iOS)
- ✅ CI/CD pipeline works
- ✅ All edge cases tested

---

**Remember: This is a team effort. Each agent depends on others doing their job correctly. Follow spec.md exactly!**
