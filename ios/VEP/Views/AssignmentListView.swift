//
//  AssignmentListView.swift
//  VEP
//
//  Created by Agent 3 on 2025-10-22.
//

import SwiftUI

/// Main view showing list of assignments for the current user
struct AssignmentListView: View {
    @StateObject private var viewModel = AssignmentListViewModel()
    @State private var selectedStatus: AssignmentStatus?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter buttons
                filterBar
                
                // Assignment list
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.assignments.isEmpty {
                    emptyStateView
                } else {
                    assignmentList
                }
            }
            .navigationTitle("Assignments")
            .searchable(text: Binding(
                get: { viewModel.searchText },
                set: { viewModel.updateSearchText($0) }
            ), prompt: "Search assignments")
            .refreshable {
                await viewModel.refreshAssignments()
            }
            .task {
                await viewModel.loadAssignments()
            }
        }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: selectedStatus == nil
                ) {
                    selectedStatus = nil
                    viewModel.filterByStatus(nil)
                }
                
                ForEach(AssignmentStatus.allCases, id: \.self) { status in
                    FilterChip(
                        title: status.displayName,
                        isSelected: selectedStatus == status
                    ) {
                        selectedStatus = status
                        viewModel.filterByStatus(status)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }
    
    private var assignmentList: some View {
        List(viewModel.assignments) { assignment in
            NavigationLink(destination: AssignmentDetailView(assignment: assignment)) {
                AssignmentRow(assignment: assignment)
            }
        }
        .listStyle(.plain)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("No Assignments Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Pull to refresh or check back later")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Row view for a single assignment
struct AssignmentRow: View {
    let assignment: Assignment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title and status
            HStack {
                Text(assignment.name)
                    .font(.headline)
                
                Spacer()
                
                StatusBadge(status: assignment.status)
            }
            
            // Description if available
            if let description = assignment.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Progress and dates
            HStack {
                // Progress
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(assignment.completedCount)/\(assignment.voterCount)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                // Due date
                if let dueDate = assignment.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: assignment.isOverdue ? "exclamationmark.triangle.fill" : "calendar")
                            .foregroundColor(assignment.isOverdue ? .red : .secondary)
                        Text(dueDate, style: .date)
                            .font(.caption)
                            .foregroundColor(assignment.isOverdue ? .red : .secondary)
                    }
                }
            }
            
            // Progress bar
            ProgressView(value: assignment.progress)
                .tint(.blue)
        }
        .padding(.vertical, 4)
    }
}

/// Filter chip button
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

/// Status badge view
struct StatusBadge: View {
    let status: AssignmentStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(4)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .pending: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}

#Preview {
    AssignmentListView()
}
