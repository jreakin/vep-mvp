//
//  LoginView.swift
//  VEP
//
//  Created by Agent 3 on 2025-10-22.
//

import SwiftUI

/// Login view for authentication
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isAuthenticated = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Logo and title
                VStack(spacing: 12) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.accentColor)
                    
                    Text("VEP Canvassing")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Voter Engagement Platform")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Login form
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text("Sign In")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(isLoading || !isFormValid)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Footer
                VStack(spacing: 8) {
                    Text("Demo Credentials:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Email: demo@vep.com")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Password: demo123")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 32)
            }
            .navigationDestination(isPresented: $isAuthenticated) {
                MainTabView()
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    private func login() {
        isLoading = true
        errorMessage = nil
        
        Task {
            // Simulate API call
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Simple validation for demo
            if email == "demo@vep.com" && password == "demo123" {
                isAuthenticated = true
            } else {
                errorMessage = "Invalid email or password"
            }
            
            isLoading = false
        }
    }
}

/// Main tab view after login
struct MainTabView: View {
    var body: some View {
        TabView {
            AssignmentListView()
                .tabItem {
                    Label("Assignments", systemImage: "list.bullet")
                }
            
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

/// Profile view placeholder
struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text("Demo User")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Email")
                        Spacer()
                        Text("demo@vep.com")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Role")
                        Spacer()
                        Text("Canvasser")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("App") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Sign Out", role: .destructive) {
                        // Sign out action
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    LoginView()
}
