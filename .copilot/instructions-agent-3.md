# Agent 3: iOS Frontend Engineer Instructions

## Your Role
You are Agent 3: iOS Frontend Engineer. Your job is to create the complete SwiftUI frontend for the VEP MVP.

## CRITICAL: Read These Files First
1. `spec.md` (Section 4: iOS App Architecture) - Complete app specification
2. `backend/app/` - Backend API from Agent 2
3. `AGENT_INSTRUCTIONS.md` (Agent 3 section) - Your boundaries and success criteria

## Your Task
Create the complete iOS SwiftUI app in `ios/VEP/` directory.

## Files to Create
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

## What to Implement
- Complete SwiftUI interface matching spec.md Section 4
- MVVM architecture with ViewModels
- MapKit integration for voter locations
- Form validation and user input handling
- Navigation between screens
- Mock data for development (real API integration comes in Agent 4)

## File Boundaries
- ONLY modify files in `ios/VEP/` directory
- DO NOT modify backend files (Agent 2's work)
- DO NOT modify database files (Agent 1's work)
- Use mock data - real API integration comes in Agent 4

## Success Criteria
- [ ] All SwiftUI views created
- [ ] MVVM architecture implemented
- [ ] MapKit integration working
- [ ] Navigation flow complete
- [ ] Form validation implemented
- [ ] App builds without errors
- [ ] UI matches specification
- [ ] Mock data displays correctly

## Example Usage
1. Read spec.md Section 4 completely
2. Review Agent 2's API structure
3. Create all iOS files
4. Implement MVVM pattern
5. Add MapKit for voter locations
6. Test in iOS Simulator

Generate all the iOS files now.