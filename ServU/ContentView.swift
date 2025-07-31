//
//  ContentView.swift
//  ServU
//
//  Created by Quian Bowden on 6/27/25.
//  Updated by Assistant on 7/19/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // This connects your view to the Microsoft authentication manager
    @StateObject private var msalManager = MSALManager()
    
    var body: some View {
        Group {
            if msalManager.isSignedIn {
                // User is signed in - show main app
                MainTabView(msalManager: msalManager)
                    .transition(.opacity)
            } else {
                // User is not signed in - show welcome/login screen
                WelcomeView(msalManager: msalManager)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: msalManager.isSignedIn)
        .onAppear {
            // When the view appears, check if user is already signed in
            msalManager.loadCurrentAccount()
        }
    }
}

// MARK: - Welcome/Login View
struct WelcomeView: View {
    @ObservedObject var msalManager: MSALManager
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(.white), Color("paleBrown")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Username label at the top (only show if we have a user but not fully signed in)
                if !msalManager.currentUser.isEmpty {
                    HStack {
                        Spacer()
                        Text(msalManager.currentUser)
                            .foregroundColor(.gray)
                            .padding(.trailing, 10)
                            .padding(.top, 10)
                    }
                }
                
                Spacer()
                
                // Welcome title
                Text("Welcome to ServU!")
                    .font(.system(size: 32))
                    .foregroundColor(Color("basicBrown"))
                    .fontWeight(.semibold)
                    .padding(.top, 25)
                
                // Subtitle
                Text("Connecting students with services at their college")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Logo placeholder
                Image(systemName: "graduationcap.circle.fill")
                    .font(.system(size: 120))
                    .foregroundColor(Color("basicBrown"))
                    .padding(.vertical, 30)
                
                // Main action buttons
                VStack(spacing: 15) {
                    // Sign In with Microsoft button
                    Button(action: login) {
                        HStack(spacing: 12) {
                            Image(systemName: "microsoft.logo")
                                .font(.system(size: 18))
                            Text("Sign in with College Email")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color("darkBrown"))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    
                    // Info text
                    Text("Use your college email (@college.edu) to connect with services at your school")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Debug section (only show in development)
                if !msalManager.loggingText.isEmpty {
                    debugSectionView
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Debug Section
    private var debugSectionView: some View {
        VStack(spacing: 10) {
            // Debug buttons (for testing)
            VStack(spacing: 10) {
                HStack(spacing: 15) {
                    Button(action: callGraphAPI) {
                        Text("Test Graph API")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Button(action: getDeviceMode) {
                        Text("Device Info")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    if msalManager.isSignedIn {
                        Button(action: { msalManager.signOut() }) {
                            Text("Sign Out")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                
                // Keychain reset button for development
                Button(action: { msalManager.resetKeychainForDevelopment() }) {
                    Text("🔧 Reset Keychain")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // Logging text area
            ScrollView {
                Text(msalManager.loggingText)
                                            .font(.system(size: 10, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 120)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Action Methods
    private func callGraphAPI() {
        // This will call Microsoft Graph API using the access token
        if msalManager.isSignedIn {
            msalManager.updateLogging(text: "Calling Microsoft Graph API with token...")
            // Here you would make your actual API call
            // For now, we'll just simulate it
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                msalManager.updateLogging(text: "Graph API call completed successfully")
            }
        } else {
            msalManager.updateLogging(text: "Please sign in first before calling Graph API")
        }
    }
    
    private func getDeviceMode() {
        // Your device info logic here
        msalManager.updateLogging(text: "Getting device information...")
        #if DEBUG
        msalManager.updateLogging(text: "DEBUG: Running in debug mode")
        #else
        msalManager.updateLogging(text: "RELEASE: Running in release mode")
        #endif
    }
    
    private func login() {
        // This redirects to Microsoft sign-in
        msalManager.signInInteractively()
    }
}

#Preview {
    ContentView()
}
