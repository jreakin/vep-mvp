//
//  AnalyticsView.swift
//  VEP
//
//  Created by Agent 3 on 2025-10-22.
//

import SwiftUI
import Charts

/// Analytics dashboard showing campaign progress and metrics
struct AnalyticsView: View {
    @State private var analytics = AnalyticsData.mock
    @State private var isLoading = false
    @State private var selectedTimeframe: Timeframe = .week
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Timeframe picker
                    timeframePicker
                    
                    // Stats overview
                    statsGrid
                    
                    // Support level chart
                    supportLevelChart
                    
                    // Contact type breakdown
                    contactTypeChart
                    
                    // Recent activity
                    recentActivitySection
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .refreshable {
                await loadAnalytics()
            }
        }
    }
    
    private var timeframePicker: some View {
        Picker("Timeframe", selection: $selectedTimeframe) {
            Text("Today").tag(Timeframe.today)
            Text("Week").tag(Timeframe.week)
            Text("Month").tag(Timeframe.month)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: "Total Voters",
                value: "\(analytics.totalVoters)",
                icon: "person.3.fill",
                color: .blue
            )
            
            StatCard(
                title: "Contacted",
                value: "\(analytics.contacted)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            StatCard(
                title: "Contact Rate",
                value: "\(analytics.contactRate)%",
                icon: "chart.line.uptrend.xyaxis",
                color: .orange
            )
            
            StatCard(
                title: "Avg Support",
                value: String(format: "%.1f", analytics.averageSupport),
                icon: "star.fill",
                color: .yellow
            )
        }
    }
    
    private var supportLevelChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support Distribution")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(Array(analytics.supportDistribution.sorted(by: { $0.key < $1.key })), id: \.key) { level, count in
                    SupportLevelBar(
                        level: level,
                        count: count,
                        total: analytics.contacted
                    )
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    private var contactTypeChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact Methods")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(Array(analytics.contactTypes.sorted(by: { $0.value > $1.value })), id: \.key) { type, count in
                    ContactTypeRow(type: type, count: count, total: analytics.contacted)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 1) {
                ForEach(analytics.recentActivity) { activity in
                    ActivityRow(activity: activity)
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    private func loadAnalytics() async {
        isLoading = true
        // Simulate API call
        try? await Task.sleep(nanoseconds: 500_000_000)
        // Agent 4 will replace with real API call
        analytics = AnalyticsData.mock
        isLoading = false
    }
}

/// Stat card component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

/// Support level bar
struct SupportLevelBar: View {
    let level: Int
    let count: Int
    let total: Int
    
    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(levelDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(count)")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                    
                    Rectangle()
                        .fill(levelColor)
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 8)
            .cornerRadius(4)
        }
    }
    
    private var levelDescription: String {
        switch level {
        case 1: return "Strong Opponent"
        case 2: return "Lean Opponent"
        case 3: return "Undecided"
        case 4: return "Lean Support"
        case 5: return "Strong Support"
        default: return "Unknown"
        }
    }
    
    private var levelColor: Color {
        switch level {
        case 1, 2: return .red
        case 3: return .yellow
        case 4, 5: return .green
        default: return .gray
        }
    }
}

/// Contact type row
struct ContactTypeRow: View {
    let type: String
    let count: Int
    let total: Int
    
    var percentage: Int {
        guard total > 0 else { return 0 }
        return Int((Double(count) / Double(total)) * 100)
    }
    
    var body: some View {
        HStack {
            Text(type.capitalized)
                .font(.subheadline)
            
            Spacer()
            
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text("(\(percentage)%)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

/// Activity row
struct ActivityRow: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.userName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(activity.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(activity.timeAgo)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

/// Data models for analytics
enum Timeframe {
    case today, week, month
}

struct AnalyticsData {
    let totalVoters: Int
    let contacted: Int
    let supportDistribution: [Int: Int]
    let contactTypes: [String: Int]
    let recentActivity: [Activity]
    
    var contactRate: Int {
        guard totalVoters > 0 else { return 0 }
        return Int((Double(contacted) / Double(totalVoters)) * 100)
    }
    
    var averageSupport: Double {
        let total = supportDistribution.reduce(0) { $0 + ($1.key * $1.value) }
        let count = supportDistribution.values.reduce(0, +)
        guard count > 0 else { return 0 }
        return Double(total) / Double(count)
    }
    
    static let mock = AnalyticsData(
        totalVoters: 10000,
        contacted: 3547,
        supportDistribution: [1: 423, 2: 891, 3: 1134, 4: 678, 5: 421],
        contactTypes: ["knocked": 2890, "not_home": 457, "refused": 200],
        recentActivity: [
            Activity(userName: "John Doe", description: "Contacted 15 voters", timeAgo: "2m ago"),
            Activity(userName: "Jane Smith", description: "Completed Downtown assignment", timeAgo: "15m ago"),
            Activity(userName: "Bob Johnson", description: "Started East Austin assignment", timeAgo: "1h ago")
        ]
    )
}

struct Activity: Identifiable {
    let id = UUID()
    let userName: String
    let description: String
    let timeAgo: String
}

#Preview {
    AnalyticsView()
}
