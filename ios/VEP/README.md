# VEP iOS App

This directory contains the SwiftUI iOS application for the Voter Engagement Platform (VEP).

## Structure

```
ios/VEP/
├── Models/              # Data models matching backend API
│   ├── User.swift
│   ├── Voter.swift
│   ├── Assignment.swift
│   └── ContactLog.swift
├── ViewModels/          # MVVM view models with business logic
│   ├── AssignmentListViewModel.swift
│   ├── WalkListViewModel.swift
│   └── ContactLogViewModel.swift
├── Views/               # SwiftUI views
│   ├── AssignmentListView.swift
│   ├── AssignmentDetailView.swift
│   ├── WalkListView.swift
│   ├── VoterDetailView.swift
│   ├── ContactLogView.swift
│   ├── AnalyticsView.swift
│   └── LoginView.swift
├── Services/            # (To be added by Agent 4)
│   ├── APIClient.swift
│   ├── OfflineStorageService.swift
│   └── SyncService.swift
└── VEPApp.swift         # Main app entry point
```

## Features

- **MVVM Architecture**: Clean separation of concerns with Models, Views, and ViewModels
- **MapKit Integration**: Interactive maps showing voter locations
- **Offline Support**: Designed for offline-first workflow (services to be added by Agent 4)
- **Mock Data**: Currently using mock data for development and testing
- **SwiftUI**: Modern declarative UI framework for iOS 17+

## Views

### AssignmentListView
Main view showing all assignments for the current user with search and filter capabilities.

### AssignmentDetailView
Detailed view of a single assignment with map and list of voters.

### WalkListView
Interactive canvassing interface with map navigation and contact logging.

### VoterDetailView
Detailed voter information with contact history and quick actions.

### ContactLogView
Form for logging voter contacts with support level and notes.

### AnalyticsView
Dashboard showing campaign progress and metrics (manager view).

### LoginView
Authentication screen with demo credentials.

## Models

All models conform to `Codable` for JSON serialization and `Identifiable` for SwiftUI lists.

- **User**: Campaign staff member
- **Voter**: Individual voter with location and support level
- **Assignment**: Canvassing assignment with list of voters
- **ContactLog**: Record of voter interaction

## ViewModels

ViewModels use `@MainActor` and `ObservableObject` for reactive state management.

- **AssignmentListViewModel**: Manages assignment list, search, and filtering
- **WalkListViewModel**: Manages walk list navigation and progress tracking
- **ContactLogViewModel**: Handles contact form validation and submission

## Building

This iOS app is designed to be opened in Xcode. To build:

1. Open Xcode
2. Navigate to the `ios/VEP` directory
3. Create a new iOS App project and add these files
4. Build and run in the iOS Simulator

## Next Steps

Agent 4 will add:
- APIClient for real backend integration
- OfflineStorageService with Core Data
- SyncService for offline queue management
- LocationService for MapKit integration

## Testing

Run tests in Xcode:
```bash
cmd+U
```

## Demo Credentials

- Email: `demo@vep.com`
- Password: `demo123`
