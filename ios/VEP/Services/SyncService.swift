import Foundation
import Combine
import Network

/// Sync service for managing offline/online data synchronization
@MainActor
class SyncService: ObservableObject {
    static let shared = SyncService()
    
    @Published var isSyncing = false
    @Published var isOnline = true
    @Published var lastSyncDate: Date?
    @Published var syncError: Error?
    
    private let apiClient = APIClient.shared
    private let storage = OfflineStorageService.shared
    private var syncTimer: Timer?
    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupNetworkMonitoring()
        loadLastSyncDate()
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                let online = path.status == .satisfied
                self?.isOnline = online
                
                // Auto-sync when coming back online
                if online, let self = self {
                    await self.syncPendingLogs()
                }
            }
        }
        networkMonitor.start(queue: monitorQueue)
    }
    
    // MARK: - Auto Sync
    
    /// Start automatic syncing at specified interval (in seconds)
    func startAutoSync(interval: TimeInterval = 300) { // Default 5 minutes
        stopAutoSync()
        
        syncTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.syncPendingLogs()
            }
        }
    }
    
    /// Stop automatic syncing
    func stopAutoSync() {
        syncTimer?.invalidate()
        syncTimer = nil
    }
    
    // MARK: - Sync Operations
    
    /// Sync all pending contact logs to the server
    func syncPendingLogs() async {
        guard isOnline && !isSyncing else { return }
        
        isSyncing = true
        syncError = nil
        
        do {
            let pendingLogs = try storage.getPendingLogs()
            
            if pendingLogs.isEmpty {
                isSyncing = false
                return
            }
            
            // Sync each log with retry logic
            for log in pendingLogs {
                do {
                    _ = try await syncContactLog(log)
                    try storage.markLogAsSynced(id: log.id)
                } catch {
                    // Log the error but continue with other logs
                    print("Failed to sync log \(log.id): \(error)")
                    
                    // Only set error for the first failure
                    if syncError == nil {
                        syncError = error
                    }
                }
            }
            
            // Clean up old synced logs
            try storage.clearSyncedLogs()
            
            // Update last sync date
            lastSyncDate = Date()
            saveLastSyncDate()
            
        } catch {
            syncError = error
            print("Sync failed: \(error)")
        }
        
        isSyncing = false
    }
    
    /// Sync a single contact log with retry logic
    private func syncContactLog(_ log: ContactLog, retryCount: Int = 0) async throws -> ContactLog {
        do {
            return try await apiClient.createContactLog(log)
        } catch {
            // Retry up to 3 times with exponential backoff
            if retryCount < 3 {
                let delay = pow(2.0, Double(retryCount)) // 1s, 2s, 4s
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await syncContactLog(log, retryCount: retryCount + 1)
            } else {
                throw error
            }
        }
    }
    
    /// Sync assignments from server to local cache
    func syncAssignments() async throws {
        guard isOnline else {
            throw SyncError.offline
        }
        
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            let assignments = try await apiClient.getAssignments()
            
            // Cache each assignment
            for assignment in assignments {
                try storage.cacheAssignment(assignment)
                
                // Fetch full assignment with voters
                if let detailedAssignment = try? await apiClient.getAssignment(id: assignment.id) {
                    try storage.cacheAssignment(detailedAssignment)
                }
            }
            
            lastSyncDate = Date()
            saveLastSyncDate()
            
        } catch {
            syncError = error
            throw error
        }
    }
    
    /// Force a full sync of all data
    func fullSync() async throws {
        guard isOnline else {
            throw SyncError.offline
        }
        
        isSyncing = true
        defer { isSyncing = false }
        
        // Sync assignments first
        try await syncAssignments()
        
        // Then sync pending logs
        await syncPendingLogs()
    }
    
    // MARK: - Last Sync Date Management
    
    private func loadLastSyncDate() {
        if let timestamp = UserDefaults.standard.object(forKey: "last_sync_date") as? Date {
            lastSyncDate = timestamp
        }
    }
    
    private func saveLastSyncDate() {
        if let date = lastSyncDate {
            UserDefaults.standard.set(date, forKey: "last_sync_date")
        }
    }
}

// MARK: - Sync Errors

enum SyncError: LocalizedError {
    case offline
    case syncInProgress
    case noDataToSync
    
    var errorDescription: String? {
        switch self {
        case .offline:
            return "Cannot sync while offline"
        case .syncInProgress:
            return "Sync already in progress"
        case .noDataToSync:
            return "No data to sync"
        }
    }
}
