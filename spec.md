# VEP MVP Technical Specification

**Version:** 1.0  
**Last Updated:** October 22, 2025  
**Status:** Agent Development Ready

---

## 1. Overview

### 1.1 Purpose
Build an MVP for canvassing operations that allows campaign staff to:
- Assign walk lists to canvassers
- View assignments on a map
- Log voter contacts in the field
- Sync data offline and upload when connected

### 1.2 Core User Stories
1. **Campaign Manager:** "I want to assign specific neighborhoods to canvassers"
2. **Canvasser:** "I want to see my assigned addresses on a map while offline"
3. **Canvasser:** "I want to quickly log contact results and voter responses"
4. **Campaign Manager:** "I want to see real-time progress of all canvassers"

### 1.3 Technology Decisions
- **Backend:** FastAPI + PostgreSQL/PostGIS on Supabase
- **Frontend:** SwiftUI for iOS 17+
- **Auth:** Supabase Auth with JWT
- **Maps:** MapKit (iOS native)
- **Offline:** Core Data + sync queue

---

## 2. Database Schema

### 2.1 Tables

#### `users`
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('admin', 'manager', 'canvasser')),
    phone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
```

**Notes:**
- Auth handled by Supabase Auth, this table stores user metadata
- Role determines permissions (admin > manager > canvasser)

#### `voters`
```sql
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE voters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    voter_id TEXT UNIQUE NOT NULL, -- External voter ID from VAN/PDI
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL DEFAULT 'TX',
    zip TEXT NOT NULL,
    location GEOMETRY(POINT, 4326), -- PostGIS point (lng, lat)
    party_affiliation TEXT,
    support_level INTEGER CHECK (support_level BETWEEN 1 AND 5),
    phone TEXT,
    email TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_voters_voter_id ON voters(voter_id);
CREATE INDEX idx_voters_location ON voters USING GIST(location);
CREATE INDEX idx_voters_zip ON voters(zip);
CREATE INDEX idx_voters_support_level ON voters(support_level);
```

**Notes:**
- `location` uses PostGIS for spatial queries (find voters near canvasser)
- `support_level`: 1=Strong Opponent, 2=Lean Opponent, 3=Undecided, 4=Lean Support, 5=Strong Support
- External voter_id links to VAN/PDI systems

#### `assignments`
```sql
CREATE TABLE assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL, -- e.g., "Downtown Austin - Oct 22"
    description TEXT,
    assigned_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_assignments_user_id ON assignments(user_id);
CREATE INDEX idx_assignments_status ON assignments(status);
CREATE INDEX idx_assignments_assigned_date ON assignments(assigned_date);
```

**Notes:**
- One assignment can have many voters
- Status tracks lifecycle: pending → in_progress → completed

#### `assignment_voters`
```sql
CREATE TABLE assignment_voters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
    voter_id UUID NOT NULL REFERENCES voters(id) ON DELETE CASCADE,
    sequence_order INTEGER, -- Order to visit voters
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(assignment_id, voter_id)
);

CREATE INDEX idx_assignment_voters_assignment ON assignment_voters(assignment_id);
CREATE INDEX idx_assignment_voters_voter ON assignment_voters(voter_id);
CREATE INDEX idx_assignment_voters_sequence ON assignment_voters(assignment_id, sequence_order);
```

**Notes:**
- Join table between assignments and voters
- `sequence_order` allows pre-planned route optimization

#### `contact_logs`
```sql
CREATE TABLE contact_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
    voter_id UUID NOT NULL REFERENCES voters(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    contact_type TEXT NOT NULL CHECK (contact_type IN ('knocked', 'phone', 'text', 'email', 'not_home', 'refused', 'moved', 'deceased')),
    result TEXT, -- Free text notes
    support_level INTEGER CHECK (support_level BETWEEN 1 AND 5),
    location GEOMETRY(POINT, 4326), -- Where contact was made
    contacted_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_contact_logs_assignment ON contact_logs(assignment_id);
CREATE INDEX idx_contact_logs_voter ON contact_logs(voter_id);
CREATE INDEX idx_contact_logs_user ON contact_logs(user_id);
CREATE INDEX idx_contact_logs_contacted_at ON contact_logs(contacted_at);
```

**Notes:**
- Every voter contact gets logged here
- `location` records where canvasser was when logging (for verification)
- `support_level` updates voter's support level

### 2.2 Database Functions

#### Update voter support level on contact
```sql
CREATE OR REPLACE FUNCTION update_voter_support_level()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.support_level IS NOT NULL THEN
        UPDATE voters 
        SET support_level = NEW.support_level, 
            updated_at = NOW()
        WHERE id = NEW.voter_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_voter_support
    AFTER INSERT ON contact_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_voter_support_level();
```

### 2.3 Row Level Security (RLS)

```sql
-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE voters ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignment_voters ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_logs ENABLE ROW LEVEL SECURITY;

-- Users can read their own data
CREATE POLICY users_select_own ON users
    FOR SELECT USING (auth.uid() = id);

-- Managers and admins can read all users
CREATE POLICY users_select_managers ON users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role IN ('admin', 'manager')
        )
    );

-- All authenticated users can read voters
CREATE POLICY voters_select_authenticated ON voters
    FOR SELECT USING (auth.role() = 'authenticated');

-- Users can only see their own assignments
CREATE POLICY assignments_select_own ON assignments
    FOR SELECT USING (user_id = auth.uid());

-- Managers can see all assignments
CREATE POLICY assignments_select_managers ON assignments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role IN ('admin', 'manager')
        )
    );

-- Users can only log contacts for their assignments
CREATE POLICY contact_logs_insert_own ON contact_logs
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM assignments 
            WHERE id = assignment_id 
            AND user_id = auth.uid()
        )
    );
```

---

## 3. Backend API Specification

### 3.1 Base Configuration

**Base URL:** `https://your-project.supabase.co/functions/v1`  
**Auth:** JWT token in `Authorization: Bearer <token>` header  
**Content-Type:** `application/json`

### 3.2 Authentication Endpoints

#### POST `/auth/signup`
```json
Request:
{
    "email": "john@example.com",
    "password": "securepassword",
    "full_name": "John Doe",
    "role": "canvasser"
}

Response: 201
{
    "user_id": "uuid",
    "email": "john@example.com",
    "token": "jwt-token"
}
```

#### POST `/auth/login`
```json
Request:
{
    "email": "john@example.com",
    "password": "securepassword"
}

Response: 200
{
    "user_id": "uuid",
    "email": "john@example.com",
    "token": "jwt-token",
    "role": "canvasser"
}
```

### 3.3 Assignment Endpoints

#### GET `/assignments`
Get all assignments for authenticated user.

```json
Response: 200
{
    "assignments": [
        {
            "id": "uuid",
            "name": "Downtown Austin - Oct 22",
            "description": "Focus on apartment buildings",
            "assigned_date": "2025-10-22",
            "due_date": "2025-10-25",
            "status": "in_progress",
            "voter_count": 47,
            "completed_count": 12
        }
    ]
}
```

#### GET `/assignments/{assignment_id}`
Get detailed assignment with voters.

```json
Response: 200
{
    "id": "uuid",
    "name": "Downtown Austin - Oct 22",
    "status": "in_progress",
    "voters": [
        {
            "id": "uuid",
            "voter_id": "TX12345678",
            "first_name": "Jane",
            "last_name": "Smith",
            "address": "123 Main St",
            "city": "Austin",
            "zip": "78701",
            "location": {
                "latitude": 30.2672,
                "longitude": -97.7431
            },
            "party_affiliation": "D",
            "support_level": 3,
            "sequence_order": 1,
            "last_contact": {
                "date": "2025-10-20",
                "type": "knocked",
                "result": "Not home"
            }
        }
    ]
}
```

#### POST `/assignments`
Create new assignment (managers only).

```json
Request:
{
    "name": "East Austin - Oct 23",
    "description": "Single family homes",
    "user_id": "uuid",
    "voter_ids": ["uuid1", "uuid2", "uuid3"],
    "due_date": "2025-10-25"
}

Response: 201
{
    "id": "uuid",
    "name": "East Austin - Oct 23",
    "status": "pending",
    "voter_count": 3
}
```

#### PATCH `/assignments/{assignment_id}`
Update assignment status.

```json
Request:
{
    "status": "completed"
}

Response: 200
{
    "id": "uuid",
    "status": "completed",
    "updated_at": "2025-10-22T14:30:00Z"
}
```

### 3.4 Voter Endpoints

#### GET `/voters`
Search voters with filters.

```json
Query params:
?zip=78701&limit=50&offset=0

Response: 200
{
    "voters": [...],
    "total": 1234,
    "limit": 50,
    "offset": 0
}
```

#### GET `/voters/{voter_id}`
Get single voter details.

```json
Response: 200
{
    "id": "uuid",
    "voter_id": "TX12345678",
    "first_name": "Jane",
    "last_name": "Smith",
    "address": "123 Main St",
    "location": {
        "latitude": 30.2672,
        "longitude": -97.7431
    },
    "contact_history": [
        {
            "date": "2025-10-20",
            "type": "knocked",
            "result": "Not home",
            "user": "John Doe"
        }
    ]
}
```

### 3.5 Contact Log Endpoints

#### POST `/contact-logs`
Log a voter contact.

```json
Request:
{
    "assignment_id": "uuid",
    "voter_id": "uuid",
    "contact_type": "knocked",
    "result": "Strong supporter, wants yard sign",
    "support_level": 5,
    "location": {
        "latitude": 30.2672,
        "longitude": -97.7431
    }
}

Response: 201
{
    "id": "uuid",
    "contacted_at": "2025-10-22T14:30:00Z"
}
```

#### GET `/contact-logs`
Get contact logs with filters.

```json
Query params:
?assignment_id=uuid&start_date=2025-10-20

Response: 200
{
    "logs": [
        {
            "id": "uuid",
            "voter_name": "Jane Smith",
            "contact_type": "knocked",
            "result": "Strong supporter",
            "support_level": 5,
            "contacted_at": "2025-10-22T14:30:00Z"
        }
    ]
}
```

### 3.6 Analytics Endpoints

#### GET `/analytics/progress`
Get campaign progress metrics.

```json
Response: 200
{
    "total_voters": 10000,
    "contacted": 3547,
    "support_distribution": {
        "1": 423,
        "2": 891,
        "3": 1134,
        "4": 678,
        "5": 421
    },
    "contact_types": {
        "knocked": 2890,
        "not_home": 457,
        "refused": 200
    }
}
```

### 3.7 Error Responses

All errors follow this format:
```json
{
    "error": "Error type",
    "message": "Human readable message",
    "details": {...}
}
```

**Common Status Codes:**
- `400`: Bad Request (validation error)
- `401`: Unauthorized (missing/invalid token)
- `403`: Forbidden (insufficient permissions)
- `404`: Not Found
- `422`: Unprocessable Entity (invalid data)
- `500`: Internal Server Error

---

## 4. iOS Application Specification

### 4.1 App Architecture

**Pattern:** MVVM (Model-View-ViewModel)

```
Views → ViewModels → Services → API/Storage
```

**Key Components:**
- `APIClient`: Handles all HTTP requests
- `OfflineStorageService`: Core Data for offline caching
- `LocationService`: MapKit and location tracking
- `SyncService`: Queues and syncs offline changes

### 4.2 Data Models

#### `User`
```swift
struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let fullName: String
    let role: UserRole
    let phone: String?
}

enum UserRole: String, Codable {
    case admin, manager, canvasser
}
```

#### `Voter`
```swift
struct Voter: Codable, Identifiable {
    let id: UUID
    let voterId: String
    let firstName: String
    let lastName: String
    let address: String
    let city: String
    let state: String
    let zip: String
    let location: Coordinate
    let partyAffiliation: String?
    let supportLevel: Int?
    let phone: String?
    let email: String?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
}
```

#### `Assignment`
```swift
struct Assignment: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String?
    let assignedDate: Date
    let dueDate: Date?
    let status: AssignmentStatus
    let voterCount: Int
    let completedCount: Int
    var voters: [Voter]?
}

enum AssignmentStatus: String, Codable {
    case pending, inProgress = "in_progress", completed, cancelled
}
```

#### `ContactLog`
```swift
struct ContactLog: Codable, Identifiable {
    let id: UUID
    let assignmentId: UUID
    let voterId: UUID
    let contactType: ContactType
    let result: String?
    let supportLevel: Int?
    let location: Coordinate
    let contactedAt: Date
}

enum ContactType: String, Codable, CaseIterable {
    case knocked, phone, text, email
    case notHome = "not_home"
    case refused, moved, deceased
    
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
}
```

### 4.3 Views

#### `AssignmentListView`
**Purpose:** Show all assignments for current user  
**Layout:** List with search/filter  
**Actions:** Tap to view details, pull to refresh

```swift
// Key features:
- List of assignments with status badges
- Filter by status (pending/in_progress/completed)
- Search by name
- Shows progress (12/47 completed)
- Tap row → navigate to AssignmentDetailView
```

#### `AssignmentDetailView`
**Purpose:** Show assignment details and voter list  
**Layout:** Header + Map + List  
**Actions:** Start walking, view on map, mark complete

```swift
// Key features:
- Assignment header (name, dates, description)
- Map showing all voter locations
- List of voters in sequence order
- Tap voter → navigate to VoterDetailView
- "Start Walking" button → navigate to WalkListView
```

#### `WalkListView`
**Purpose:** Guide canvasser through assignment  
**Layout:** Current voter card + map + next voters list  
**Actions:** Log contact, navigate to next, skip

```swift
// Key features:
- Large card for current voter (name, address, info)
- Map centered on current voter
- "Log Contact" button → sheet with ContactFormView
- "Next" button → advance to next voter
- Shows route to next voter
- Works offline
```

#### `ContactFormView`
**Purpose:** Log voter contact quickly  
**Layout:** Form in bottom sheet  
**Actions:** Select contact type, add notes, save

```swift
// Key features:
- Segmented picker for contact type
- Support level picker (1-5 stars)
- Text field for notes
- Auto-captures current location
- Saves immediately (queues if offline)
- Dismisses and returns to WalkListView
```

#### `VoterDetailView`
**Purpose:** Show voter details and contact history  
**Layout:** Info card + contact history list  
**Actions:** Call, map, log contact

```swift
// Key features:
- Voter info (name, address, party, support level)
- Map showing voter location
- Contact history timeline
- Quick actions: Call, Map Directions, Log Contact
```

#### `MapView`
**Purpose:** Show all voters on interactive map  
**Layout:** Full screen map with annotations  
**Actions:** Tap marker to see voter, filter by status

```swift
// Key features:
- MapKit integration
- Color-coded pins (support level)
- Cluster annotations for many voters
- User location tracking
- Tap pin → show voter callout
- "Directions" button in callout
```

#### `AnalyticsView`
**Purpose:** Show progress and metrics (managers)  
**Layout:** Cards with charts  
**Actions:** View details, export data

```swift
// Key features:
- Total contacts today/week/month
- Support level distribution (bar chart)
- Contact type breakdown (pie chart)
- Top performers leaderboard
- Only visible to managers/admins
```

### 4.4 ViewModels

#### `AssignmentListViewModel`
```swift
@MainActor
class AssignmentListViewModel: ObservableObject {
    @Published var assignments: [Assignment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var filterStatus: AssignmentStatus?
    
    func loadAssignments() async
    func refreshAssignments() async
    func filterByStatus(_ status: AssignmentStatus?)
}
```

#### `WalkListViewModel`
```swift
@MainActor
class WalkListViewModel: ObservableObject {
    @Published var assignment: Assignment
    @Published var currentVoterIndex = 0
    @Published var contactedVoters: Set<UUID> = []
    @Published var isOnline = true
    
    var currentVoter: Voter? {
        assignment.voters?[safe: currentVoterIndex]
    }
    
    var progress: Double {
        Double(contactedVoters.count) / Double(assignment.voterCount)
    }
    
    func nextVoter()
    func previousVoter()
    func logContact(_ log: ContactLog) async
    func markVoterContacted(_ voterId: UUID)
}
```

### 4.5 Services

#### `APIClient`
```swift
class APIClient {
    static let shared = APIClient()
    
    private let baseURL = "https://your-project.supabase.co"
    private var token: String?
    
    func setAuthToken(_ token: String)
    
    // Assignments
    func getAssignments() async throws -> [Assignment]
    func getAssignment(id: UUID) async throws -> Assignment
    
    // Contact logs
    func createContactLog(_ log: ContactLog) async throws -> ContactLog
    
    // Voters
    func getVoter(id: UUID) async throws -> Voter
}
```

#### `OfflineStorageService`
```swift
class OfflineStorageService {
    static let shared = OfflineStorageService()
    
    // Core Data stack
    private let persistentContainer: NSPersistentContainer
    
    // Cache management
    func cacheAssignment(_ assignment: Assignment)
    func getCachedAssignment(id: UUID) -> Assignment?
    func clearCache()
    
    // Offline queue
    func queueContactLog(_ log: ContactLog)
    func getPendingLogs() -> [ContactLog]
    func clearSyncedLog(id: UUID)
}
```

#### `SyncService`
```swift
class SyncService {
    static let shared = SyncService()
    
    @Published var isSyncing = false
    @Published var pendingCount = 0
    
    func syncPendingLogs() async
    func startAutoSync(interval: TimeInterval)
    func stopAutoSync()
}
```

### 4.6 Offline Strategy

**On Assignment Load:**
1. Fetch from API if online
2. Cache to Core Data
3. If offline, load from Core Data

**On Contact Log:**
1. Save to Core Data immediately
2. Add to sync queue
3. If online, sync immediately
4. If offline, sync when connection restored

**Sync Queue:**
- FIFO order
- Retry failed syncs (max 3 attempts)
- Show pending count in UI
- Auto-sync every 5 minutes when online

---

## 5. Agent Boundaries

### 5.1 Agent 1 - Database Engineer
**Owns:**
- `backend/migrations/001_initial_schema.sql`
- Database design decisions
- PostGIS setup
- Indexes and constraints
- RLS policies

**Does NOT touch:**
- Any Python code
- API routes
- Frontend code

**Deliverable:** Complete SQL migration file

### 5.2 Agent 2 - Backend Engineer
**Owns:**
- `backend/app/main.py`
- `backend/app/routes/*.py`
- `backend/app/models/*.py`
- `backend/app/dependencies.py`
- FastAPI application logic

**Does NOT touch:**
- Database schema
- Frontend code
- Test files (Agent 5 owns)

**Deliverable:** Working FastAPI backend with all endpoints

### 5.3 Agent 3 - Frontend Engineer
**Owns:**
- `ios/VEP/Views/*.swift`
- `ios/VEP/Models/*.swift`
- `ios/VEP/ViewModels/*.swift`
- SwiftUI views and view logic

**Does NOT touch:**
- Service layer (Agent 4 owns)
- Backend code
- API client implementation

**Deliverable:** All SwiftUI views with ViewModels

### 5.4 Agent 4 - Integration Engineer
**Owns:**
- `ios/VEP/Services/APIClient.swift`
- `ios/VEP/Services/OfflineStorageService.swift`
- `ios/VEP/Services/SyncService.swift`
- Network layer
- Core Data setup
- Integration between frontend and backend

**Does NOT touch:**
- SwiftUI views
- Backend routes
- Database schema

**Deliverable:** Complete service layer with offline support

### 5.5 Agent 5 - Testing Engineer
**Owns:**
- `backend/tests/*.py`
- `ios/VEPTests/*.swift`
- All test files
- CI/CD configuration

**Does NOT touch:**
- Application code (only reads it)

**Deliverable:** Comprehensive test suite (>80% coverage)

---

## 6. Testing Requirements

### 6.1 Backend Tests

**Unit Tests:**
- Test each route handler
- Test model validation
- Test database functions
- Mock external dependencies

**Integration Tests:**
- Test full request/response cycle
- Test database transactions
- Test RLS policies
- Test error handling

**Coverage Target:** >80%

### 6.2 iOS Tests

**Unit Tests:**
- Test ViewModels
- Test business logic
- Test data transformations
- Mock API client

**Integration Tests:**
- Test APIClient with test server
- Test offline storage
- Test sync logic

**UI Tests:**
- Test critical user flows
- Test offline mode
- Test error states

**Coverage Target:** >70%

---

## 7. Deployment

### 7.1 Backend Deployment

**Platform:** Supabase  
**Steps:**
1. Create Supabase project
2. Run migration file
3. Deploy FastAPI as Supabase Edge Function
4. Set environment variables
5. Test with Postman/curl

### 7.2 iOS Deployment

**Platform:** TestFlight → App Store  
**Steps:**
1. Configure bundle ID
2. Set up signing certificates
3. Build for release
4. Upload to TestFlight
5. Invite beta testers

---

## 8. Success Criteria

**MVP is complete when:**
1. ✅ Manager can create assignments with voter lists
2. ✅ Canvasser can see assigned voters on map
3. ✅ Canvasser can log contacts while offline
4. ✅ Contacts sync when connection restored
5. ✅ Manager can view progress dashboard
6. ✅ All tests pass (>75% coverage)
7. ✅ App deployed to TestFlight
8. ✅ Backend deployed to Supabase

---

## 9. Non-Goals (Out of Scope for MVP)

- ❌ Admin panel (use Supabase dashboard)
- ❌ SMS/email integration
- ❌ Route optimization algorithm
- ❌ Real-time collaboration
- ❌ Android app
- ❌ Web app
- ❌ Advanced analytics/reporting
- ❌ Voter data import (manual for MVP)

---

**This specification is locked. Agents must follow it exactly. Any deviation requires updating this document first.**
