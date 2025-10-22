//
//  AssignmentDetailView.swift
//  VEP
//
//  Created by Agent 3 on 2025-10-22.
//

import SwiftUI
import MapKit

/// Detail view for a single assignment showing voters on a map and list
struct AssignmentDetailView: View {
    let assignment: Assignment
    @State private var showingMap = true
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30.2672, longitude: -97.7431),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Assignment header
                assignmentHeader
                
                // Toggle between map and list
                Picker("View", selection: $showingMap) {
                    Text("Map").tag(true)
                    Text("List").tag(false)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Map or list view
                if showingMap {
                    mapView
                } else {
                    voterList
                }
            }
        }
        .navigationTitle(assignment.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: WalkListView(assignment: assignment)) {
                    Label("Start Walking", systemImage: "figure.walk")
                }
            }
        }
    }
    
    private var assignmentHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Status and progress
            HStack {
                StatusBadge(status: assignment.status)
                
                Spacer()
                
                Text("\(assignment.completedCount) / \(assignment.voterCount) completed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            ProgressView(value: assignment.progress)
                .tint(.blue)
            
            // Description
            if let description = assignment.description {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            // Dates
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Assigned")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(assignment.assignedDate, style: .date)
                        .font(.subheadline)
                }
                
                if let dueDate = assignment.dueDate {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Due")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(dueDate, style: .date)
                            .font(.subheadline)
                            .foregroundColor(assignment.isOverdue ? .red : .primary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private var mapView: some View {
        Map(coordinateRegion: $mapRegion, annotationItems: MockData.voters) { voter in
            MapAnnotation(coordinate: voter.location.clCoordinate) {
                VoterMapPin(voter: voter)
            }
        }
        .frame(height: 400)
        .onAppear {
            // Center map on voters
            if let firstVoter = MockData.voters.first {
                mapRegion = MKCoordinateRegion(
                    center: firstVoter.location.clCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
    }
    
    private var voterList: some View {
        LazyVStack(spacing: 0) {
            ForEach(MockData.voters) { voter in
                NavigationLink(destination: VoterDetailView(voter: voter, assignment: assignment)) {
                    VoterListRow(voter: voter)
                }
                .buttonStyle(.plain)
                
                Divider()
                    .padding(.leading)
            }
        }
    }
}

/// Map pin for voter
struct VoterMapPin: View {
    let voter: Voter
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(pinColor)
                    .frame(width: 30, height: 30)
                
                Text(voter.firstName.prefix(1))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(pinColor)
                .offset(y: -5)
        }
    }
    
    private var pinColor: Color {
        guard let level = voter.supportLevel else { return .gray }
        switch level {
        case 1, 2: return .red
        case 3: return .yellow
        case 4, 5: return .green
        default: return .gray
        }
    }
}

/// Voter row in list
struct VoterListRow: View {
    let voter: Voter
    
    var body: some View {
        HStack(spacing: 12) {
            // Sequence number
            if let order = voter.sequenceOrder {
                Text("\(order)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.accentColor)
                    .cornerRadius(16)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(voter.fullName)
                    .font(.headline)
                
                Text(voter.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    if let party = voter.partyAffiliation {
                        Label(party, systemImage: "person.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let level = voter.supportLevel {
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= level ? "star.fill" : "star")
                                    .font(.caption2)
                                    .foregroundColor(star <= level ? .yellow : .gray)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        AssignmentDetailView(assignment: MockData.assignments[0])
    }
}
