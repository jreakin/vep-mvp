# GitHub Copilot Agent 4: Integration Engineer

## 🎯 Your Mission
You are Agent 4: Integration Engineer. Connect the iOS frontend to the backend API and implement offline functionality.

## 📋 Instructions for GitHub Copilot

### Step 1: Read the Specification
1. Open `spec.md` and read Section 5: Integration & Offline Strategy
2. Open `backend/app/` (from Agent 2) to understand API endpoints
3. Open `ios/VEP/` (from Agent 3) to understand current structure
4. Open `AGENT_INSTRUCTIONS.md` and read the Agent 4 section

### Step 2: Create Integration Files

**Files to Create:**
- `ios/VEP/Services/APIClient.swift` - REST API client
- `ios/VEP/Services/OfflineStorageService.swift` - Core Data offline storage
- `ios/VEP/Services/SyncService.swift` - Data synchronization
- `ios/VEP/Services/LocationService.swift` - Location services
- `ios/VEP/CoreData/VEP.xcdatamodeld` - Core Data model
- Update Agent 3's ViewModels to use real services

### Step 3: Required Services

**APIClient:**
- REST API communication
- JWT authentication
- Request/response handling
- Error handling and retries
- Background task support

**OfflineStorageService:**
- Core Data model matching backend schema
- CRUD operations for all entities
- Offline data persistence
- Data validation
- Conflict resolution

**SyncService:**
- FIFO sync queue
- Retry logic with exponential backoff
- Conflict resolution
- Background sync
- Network state monitoring

**LocationService:**
- Current location tracking
- Geofencing for canvassing areas
- Location-based notifications
- Privacy compliance

### Step 4: Core Data Model

**Entities to Create:**
- User (matches backend users table)
- Voter (matches backend voters table)
- Assignment (matches backend assignments table)
- AssignmentVoter (matches backend assignment_voters table)
- ContactLog (matches backend contact_logs table)

**Relationships:**
- Assignment -> AssignmentVoter (one-to-many)
- AssignmentVoter -> Voter (many-to-one)
- AssignmentVoter -> ContactLog (one-to-many)
- User -> Assignment (one-to-many, for managers)

### Step 5: Offline Strategy

**Data Sync:**
- Download assignments when online
- Store voter data locally
- Queue contact logs when offline
- Sync when connection restored
- Handle conflicts gracefully

**User Experience:**
- Show offline indicator
- Cache recent data
- Allow full functionality offline
- Background sync when possible
- Clear sync status

### Step 6: Success Criteria
- [ ] API client connects to backend
- [ ] Authentication working
- [ ] Core Data model created
- [ ] Offline storage implemented
- [ ] Sync service working
- [ ] Location services integrated
- [ ] ViewModels use real data
- [ ] App works offline and syncs online
- [ ] No more mock data

### Step 7: Testing
After creating the integration:
1. Test API connectivity
2. Test offline functionality
3. Test sync when online
4. Test location services
5. Test authentication flow

## 🚀 Ready to Start?

Open VS Code with GitHub Copilot and say:
"I need to create the integration layer for the VEP MVP project. Please read spec.md Section 5 and create all the service files with API integration and offline functionality."