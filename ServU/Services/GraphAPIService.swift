//
//  GraphAPIService.swift
//  ServU
//
//  Created by Amber Still on 8/9/25.
//


//
//  GraphAPIService.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  Microsoft Graph integration for user data and profile information
//

import Foundation
import MSAL

class GraphAPIService: ObservableObject {
    @Published var userInfo: GraphUser?
    @Published var profilePhoto: Data?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let graphEndpoint = "https://graph.microsoft.com/v1.0"
    
    // MARK: - User Profile Methods
    
    /// Fetch user profile information from Microsoft Graph
    func fetchUserProfile(accessToken: String) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(graphEndpoint)/me") else {
            handleError("Invalid URL for user profile")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.handleError("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.handleError("Invalid response")
                    return
                }
                
                guard httpResponse.statusCode == 200 else {
                    self?.handleError("Server error: \(httpResponse.statusCode)")
                    return
                }
                
                guard let data = data else {
                    self?.handleError("No data received")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let userInfo = try decoder.decode(GraphUser.self, from: data)
                    self?.userInfo = userInfo
                    print("✅ Successfully fetched user profile: \(userInfo.displayName ?? "Unknown")")
                } catch {
                    self?.handleError("Failed to decode user data: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    /// Fetch user's profile photo from Microsoft Graph
    func fetchUserPhoto(accessToken: String) {
        guard let url = URL(string: "\(graphEndpoint)/me/photo/$value") else {
            print("⚠️ Invalid URL for user photo")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("⚠️ Error fetching photo: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("⚠️ Invalid photo response")
                    return
                }
                
                if httpResponse.statusCode == 200, let data = data {
                    self?.profilePhoto = data
                    print("✅ Successfully fetched user photo")
                } else {
                    print("⚠️ No photo available or error: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    // MARK: - Email Methods
    
    /// Fetch user's recent emails (for integration features)
    func fetchRecentEmails(accessToken: String, limit: Int = 10) {
        guard let url = URL(string: "\(graphEndpoint)/me/messages?$top=\(limit)&$select=subject,from,receivedDateTime,isRead") else {
            handleError("Invalid URL for emails")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.handleError("Email fetch error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let data = data else {
                    self?.handleError("Failed to fetch emails")
                    return
                }
                
                // Process email data if needed
                print("✅ Successfully fetched recent emails")
            }
        }.resume()
    }
    
    // MARK: - Calendar Methods
    
    /// Fetch user's calendar events (for scheduling integration)
    func fetchCalendarEvents(accessToken: String, limit: Int = 20) {
        let startDate = ISO8601DateFormatter().string(from: Date())
        let endDate = ISO8601DateFormatter().string(from: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date())
        
        guard let url = URL(string: "\(graphEndpoint)/me/events?$top=\(limit)&$filter=start/dateTime ge '\(startDate)' and start/dateTime le '\(endDate)'&$select=subject,start,end,location") else {
            handleError("Invalid URL for calendar")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.handleError("Calendar fetch error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let data = data else {
                    self?.handleError("Failed to fetch calendar")
                    return
                }
                
                // Process calendar data if needed
                print("✅ Successfully fetched calendar events")
            }
        }.resume()
    }
    
    // MARK: - Helper Methods
    
    private func handleError(_ message: String) {
        errorMessage = message
        print("❌ GraphAPI Error: \(message)")
    }
    
    /// Update user profile with Graph data
    func updateUserProfile(_ userProfile: UserProfile) {
        guard let graphUser = userInfo else { return }
        
        userProfile.email = graphUser.userPrincipalName ?? graphUser.mail ?? ""
        userProfile.displayName = graphUser.displayName ?? ""
        
        // Parse first and last name if available
        if let givenName = graphUser.givenName {
            userProfile.firstName = givenName
        }
        if let surname = graphUser.surname {
            userProfile.lastName = surname
        }
        
        // Update phone if available
        if let mobilePhone = graphUser.mobilePhone {
            userProfile.phoneNumber = mobilePhone
        }
        
        print("✅ Updated user profile with Graph data")
    }
    
    /// Clear cached data
    func clearCache() {
        userInfo = nil
        profilePhoto = nil
        errorMessage = nil
    }
}

// MARK: - Graph User Model
struct GraphUser: Codable {
    let id: String?
    let displayName: String?
    let givenName: String?
    let surname: String?
    let userPrincipalName: String?
    let mail: String?
    let mobilePhone: String?
    let officeLocation: String?
    let preferredLanguage: String?
    let jobTitle: String?
    let department: String?
    
    // Computed properties
    var fullName: String {
        let first = givenName ?? ""
        let last = surname ?? ""
        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }
    
    var primaryEmail: String {
        return mail ?? userPrincipalName ?? ""
    }
}

// MARK: - Graph Email Model (for future use)
struct GraphEmail: Codable {
    let id: String
    let subject: String?
    let from: EmailAddress?
    let receivedDateTime: String?
    let isRead: Bool?
    
    struct EmailAddress: Codable {
        let name: String?
        let address: String?
    }
}

// MARK: - Graph Calendar Event Model (for future use)
struct GraphCalendarEvent: Codable {
    let id: String
    let subject: String?
    let start: DateTimeTimeZone?
    let end: DateTimeTimeZone?
    let location: Location?
    
    struct DateTimeTimeZone: Codable {
        let dateTime: String
        let timeZone: String
    }
    
    struct Location: Codable {
        let displayName: String?
        let address: Address?
        
        struct Address: Codable {
            let street: String?
            let city: String?
            let state: String?
            let countryOrRegion: String?
            let postalCode: String?
        }
    }
}