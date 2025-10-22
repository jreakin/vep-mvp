//
//  WalkListView.swift
//  VEP
//
//  Created by Agent 3 on 2025-10-22.
//

import SwiftUI
import MapKit

/// Interactive walk list view with map navigation for canvassing
struct WalkListView: View {
    @StateObject private var viewModel: WalkListViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingContactForm = false
    
    init(assignment: Assignment) {
        _viewModel = StateObject(wrappedValue: WalkListViewModel(assignment: assignment))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Progress header
                progressHeader
                
                // Map showing current voter
                if let voter = viewModel.currentVoter {
                    mapSection(for: voter)
                }
                
                // Current voter card
                if let voter = viewModel.currentVoter {
                    currentVoterCard(voter: voter)
                } else {
                    completedView
                }
                
                // Navigation controls
                navigationControls
            }
            
            // Contact form sheet
            if showingContactForm, let voter = viewModel.currentVoter {
                ContactLogView(
                    assignment: viewModel.assignment,
                    voter: voter,
                    isPresented: $showingContactForm,
                    onSubmit: { log in
                        Task {
                            await viewModel.logContact(
                                contactType: log.contactType,
                                result: log.result,
                                supportLevel: log.supportLevel
                            )
                        }
                    }
                )
            }
        }
        .navigationTitle("Walk List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(viewModel.contactedVoters.count) / \(viewModel.assignment.voterCount) Contacted")
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(viewModel.progress * 100))%")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            ProgressView(value: viewModel.progress)
                .tint(.blue)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private func mapSection(for voter: Voter) -> some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: voter.location.clCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )), annotationItems: [voter]) { voter in
            MapAnnotation(coordinate: voter.location.clCoordinate) {
                VoterMapPin(voter: voter)
            }
        }
        .frame(height: 250)
        .disabled(true)
    }
    
    private func currentVoterCard(voter: Voter) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(voter.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(voter.address)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let order = voter.sequenceOrder {
                    Text("#\(order)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                }
            }
            
            // Voter details
            VStack(alignment: .leading, spacing: 8) {
                if let party = voter.partyAffiliation {
                    DetailRow(icon: "person.fill", label: "Party", value: party)
                }
                
                if let level = voter.supportLevel {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.secondary)
                        Text("Support Level:")
                            .foregroundColor(.secondary)
                        Text(voter.supportLevelDescription)
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                }
                
                if let phone = voter.phone {
                    DetailRow(icon: "phone.fill", label: "Phone", value: phone)
                }
            }
            
            // Last contact
            if let lastContact = voter.lastContact {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last Contact")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(lastContact.displayDate)
                        Text("•")
                        Text(lastContact.type)
                    }
                    .font(.subheadline)
                    
                    if let result = lastContact.result {
                        Text(result)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Action buttons
            HStack(spacing: 12) {
                if let phone = voter.phone {
                    Button(action: { callVoter(phone) }) {
                        Label("Call", systemImage: "phone.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
                Button(action: { openMaps(for: voter) }) {
                    Label("Directions", systemImage: "map.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            
            // Log contact button
            Button(action: { showingContactForm = true }) {
                Label("Log Contact", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
        .padding()
    }
    
    private var completedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)
            
            Text("All Voters Contacted!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Great work! You've completed this assignment.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { dismiss() }) {
                Text("Finish")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var navigationControls: some View {
        HStack(spacing: 20) {
            Button(action: { viewModel.previousVoter() }) {
                Label("Previous", systemImage: "chevron.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.currentVoterIndex == 0)
            
            Button(action: { viewModel.skipVoter() }) {
                Label("Skip", systemImage: "forward.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.nextVoter == nil)
            
            Button(action: { viewModel.nextVoter() }) {
                Label("Next", systemImage: "chevron.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.nextVoter == nil)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private func callVoter(_ phone: String) {
        if let url = URL(string: "tel://\(phone)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openMaps(for voter: Voter) {
        let coordinate = voter.location.clCoordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = voter.fullName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
}

/// Detail row component
struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
            Text(label + ":")
                .foregroundColor(.secondary)
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

#Preview {
    NavigationStack {
        WalkListView(assignment: MockData.assignments[0])
    }
}
