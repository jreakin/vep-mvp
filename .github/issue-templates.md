# Pre-Created Issues for GitHub Project

Copy and paste these into GitHub Issues after setting up your repository.

---

## Issue 1: Agent 1 - Database Schema

**Title:** [AGENT 1] Database Schema with PostGIS

**Labels:** `agent-1`, `database`, `ready`, `priority-high`

**Assignees:** (assign to yourself when starting)

**Description:**

```markdown
## Agent Information
**Agent:** Agent 1 - Database Engineer  
**Status:** 🟡 Ready to Start  
**Estimate:** 2-4 hours  
**Blocker:** None - Can start immediately

## Objective
Create the complete PostgreSQL database schema with PostGIS extension for the VEP MVP, including all tables, indexes, constraints, RLS policies, and triggers.

## Files to Create
- [ ] `backend/migrations/001_initial_schema.sql`

## Requirements from spec.md
- Section 2: Complete Database Schema
- Section 2.1: All 5 tables (users, voters, assignments, assignment_voters, contact_logs)
- Section 2.2: Database functions and triggers
- Section 2.3: Row Level Security policies

## Success Criteria
- [ ] SQL file runs without errors on PostgreSQL 14+
- [ ] All 5 tables created with correct columns
- [ ] PostGIS extension enabled
- [ ] All indexes created (15+ indexes)
- [ ] All foreign key constraints
- [ ] All check constraints
- [ ] RLS policies implemented for all tables
- [ ] Trigger for voter support level updates
- [ ] Tested with: `psql -d test_db -f migrations/001_initial_schema.sql`
- [ ] PROGRESS.md updated

## Dependencies
**Depends on:** None  
**Blocks:** #2 (Agent 2), #5 (Agent 5)

## Cursor Prompt
Copy this prompt from `.copilot/instructions-agent-1.md`:

```
You are Agent 1: Database Engineer.

CRITICAL: Read these files first:
1. spec.md (Section 2: Database Schema)
2. AGENT_INSTRUCTIONS.md (Agent 1 section)

Your task:
Create backend/migrations/001_initial_schema.sql

Include:
- PostGIS extension
- All 5 tables from spec.md Section 2
- All indexes and constraints
- RLS policies
- Trigger for voter support updates

Generate the complete file now.
```

## Notes
- This is the foundation for the entire project
- Every other agent depends on this schema
- Take time to get it right
- SQL must be idempotent (can run multiple times)

## Progress
- [ ] Read spec.md Section 2
- [ ] Read AGENT_INSTRUCTIONS.md Agent 1 section
- [ ] Invoke Agent 1 in Cursor
- [ ] Review generated SQL
- [ ] Test migration locally
- [ ] Create branch: `agent-1/database-schema`
- [ ] Commit and push
- [ ] Create PR
- [ ] Merge after review
- [ ] Update PROGRESS.md
```

---

## Issue 2: Agent 2 - Backend API

**Title:** [AGENT 2] FastAPI Backend Routes and Models

**Labels:** `agent-2`, `backend`, `blocked`, `priority-high`

**Assignees:** (assign when Agent 1 complete)

**Description:**

```markdown
## Agent Information
**Agent:** Agent 2 - Backend Engineer  
**Status:** 🔴 Blocked by Agent 1  
**Estimate:** 1-2 weeks  
**Blocker:** Waiting for #1 (database schema)

## Objective
Build the complete FastAPI backend with all REST endpoints, SQLModel models, authentication, and business logic matching the API specification.

## Files to Create
- [ ] `backend/app/main.py` (complete from skeleton)
- [ ] `backend/app/config.py` (complete from skeleton)
- [ ] `backend/app/dependencies.py`
- [ ] `backend/app/models/user.py`
- [ ] `backend/app/models/voter.py`
- [ ] `backend/app/models/assignment.py`
- [ ] `backend/app/models/contact_log.py`
- [ ] `backend/app/routes/auth.py`
- [ ] `backend/app/routes/assignments.py`
- [ ] `backend/app/routes/voters.py`
- [ ] `backend/app/routes/contact_logs.py`
- [ ] `backend/app/routes/analytics.py`

## Requirements from spec.md
- Section 3: Complete Backend API Specification
- Section 3.2: All authentication endpoints
- Section 3.3: All assignment endpoints (4 endpoints)
- Section 3.4: All voter endpoints (2 endpoints)
- Section 3.5: All contact log endpoints (2 endpoints)
- Section 3.6: Analytics endpoint
- Section 3.7: Error handling

## Success Criteria
- [ ] FastAPI server starts without errors
- [ ] All 15+ endpoints implemented
- [ ] SQLModel models match database schema from Agent 1
- [ ] JWT authentication working with Supabase
- [ ] Request validation working (Pydantic)
- [ ] Error handling for all status codes (400, 401, 403, 404, 422, 500)
- [ ] CORS configured
- [ ] Tested with Postman/curl
- [ ] All routes return correct responses matching spec.md
- [ ] PROGRESS.md updated

## Dependencies
**Depends on:** #1 (Agent 1 must complete database first)  
**Blocks:** #3 (Agent 3), #4 (Agent 4)

## Cursor Prompt
Copy from `.copilot/instructions-agent-2.md`

## Notes
- Must read Agent 1's SQL migration first
- Models must exactly match database schema
- Every endpoint in spec.md Section 3 is required
- Test each endpoint before committing

## Progress
- [ ] Wait for Agent 1 to complete
- [ ] Read backend/migrations/001_initial_schema.sql
- [ ] Read spec.md Section 3
- [ ] Invoke Agent 2 in Cursor
- [ ] Review generated code
- [ ] Test all endpoints locally
- [ ] Create branch: `agent-2/backend-api`
- [ ] Commit and push
- [ ] Create PR
- [ ] Merge after review
- [ ] Update PROGRESS.md
```

---

## Issue 3: Agent 3 - iOS Frontend

**Title:** [AGENT 3] SwiftUI Views and ViewModels

**Labels:** `agent-3`, `ios`, `blocked`, `priority-high`

**Assignees:** (assign when Agent 2 complete)

**Description:**

```markdown
## Agent Information
**Agent:** Agent 3 - Frontend Engineer  
**Status:** 🔴 Blocked by Agent 2  
**Estimate:** 1-2 weeks  
**Blocker:** Waiting for #2 (backend API contracts)

## Objective
Build all SwiftUI views, ViewModels, and data models for the iOS application following the MVVM architecture.

## Files to Create
- [ ] `ios/VEP/Models/User.swift`
- [ ] `ios/VEP/Models/Voter.swift`
- [ ] `ios/VEP/Models/Assignment.swift`
- [ ] `ios/VEP/Models/ContactLog.swift`
- [ ] `ios/VEP/ViewModels/AssignmentListViewModel.swift`
- [ ] `ios/VEP/ViewModels/WalkListViewModel.swift`
- [ ] `ios/VEP/ViewModels/VoterDetailViewModel.swift`
- [ ] `ios/VEP/Views/AssignmentListView.swift`
- [ ] `ios/VEP/Views/AssignmentDetailView.swift`
- [ ] `ios/VEP/Views/WalkListView.swift`
- [ ] `ios/VEP/Views/ContactFormView.swift`
- [ ] `ios/VEP/Views/VoterDetailView.swift`
- [ ] `ios/VEP/Views/MapView.swift`
- [ ] `ios/VEP/Views/AnalyticsView.swift`

## Requirements from spec.md
- Section 4.2: All data models
- Section 4.3: All 7 views
- Section 4.4: All 3 ViewModels
- MVVM architecture strictly followed

## Success Criteria
- [ ] All Swift models created matching API
- [ ] All 7 views created and working
- [ ] All 3 ViewModels with @Published properties
- [ ] Navigation working between views
- [ ] MapKit integration in MapView
- [ ] ViewModels use mock data (Agent 4 will replace)
- [ ] Compiles without errors in Xcode
- [ ] Tested in iOS simulator
- [ ] Light and dark mode working
- [ ] Accessibility labels added
- [ ] PROGRESS.md updated

## Dependencies
**Depends on:** #2 (Agent 2 for API data models)  
**Blocks:** #4 (Agent 4 integration)

## Cursor Prompt
Copy from `.copilot/instructions-agent-3.md`

## Notes
- Models must match Agent 2's API responses
- Use mock data in ViewModels for now
- Agent 4 will replace mocks with real API calls
- Focus on UI/UX and SwiftUI best practices

## Progress
- [ ] Wait for Agent 2 to complete
- [ ] Read Agent 2's models
- [ ] Read spec.md Section 4
- [ ] Invoke Agent 3 in Cursor
- [ ] Review generated views
- [ ] Test in simulator
- [ ] Create branch: `agent-3/ios-frontend`
- [ ] Commit and push
- [ ] Create PR
- [ ] Merge after review
- [ ] Update PROGRESS.md
```

---

## Issue 4: Agent 4 - Integration

**Title:** [AGENT 4] Service Layer and Offline Sync

**Labels:** `agent-4`, `integration`, `blocked`, `priority-high`

**Assignees:** (assign when Agents 2 & 3 complete)

**Description:**

```markdown
## Agent Information
**Agent:** Agent 4 - Integration Engineer  
**Status:** 🔴 Blocked by Agents 2 & 3  
**Estimate:** 1 week  
**Blocker:** Waiting for #2 (backend) and #3 (frontend)

## Objective
Build the complete service layer that connects frontend to backend, including API client, offline storage, and sync functionality.

## Files to Create
- [ ] `ios/VEP/Services/APIClient.swift`
- [ ] `ios/VEP/Services/OfflineStorageService.swift`
- [ ] `ios/VEP/Services/SyncService.swift`
- [ ] `ios/VEP/Services/LocationService.swift`
- [ ] `ios/VEP/CoreData/VEP.xcdatamodeld`
- [ ] Core Data entity files

## Files to Modify
- [ ] Update all ViewModels from Agent 3 to use real services
- [ ] Replace mock data with API calls

## Requirements from spec.md
- Section 3: API client must match all endpoints
- Section 4.5: All service implementations
- Section 4.6: Offline strategy (CRITICAL)

## Success Criteria
- [ ] APIClient implements all endpoints from spec.md Section 3
- [ ] JWT authentication working
- [ ] Core Data model created
- [ ] OfflineStorageService caching assignments and voters
- [ ] SyncService with FIFO queue
- [ ] Retry logic (max 3 attempts)
- [ ] Auto-sync every 5 minutes
- [ ] ViewModels updated to use real services
- [ ] Offline mode tested thoroughly
- [ ] End-to-end flow working (API → ViewModel → View)
- [ ] Network error handling working
- [ ] PROGRESS.md updated

## Dependencies
**Depends on:** #2 (backend API) and #3 (frontend ViewModels)  
**Blocks:** None (enables MVP completion)

## Cursor Prompt
Copy from `.copilot/instructions-agent-4.md`

## Notes
- Most complex integration work
- Offline-first strategy is critical
- Test extensively with airplane mode
- Must not break Agent 3's UI

## Progress
- [ ] Wait for Agents 2 & 3 to complete
- [ ] Read Agent 2's API routes
- [ ] Read Agent 3's ViewModels
- [ ] Read spec.md Sections 4.5 & 4.6
- [ ] Invoke Agent 4 in Cursor
- [ ] Review generated services
- [ ] Test offline mode
- [ ] Test end-to-end flow
- [ ] Create branch: `agent-4/integration`
- [ ] Commit and push
- [ ] Create PR
- [ ] Merge after review
- [ ] Update PROGRESS.md
```

---

## Issue 5: Agent 5 - Testing

**Title:** [AGENT 5] Test Suite and CI/CD

**Labels:** `agent-5`, `testing`, `ready`, `priority-medium`

**Assignees:** (can assign after Agent 1, work in parallel)

**Description:**

```markdown
## Agent Information
**Agent:** Agent 5 - Testing Engineer  
**Status:** 🟡 Ready (Can work in parallel)  
**Estimate:** 1-2 weeks (parallel to Agents 2-4)  
**Blocker:** Needs Agent 1 complete to start, then can work in parallel

## Objective
Write comprehensive test suites for both backend and iOS, achieving >80% backend coverage and >70% iOS coverage, plus CI/CD configuration.

## Files to Create

### Backend Tests
- [ ] `backend/tests/conftest.py`
- [ ] `backend/tests/test_auth.py`
- [ ] `backend/tests/test_assignments.py`
- [ ] `backend/tests/test_voters.py`
- [ ] `backend/tests/test_contact_logs.py`
- [ ] `backend/tests/test_analytics.py`

### iOS Tests
- [ ] `ios/VEPTests/ViewModelTests.swift`
- [ ] `ios/VEPTests/APIClientTests.swift`
- [ ] `ios/VEPTests/OfflineStorageTests.swift`
- [ ] `ios/VEPUITests/WalkListUITests.swift`

### CI/CD
- [ ] Update `.github/workflows/backend.yml` (if needed)
- [ ] Update `.github/workflows/ios.yml` (if needed)

## Requirements from spec.md
- Section 6: Complete Testing Requirements
- >80% backend coverage
- >70% iOS coverage

## Success Criteria
- [ ] Backend pytest suite complete
- [ ] Backend coverage >80%
- [ ] iOS XCTest suite complete
- [ ] iOS coverage >70%
- [ ] All happy paths tested
- [ ] All error cases tested
- [ ] Edge cases covered
- [ ] Mock objects used properly
- [ ] CI/CD passing on all PRs
- [ ] Tests run on Python 3.11 and 3.12
- [ ] Tests run on macOS with Xcode
- [ ] PROGRESS.md updated

## Dependencies
**Depends on:** #1 (needs database to test against)  
**Can work parallel to:** #2, #3, #4 (write tests as they complete)  
**Blocks:** None

## Cursor Prompt
Copy from `.copilot/instructions-agent-5.md`

## Notes
- Can start after Agent 1 completes
- Work in parallel with other agents
- Add tests incrementally as agents complete
- Focus on high coverage and edge cases

## Progress
- [ ] Wait for Agent 1 to complete
- [ ] Read all agents' code as they complete
- [ ] Read spec.md Section 6
- [ ] Invoke Agent 5 in Cursor
- [ ] Write backend tests incrementally
- [ ] Write iOS tests incrementally
- [ ] Verify CI/CD passes
- [ ] Check coverage reports
- [ ] Create branch: `agent-5/testing`
- [ ] Commit and push
- [ ] Create PR
- [ ] Merge after review
- [ ] Update PROGRESS.md
```

---

## Labels to Create First

Before creating these issues, create these labels in your repository:

**Settings → Labels → New label**

```
agent-1          #0E8A16 (green)
agent-2          #1D76DB (blue)
agent-3          #5319E7 (purple)
agent-4          #E99695 (pink)
agent-5          #FBCA04 (yellow)

ready            #0E8A16 (green)
in-progress      #1D76DB (blue)
blocked          #D93F0B (red)
review           #5319E7 (purple)
completed        #0E8A16 (green)

database         #C5DEF5 (light blue)
backend          #BFD4F2 (light blue)
ios              #D4C5F9 (light purple)
integration      #FEF2C0 (light yellow)
testing          #C2E0C6 (light green)

priority-high    #D93F0B (red)
priority-medium  #FBCA04 (yellow)
priority-low     #C2E0C6 (light green)
```

---

## Quick Create Script

Or copy/paste these into GitHub CLI:

```bash
# Create all issues at once
gh issue create --title "[AGENT 1] Database Schema with PostGIS" --body-file .github/issue-1.md --label "agent-1,database,ready,priority-high"

gh issue create --title "[AGENT 2] FastAPI Backend Routes and Models" --body-file .github/issue-2.md --label "agent-2,backend,blocked,priority-high"

gh issue create --title "[AGENT 3] SwiftUI Views and ViewModels" --body-file .github/issue-3.md --label "agent-3,ios,blocked,priority-high"

gh issue create --title "[AGENT 4] Service Layer and Offline Sync" --body-file .github/issue-4.md --label "agent-4,integration,blocked,priority-high"

gh issue create --title "[AGENT 5] Test Suite and CI/CD" --body-file .github/issue-5.md --label "agent-5,testing,ready,priority-medium"
```

(First save each issue description to .github/issue-1.md, etc.)
