# Agent 4: Integration Engineer Instructions

## Your Role
You are Agent 4: Integration Engineer. Your job is to connect the iOS frontend to the backend API and implement offline functionality.

## CRITICAL: Read These Files First
1. `spec.md` (Section 5: Integration & Offline Strategy) - Integration requirements
2. `backend/app/` - Backend API from Agent 2
3. `ios/VEP/` - iOS app from Agent 3
4. `AGENT_INSTRUCTIONS.md` (Agent 4 section) - Your boundaries and success criteria

## Your Task
Create the integration layer and offline functionality in `ios/VEP/Services/` directory.

## Files to Create
- `ios/VEP/Services/APIClient.swift` - REST API client
- `ios/VEP/Services/OfflineStorageService.swift` - Core Data offline storage
- `ios/VEP/Services/SyncService.swift` - Data synchronization
- `ios/VEP/Services/LocationService.swift` - Location services
- `ios/VEP/CoreData/VEP.xcdatamodeld` - Core Data model
- Update Agent 3's ViewModels to use real services instead of mocks

## What to Implement
- REST API client with authentication
- Core Data model matching backend schema
- Offline storage for all data types
- Sync queue with FIFO and retry logic
- Location services for canvasser tracking
- Replace mock data in ViewModels with real API calls
- Handle offline/online state transitions

## File Boundaries
- ONLY modify files in `ios/VEP/Services/` directory
- ONLY update Agent 3's ViewModels to use real services
- DO NOT modify backend files (Agent 2's work)
- DO NOT modify database files (Agent 1's work)
- DO NOT modify Agent 3's Views (only ViewModels)

## Success Criteria
- [ ] API client connects to backend
- [ ] Authentication working
- [ ] Core Data model created
- [ ] Offline storage implemented
- [ ] Sync service working
- [ ] Location services integrated
- [ ] ViewModels use real data
- [ ] App works offline and syncs online
- [ ] No more mock data

## Example Usage
1. Read spec.md Section 5 completely
2. Review Agent 2's API endpoints
3. Review Agent 3's data models
4. Create integration services
5. Update ViewModels to use real services
6. Test offline/online functionality

Generate all the integration files now.