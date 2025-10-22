import Foundation
import SwiftUI

/// ViewModel for the assignment list view
@MainActor
class AssignmentListViewModel: ObservableObject {
    @Published var assignments: [Assignment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var filterStatus: AssignmentStatus?
    @Published var searchText = ""
    
    private let apiClient = APIClient.shared
    private let storage = OfflineStorageService.shared
    private let syncService = SyncService.shared
    
    // Filtered assignments based on search and filter
    var filteredAssignments: [Assignment] {
        var result = assignments
        
        // Apply status filter
        if let status = filterStatus {
            result = result.filter { $0.status == status }
        }
        
        // Apply search
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return result
    }
    
    /// Load assignments from API or cache
    func loadAssignments() async {
        isLoading = true
        errorMessage = nil
        
        do {
            if syncService.isOnline {
                // Load from API when online
                assignments = try await apiClient.getAssignments()
                
                // Cache for offline use
                for assignment in assignments {
                    try storage.cacheAssignment(assignment)
                }
            } else {
                // Load from cache when offline
                assignments = try storage.getAllCachedAssignments()
            }
        } catch {
            // Fallback to cache on error
            if let cachedAssignments = try? storage.getAllCachedAssignments() {
                assignments = cachedAssignments
                errorMessage = "Using cached data: \(error.localizedDescription)"
            } else {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    /// Refresh assignments (pull-to-refresh)
    func refreshAssignments() async {
        await loadAssignments()
        
        // Also trigger a sync
        if syncService.isOnline {
            await syncService.syncPendingLogs()
        }
    }
    
    /// Filter assignments by status
    func filterByStatus(_ status: AssignmentStatus?) {
        filterStatus = status
    }
    
    /// Clear search and filters
    func clearFilters() {
        searchText = ""
        filterStatus = nil
    }
}
