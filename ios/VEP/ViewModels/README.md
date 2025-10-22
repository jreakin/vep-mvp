# ViewModel Integration Guide

This guide explains how Agent 3's ViewModels should integrate with the service layer.

## Overview

The service layer provides four main services that ViewModels should use:

1. **APIClient** - For API communication
2. **OfflineStorageService** - For caching and offline data
3. **SyncService** - For background synchronization
4. **LocationService** - For geolocation features

## Example ViewModels

Three example ViewModels are provided to demonstrate integration patterns:

### 1. AssignmentListViewModel

**Purpose:** Display list of assignments with offline support

**Key Features:**
- Loads from API when online
- Falls back to cache when offline
- Caches data for offline use
- Search and filter functionality
- Pull-to-refresh with sync

**Usage Pattern:**
```swift
@StateObject private var viewModel = AssignmentListViewModel()

var body: some View {
    List(viewModel.filteredAssignments) { assignment in
        AssignmentRow(assignment: assignment)
    }
    .searchable(text: $viewModel.searchText)
    .refreshable {
        await viewModel.refreshAssignments()
    }
    .task {
        await viewModel.loadAssignments()
    }
}
```

### 2. WalkListViewModel

**Purpose:** Guide canvasser through voter list with contact logging

**Key Features:**
- Current/next voter navigation
- Progress tracking
- Contact logging with offline queueing
- Distance calculations
- Auto-advance after logging contact
- Persistent contacted voter tracking

**Usage Pattern:**
```swift
@StateObject private var viewModel = WalkListViewModel(assignment: assignment)

var body: some View {
    VStack {
        if let voter = viewModel.currentVoter {
            VoterCard(voter: voter)
            
            Button("Log Contact") {
                await viewModel.logContact(
                    contactType: .knocked,
                    result: "Supports candidate",
                    supportLevel: 5
                )
            }
            
            HStack {
                Button("Previous") {
                    viewModel.previousVoter()
                }
                Button("Next") {
                    viewModel.nextVoter()
                }
            }
        }
        
        ProgressView(value: viewModel.progress)
        Text("\(viewModel.remainingCount) voters remaining")
    }
}
```

### 3. ContactLogViewModel

**Purpose:** Form for logging voter contacts

**Key Features:**
- Contact type selection
- Support level picker
- Notes/result field
- Form validation
- Offline queueing
- Quick action buttons

**Usage Pattern:**
```swift
@StateObject private var viewModel = ContactLogViewModel(
    voter: voter,
    assignmentId: assignmentId
)

var body: some View {
    Form {
        Picker("Contact Type", selection: $viewModel.selectedContactType) {
            ForEach(ContactType.allCases, id: \.self) { type in
                Text(type.displayName).tag(type)
            }
        }
        
        TextField("Notes", text: $viewModel.result)
        
        // Support level picker
        Picker("Support", selection: $viewModel.supportLevel) {
            ForEach(viewModel.supportLevels, id: \.0) { level, name, emoji in
                Text("\(emoji) \(name)").tag(Optional(level))
            }
        }
        
        Button("Submit") {
            await viewModel.submit()
        }
        .disabled(!viewModel.canSubmit || viewModel.isSubmitting)
    }
}
```

## Integration Patterns

### Pattern 1: Online-First with Offline Fallback

Use when you want latest data but can work offline:

```swift
func loadData() async {
    do {
        if syncService.isOnline {
            // Try API first
            data = try await apiClient.getData()
            // Cache for offline use
            try storage.cacheData(data)
        } else {
            // Load from cache when offline
            data = try storage.getCachedData()
        }
    } catch {
        // Fallback to cache on error
        if let cached = try? storage.getCachedData() {
            data = cached
            errorMessage = "Using cached data"
        }
    }
}
```

### Pattern 2: Write-Through with Queue

Use for creating/updating data:

```swift
func createItem(_ item: Item) async {
    do {
        if syncService.isOnline {
            // Try to save to API
            _ = try await apiClient.createItem(item)
        } else {
            // Queue for later sync
            try storage.queueItem(item)
        }
    } catch {
        // Queue even if API failed
        try? storage.queueItem(item)
        errorMessage = "Saved offline"
    }
}
```

### Pattern 3: Location-Aware

Use when you need user's location:

```swift
func getCurrentLocation() -> Coordinate? {
    // Request permission if needed
    if locationService.authorizationStatus == .notDetermined {
        locationService.requestPermission()
        return nil
    }
    
    // Return current coordinate
    return locationService.currentCoordinate
}
```

### Pattern 4: Auto-Sync

Services auto-sync in background, but you can trigger manually:

```swift
func refresh() async {
    // Load fresh data
    await loadData()
    
    // Trigger sync of pending changes
    await syncService.syncPendingLogs()
}
```

## Best Practices

### 1. Error Handling

Always provide graceful degradation:

```swift
do {
    data = try await apiClient.getData()
} catch {
    // Try cache
    if let cached = try? storage.getCachedData() {
        data = cached
        showMessage = "Using offline data"
    } else {
        showError = true
        errorMessage = error.localizedDescription
    }
}
```

### 2. Loading States

Show clear loading indicators:

```swift
@Published var isLoading = false

func loadData() async {
    isLoading = true
    defer { isLoading = false }
    
    // ... load data
}
```

### 3. Offline Indicators

Show when offline:

```swift
var statusText: String {
    if syncService.isOnline {
        return "Online"
    } else {
        return "Offline - \(storage.pendingLogsCount) pending"
    }
}
```

### 4. Optimistic Updates

Update UI immediately, sync in background:

```swift
func deleteItem(_ id: UUID) async {
    // Remove from UI immediately
    items.removeAll { $0.id == id }
    
    // Sync in background
    Task {
        try? await apiClient.deleteItem(id)
    }
}
```

### 5. Caching Strategy

Cache aggressively for offline use:

```swift
func loadAssignment(id: UUID) async {
    // Try API first
    if let assignment = try? await apiClient.getAssignment(id: id) {
        // Cache it
        try? storage.cacheAssignment(assignment)
        self.assignment = assignment
    } else {
        // Fall back to cache
        self.assignment = try? storage.getCachedAssignment(id: id)
    }
}
```

## Required EnvironmentObjects

Make services available throughout the app:

```swift
@main
struct VEPApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(APIClient.shared)
                .environmentObject(SyncService.shared)
                .environmentObject(LocationService.shared)
                .environmentObject(NetworkMonitor.shared)
        }
    }
}
```

Access in views:

```swift
struct MyView: View {
    @EnvironmentObject var apiClient: APIClient
    @EnvironmentObject var syncService: SyncService
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        // Use services directly in View if ViewModel not needed
    }
}
```

## Testing ViewModels

Mock services for testing:

```swift
class MockAPIClient: APIClient {
    var mockAssignments: [Assignment] = []
    
    override func getAssignments() async throws -> [Assignment] {
        return mockAssignments
    }
}

// In tests
let viewModel = AssignmentListViewModel()
viewModel.apiClient = MockAPIClient()
```

## Common Gotchas

1. **@MainActor Required** - ViewModels must be @MainActor for UI updates
2. **Async Properly** - Use `await` for async operations, don't block main thread
3. **Error Handling** - Always catch errors and provide fallback
4. **Memory Leaks** - Use `[weak self]` in closures to avoid retain cycles
5. **Cache Invalidation** - Clear stale cache when appropriate

## Migration from Mock Data

If ViewModels currently use mock data:

1. Replace mock data source with API client
2. Add offline storage caching
3. Add error handling with cache fallback
4. Test offline behavior
5. Remove mock data

Example:

```swift
// Before (mock)
@Published var assignments = Assignment.mockData

// After (real)
@Published var assignments: [Assignment] = []

func loadAssignments() async {
    do {
        assignments = try await apiClient.getAssignments()
        for assignment in assignments {
            try? storage.cacheAssignment(assignment)
        }
    } catch {
        assignments = (try? storage.getAllCachedAssignments()) ?? []
    }
}
```

## Next Steps for Agent 3

1. Review the three example ViewModels
2. Understand the integration patterns
3. Apply these patterns to your Views
4. Test offline functionality
5. Add proper error handling
6. Remove any mock data dependencies

The service layer is complete and ready for integration!
