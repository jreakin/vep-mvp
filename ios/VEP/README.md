# iOS Service Layer and Offline Sync

This directory contains the integration layer for the VEP MVP iOS application, implementing API communication, offline storage, and data synchronization.

## Architecture Overview

```
Models ← Services ← ViewModels ← Views
         ↓
    Core Data (Offline Storage)
```

## Components

### Models (`/Models`)

Data models matching the backend API schema:

- **User.swift** - User account model with role-based permissions
- **Voter.swift** - Voter information with location data
- **Assignment.swift** - Canvassing assignment with progress tracking
- **ContactLog.swift** - Voter contact event logging
- **Coordinate.swift** - Geographic coordinate helper

All models conform to `Codable` for JSON serialization and `Identifiable` for SwiftUI integration.

### Services (`/Services`)

#### APIClient.swift
REST API client for backend communication:
- JWT authentication management
- All API endpoints from spec (assignments, voters, contact logs)
- Automatic error handling and retries
- Network state monitoring
- Request/response validation

**Usage:**
```swift
let apiClient = APIClient.shared
apiClient.setAuthToken("your-jwt-token")

// Get assignments
let assignments = try await apiClient.getAssignments()

// Create contact log
let log = ContactLog(...)
try await apiClient.createContactLog(log)
```

#### OfflineStorageService.swift
Core Data wrapper for offline caching:
- Cache assignments and voters for offline access
- Queue contact logs when offline
- Automatic conflict resolution
- Pending sync count tracking

**Usage:**
```swift
let storage = OfflineStorageService.shared

// Cache assignment
try storage.cacheAssignment(assignment)

// Queue contact log for sync
try storage.queueContactLog(contactLog)

// Get pending logs
let pending = try storage.getPendingLogs()
```

#### SyncService.swift
Orchestrates offline/online data synchronization:
- Network connectivity monitoring
- Automatic sync when online
- Exponential backoff retry logic (1s, 2s, 4s delays)
- Background sync every 5 minutes (configurable)
- FIFO queue processing

**Usage:**
```swift
let syncService = SyncService.shared

// Start auto-sync (every 5 minutes)
syncService.startAutoSync()

// Manual sync
await syncService.syncPendingLogs()

// Full sync (assignments + logs)
try await syncService.fullSync()
```

#### LocationService.swift
Geolocation tracking and permissions:
- Current location tracking
- Location permission management
- Distance calculations
- MapKit integration helpers

**Usage:**
```swift
let locationService = LocationService.shared

// Request permission
locationService.requestPermission()

// Start tracking
locationService.startTracking()

// Get current location
if let coordinate = locationService.currentCoordinate {
    print("Lat: \(coordinate.latitude), Lng: \(coordinate.longitude)")
}
```

### Core Data Model (`/CoreData`)

The Core Data model mirrors the backend database schema:

#### Entities

1. **CDUser** - Cached user data
   - id, email, fullName, role, phone

2. **CDVoter** - Cached voter data
   - id, voterId, firstName, lastName, address, city, state, zip
   - latitude, longitude (for location)
   - partyAffiliation, supportLevel, phone, email

3. **CDAssignment** - Cached assignment data
   - id, name, description, assignedDate, dueDate, status
   - voterCount, completedCount
   - Relationship: voters (one-to-many)

4. **CDContactLog** - Queued contact logs
   - id, assignmentId, voterId, contactType, result
   - supportLevel, latitude, longitude, contactedAt
   - synced (boolean flag for sync status)

## Offline Strategy

### Data Flow

1. **When Online:**
   - Fetch data from API
   - Cache to Core Data
   - Display from cache
   - Sync contact logs immediately

2. **When Offline:**
   - Load data from Core Data cache
   - Queue contact logs locally
   - Show "offline" indicator
   - Full functionality maintained

3. **When Reconnected:**
   - Auto-detect network availability
   - Sync queued logs (FIFO order)
   - Update cached data
   - Show sync status

### Sync Queue Implementation

Contact logs are synced in FIFO order with:
- **Retry Logic:** 3 attempts per log
- **Exponential Backoff:** 1s → 2s → 4s delays
- **Error Handling:** Continue on individual failures
- **Auto-Sync:** Every 5 minutes when online
- **Manual Sync:** User-triggered via UI

### Conflict Resolution

Core Data merge policy: `NSMergeByPropertyObjectTrumpMergePolicy`
- Server data takes precedence
- Local changes preserved if not synced
- Automatic conflict resolution

## Integration with ViewModels

ViewModels should:
1. Use APIClient for online operations
2. Use OfflineStorageService for caching
3. Use SyncService for background sync
4. Use LocationService for location features

Example ViewModel:
```swift
@MainActor
class AssignmentListViewModel: ObservableObject {
    @Published var assignments: [Assignment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    private let storage = OfflineStorageService.shared
    private let syncService = SyncService.shared
    
    func loadAssignments() async {
        isLoading = true
        
        do {
            // Try to load from API
            assignments = try await apiClient.getAssignments()
            
            // Cache for offline use
            for assignment in assignments {
                try storage.cacheAssignment(assignment)
            }
        } catch {
            // Fallback to cache if offline
            assignments = (try? storage.getAllCachedAssignments()) ?? []
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
```

## Testing

### Unit Tests
- Mock APIClient responses
- Test offline storage CRUD operations
- Verify sync queue behavior
- Test location tracking

### Integration Tests
- Test online → offline → online flow
- Verify data consistency
- Test conflict resolution
- Validate sync retry logic

## Security Considerations

- **Token Storage:** JWT tokens stored in UserDefaults (should use Keychain in production)
- **Data Encryption:** Core Data not encrypted by default (enable in production)
- **Network Security:** HTTPS only, certificate pinning recommended
- **Location Privacy:** Request permission before tracking, explain usage to user

## Performance Optimization

- **Lazy Loading:** Fetch voters only when needed
- **Batch Operations:** Sync multiple logs in single session
- **Background Fetch:** Use iOS background tasks for sync
- **Cache Expiration:** Clear old cached data periodically

## Next Steps

- [ ] Add Keychain for secure token storage
- [ ] Enable Core Data encryption
- [ ] Implement background fetch for sync
- [ ] Add analytics tracking
- [ ] Performance monitoring
- [ ] Crash reporting integration

## Dependencies

- CoreData (built-in)
- CoreLocation (built-in)
- Network (built-in)
- Combine (built-in)

No external dependencies required! All services use iOS native frameworks.
