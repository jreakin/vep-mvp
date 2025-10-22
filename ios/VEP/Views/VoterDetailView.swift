//
//  VoterDetailView.swift
//  VEP
//
//  Created by Agent 3 on 2025-10-22.
//

import SwiftUI
import MapKit

/// Detailed view of a single voter with contact history
struct VoterDetailView: View {
    let voter: Voter
    let assignment: Assignment
    @State private var showingContactForm = false
    @State private var contactHistory: [ContactLog] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Voter info card
                voterInfoCard
                
                // Map
                voterMapSection
                
                // Quick actions
                quickActionsSection
                
                // Contact history
                contactHistorySection
            }
            .padding()
        }
        .navigationTitle(voter.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingContactForm) {
            NavigationStack {
                ContactLogView(
                    assignment: assignment,
                    voter: voter,
                    isPresented: $showingContactForm,
                    onSubmit: { log in
                        contactHistory.append(log)
                    }
                )
            }
        }
        .task {
            // Load contact history
            // Agent 4 will replace with real API call
        }
    }
    
    private var voterInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Name
            Text(voter.fullName)
                .font(.title2)
                .fontWeight(.bold)
            
            // Address
            VStack(alignment: .leading, spacing: 4) {
                Label(voter.address, systemImage: "mappin.circle.fill")
                Text("\(voter.city), \(voter.state) \(voter.zip)")
                    .foregroundColor(.secondary)
            }
            .font(.body)
            
            Divider()
            
            // Details grid
            VStack(spacing: 8) {
                if let party = voter.partyAffiliation {
                    InfoRow(label: "Party", value: party, icon: "person.fill")
                }
                
                if let level = voter.supportLevel {
                    InfoRow(label: "Support", value: voter.supportLevelDescription, icon: "star.fill")
                }
                
                if let phone = voter.phone {
                    InfoRow(label: "Phone", value: phone, icon: "phone.fill")
                }
                
                if let email = voter.email {
                    InfoRow(label: "Email", value: email, icon: "envelope.fill")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var voterMapSection: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: voter.location.clCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )), annotationItems: [voter]) { voter in
            MapAnnotation(coordinate: voter.location.clCoordinate) {
                VoterMapPin(voter: voter)
            }
        }
        .frame(height: 200)
        .cornerRadius(12)
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                if let phone = voter.phone {
                    ActionButton(icon: "phone.fill", title: "Call") {
                        if let url = URL(string: "tel://\(phone)") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                
                ActionButton(icon: "map.fill", title: "Directions") {
                    openMaps()
                }
                
                ActionButton(icon: "plus.circle.fill", title: "Log Contact") {
                    showingContactForm = true
                }
            }
        }
    }
    
    private var contactHistorySection: some View {
        VStack(spacing: 12) {
            Text("Contact History")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if contactHistory.isEmpty && voter.lastContact == nil {
                Text("No contacts recorded yet")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    // Show last contact from voter data
                    if let lastContact = voter.lastContact {
                        ContactHistoryRow(
                            type: lastContact.type,
                            date: lastContact.displayDate,
                            result: lastContact.result
                        )
                    }
                    
                    // Show additional contact logs
                    ForEach(contactHistory) { log in
                        ContactHistoryRow(
                            type: log.contactType.displayName,
                            date: formatDate(log.contactedAt),
                            result: log.result
                        )
                    }
                }
            }
        }
    }
    
    private func openMaps() {
        let coordinate = voter.location.clCoordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = voter.fullName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

/// Info row for voter details
struct InfoRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .fontWeight(.medium)
            
            Spacer()
        }
        .font(.subheadline)
    }
}

/// Action button component
struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

/// Contact history row
struct ContactHistoryRow: View {
    let type: String
    let date: String
    let result: String?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "circle.fill")
                .font(.caption2)
                .foregroundColor(.accentColor)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(type)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let result = result {
                    Text(result)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        VoterDetailView(voter: MockData.voters[0], assignment: MockData.assignments[0])
    }
}
