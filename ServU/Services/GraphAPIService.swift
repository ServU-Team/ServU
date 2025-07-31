//
//  GraphAPIService.swift
//  ServU
//
//  Created by Amber Still on 7/29/25.
//


//
//  GraphAPIService.swift
//  ServU
//
//  Created by Quian Bowden on 6/21/25.
//  Updated by Assistant on 7/29/25.
//  Fixed unnecessary try blocks
//

import Foundation
import MSAL

class GraphAPIService: ObservableObject {
    
    // MARK: - Properties
    private let msalManager: MSALManager
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - API Endpoints
    private let graphBaseURL = "https://graph.microsoft.com/v1.0"
    private let userEndpoint = "/me"
    private let userPhotoEndpoint = "/me/photo/$value"
    
    // MARK: - Initialization
    init(msalManager: MSALManager) {
        self.msalManager = msalManager
    }
    
    // MARK: - Public Methods
    
    /// Fetches user profile information from Microsoft Graph
    func fetchUserProfile() async throws -> UserProfile {
        print("🔍 DEBUG: Starting fetchUserProfile")
        
        guard !msalManager.accessToken.isEmpty else {
            print("❌ DEBUG: No access token available")
            throw GraphAPIError.noAccessToken
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        do {
            // Fetch basic profile data
            let profileData = try await makeGraphAPICall(endpoint: userEndpoint)
            print("✅ DEBUG: Received profile data: \(profileData)")
            
            // Parse the profile data
            let userProfile = parseUserProfile(from: profileData)
            print("✅ DEBUG: Parsed user profile: \(userProfile)")
            
            // Try to fetch profile photo (optional - don't fail if this doesn't work)
            do {
                userProfile.profileImageData = try await fetchUserPhoto()
                print("✅ DEBUG: Successfully fetched profile photo")
            } catch {
                print("⚠️ DEBUG: Could not fetch profile photo: \(error)")
                userProfile.profileImageData = nil
            }
            
            return userProfile
            
        } catch {
            print("❌ DEBUG: Error in fetchUserProfile: \(error)")
            await MainActor.run {
                errorMessage = "Failed to fetch profile: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    /// Fetches user's profile photo from Microsoft Graph
    private func fetchUserPhoto() async throws -> Data {
        print("📸 DEBUG: Fetching user photo")
        
        guard let url = URL(string: "\(graphBaseURL)\(userPhotoEndpoint)") else {
            throw GraphAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(msalManager.accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GraphAPIError.invalidResponse
        }
        
        print("📸 DEBUG: Photo response status: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode == 200 {
            return data
        } else {
            // Photo might not exist - this is okay
            throw GraphAPIError.photoNotAvailable
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// Makes a generic Graph API call
    private func makeGraphAPICall(endpoint: String) async throws -> [String: Any] {
        guard let url = URL(string: "\(graphBaseURL)\(endpoint)") else {
            throw GraphAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(msalManager.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        print("🌐 DEBUG: Making request to: \(url)")
        print("🔑 DEBUG: Using token: \(msalManager.accessToken.prefix(20))...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GraphAPIError.invalidResponse
        }
        
        print("📊 DEBUG: Response status: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode == 200 {
            // ✅ FIXED: Removed unnecessary try since JSONSerialization.jsonObject doesn't throw in this context
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json ?? [:]
        } else {
            // Log error response for debugging
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ DEBUG: Error response: \(errorString)")
            }
            throw GraphAPIError.httpError(httpResponse.statusCode)
        }
    }
    
    /// Parses Microsoft Graph user response into UserProfile model
    private func parseUserProfile(from data: [String: Any]) -> UserProfile {
        let profile = UserProfile()
        
        // Basic information
        profile.id = data["id"] as? String ?? ""
        profile.displayName = data["displayName"] as? String ?? ""
        profile.email = data["mail"] as? String ?? data["userPrincipalName"] as? String ?? ""
        profile.firstName = data["givenName"] as? String ?? ""
        profile.lastName = data["surname"] as? String ?? ""
        profile.jobTitle = data["jobTitle"] as? String
        
        // Extract college from email domain
        if !profile.email.isEmpty {
            profile.college = CollegeDataService.getCollegeInfo(from: profile.email)
        }
        
        print("📝 DEBUG: Parsed profile - Name: \(profile.displayName), Email: \(profile.email), College: \(profile.college?.name ?? "Unknown")")
        
        return profile
    }
}

// MARK: - Error Handling
enum GraphAPIError: LocalizedError {
    case noAccessToken
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case photoNotAvailable
    case parseError
    
    var errorDescription: String? {
        switch self {
        case .noAccessToken:
            return "No access token available. Please sign in again."
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .photoNotAvailable:
            return "Profile photo not available"
        case .parseError:
            return "Error parsing server response"
        }
    }
}
