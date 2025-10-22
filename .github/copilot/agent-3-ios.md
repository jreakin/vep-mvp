# GitHub Copilot Agent 3: iOS Frontend Engineer

## 🎯 Your Mission
You are Agent 3: iOS Frontend Engineer. Create the complete SwiftUI frontend for the VEP MVP voter engagement platform.

## 📋 Instructions for GitHub Copilot

### Step 1: Read the Specification
1. Open `spec.md` and read Section 4: iOS App Architecture
2. Open `backend/app/` (from Agent 2) to understand API structure
3. Open `AGENT_INSTRUCTIONS.md` and read the Agent 3 section

### Step 2: Create iOS Files

**Files to Create:**
- `ios/VEP/Models/` - Swift data models:
  - `User.swift` - User model
  - `Voter.swift` - Voter model
  - `Assignment.swift` - Assignment model
  - `ContactLog.swift` - Contact log model
- `ios/VEP/ViewModels/` - MVVM view models:
  - `AssignmentListViewModel.swift` - Assignment list logic
  - `WalkListViewModel.swift` - Walk list with map logic
  - `ContactLogViewModel.swift` - Contact logging logic
- `ios/VEP/Views/` - SwiftUI views:
  - `AssignmentListView.swift` - Assignment list screen
  - `AssignmentDetailView.swift` - Assignment details
  - `WalkListView.swift` - Walk list with map
  - `VoterDetailView.swift` - Individual voter details
  - `ContactLogView.swift` - Contact logging form
  - `AnalyticsView.swift` - Progress dashboard
  - `LoginView.swift` - Authentication screen

### Step 3: Required Features

**Core Views:**
- Assignment list with search and filters
- Assignment detail with voter list
- Interactive map with voter locations
- Voter detail with contact history
- Contact logging form with validation
- Analytics dashboard with progress charts
- Login/authentication screen

**MapKit Integration:**
- Display voters on map with custom pins
- Show canvasser's current location
- Calculate walking routes between voters
- Cluster nearby voters
- Search by address or voter name

**MVVM Architecture:**
- ViewModels handle business logic
- Models match backend API structure
- Views are declarative and reactive
- Proper state management
- Error handling and loading states

**Mock Data (for now):**
- Create realistic sample data
- Use mock data in ViewModels
- Real API integration comes in Agent 4

### Step 4: Technical Requirements

**SwiftUI Features:**
- iOS 17+ compatibility
- Dark mode support
- Accessibility features
- Responsive design
- Navigation between screens

**MapKit:**
- Custom map annotations
- Location services
- Geocoding and reverse geocoding
- Route calculation
- Map clustering

**Data Models:**
- Codable for JSON serialization
- Identifiable for SwiftUI lists
- ObservableObject for ViewModels
- Proper error handling

### Step 5: Success Criteria
- [ ] All SwiftUI views created
- [ ] MVVM architecture implemented
- [ ] MapKit integration working
- [ ] Navigation flow complete
- [ ] Form validation implemented
- [ ] App builds without errors
- [ ] UI matches specification
- [ ] Mock data displays correctly

### Step 6: Testing
After creating the iOS app:
1. Open in Xcode: `open ios/VEP/VEP.xcodeproj`
2. Build and run in simulator
3. Test all navigation flows
4. Verify map functionality
5. Check form validation

## 🚀 Ready to Start?

Open VS Code with GitHub Copilot and say:
"I need to create the SwiftUI iOS app for the VEP MVP project. Please read spec.md Section 4 and create all the iOS files with the complete UI implementation using MapKit."