import SwiftUI

/// Main app configuration and initialization
@main
struct VEPApp: App {
    @StateObject private var apiClient = APIClient.shared
    @StateObject private var syncService = SyncService.shared
    @StateObject private var locationService = LocationService.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    init() {
        // Configure services on app launch
        setupServices()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(apiClient)
                .environmentObject(syncService)
                .environmentObject(locationService)
                .environmentObject(networkMonitor)
                .onAppear {
                    // Load saved auth token
                    apiClient.loadAuthToken()
                    
                    // Request location permission
                    locationService.requestPermission()
                    
                    // Start auto-sync
                    syncService.startAutoSync(interval: 300) // 5 minutes
                }
        }
    }
    
    private func setupServices() {
        // Configure API base URL from environment or use default
        // In production, this would come from a configuration file
        
        #if DEBUG
        // Use staging/development server in debug builds
        // APIClient.shared.baseURL = "https://dev.your-project.supabase.co"
        #endif
    }
}

/// Placeholder content view
struct ContentView: View {
    @EnvironmentObject var syncService: SyncService
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        NavigationView {
            VStack {
                // Network status indicator
                HStack {
                    Circle()
                        .fill(networkMonitor.isConnected ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                    Text(networkMonitor.isConnected ? "Online" : "Offline")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Sync status
                if syncService.isSyncing {
                    HStack {
                        ProgressView()
                            .padding(.trailing, 8)
                        Text("Syncing...")
                            .font(.caption)
                    }
                    .padding()
                }
                
                // Pending logs indicator
                if OfflineStorageService.shared.pendingLogsCount > 0 {
                    HStack {
                        Image(systemName: "icloud.and.arrow.up")
                        Text("\(OfflineStorageService.shared.pendingLogsCount) pending logs")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Text("VEP MVP")
                    .font(.largeTitle)
                    .bold()
                
                Text("Voter Engagement Platform")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Views will be added by Agent 3")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
            .navigationTitle("VEP")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SyncService.shared)
        .environmentObject(NetworkMonitor.shared)
}
