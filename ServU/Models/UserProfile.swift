//
//  UserProfile.swift
//  ServU
//
//  Created by Amber Still on 8/9/25.
//


//
//  UserProfile.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  User profile and preferences management
//

import SwiftUI
import Foundation

class UserProfile: ObservableObject {
    // MARK: - User Information
    @Published var userId: UUID = UUID()
    @Published var email: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var displayName: String = ""
    @Published var profileImageURL: String?
    
    // MARK: - Academic Information
    @Published var college: College?
    @Published var classificationLevel: ClassificationLevel = .freshman
    @Published var major: String = ""
    @Published var graduationYear: Int?
    
    // MARK: - Contact Information
    @Published var phoneNumber: String = ""
    @Published var instagramHandle: String = ""
    @Published var preferredContactMethod: ContactMethod = .email
    
    // MARK: - Business Information
    @Published var hasBusinessProfile: Bool = false
    @Published var businesses: [Business] = []
    @Published var primaryBusinessId: UUID?
    
    // MARK: - Preferences
    @Published var preferences = UserPreferences()
    @Published var favoriteBusinesses: Set<UUID> = []
    @Published var recentlyViewedBusinesses: [UUID] = []
    
    // MARK: - App State
    @Published var hasCompletedOnboarding: Bool = false
    @Published var lastLoginDate: Date?
    @Published var isProfileComplete: Bool = false
    
    // MARK: - Computed Properties
    var fullName: String {
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
    
    var initials: String {
        let firstInitial = firstName.prefix(1).uppercased()
        let lastInitial = lastName.prefix(1).uppercased()
        return "\(firstInitial)\(lastInitial)"
    }
    
    var primaryBusiness: Business? {
        guard let primaryId = primaryBusinessId else { return nil }
        return businesses.first { $0.id == primaryId }
    }
    
    // MARK: - Profile Completion
    func updateProfileCompletion() {
        isProfileComplete = !firstName.isEmpty &&
                           !lastName.isEmpty &&
                           !email.isEmpty &&
                           college != nil &&
                           !major.isEmpty &&
                           graduationYear != nil
    }
    
    // MARK: - Business Management
    func addBusiness(_ business: Business) {
        businesses.append(business)
        hasBusinessProfile = true
        
        // Set as primary if first business
        if primaryBusinessId == nil {
            primaryBusinessId = business.id
        }
    }
    
    func removeBusiness(_ businessId: UUID) {
        businesses.removeAll { $0.id == businessId }
        
        // Update primary business if removed
        if primaryBusinessId == businessId {
            primaryBusinessId = businesses.first?.id
        }
        
        // Update business profile status
        hasBusinessProfile = !businesses.isEmpty
    }
    
    func setPrimaryBusiness(_ businessId: UUID) {
        if businesses.contains(where: { $0.id == businessId }) {
            primaryBusinessId = businessId
        }
    }
    
    // MARK: - Favorites Management
    func toggleFavorite(_ businessId: UUID) {
        if favoriteBusinesses.contains(businessId) {
            favoriteBusinesses.remove(businessId)
        } else {
            favoriteBusinesses.insert(businessId)
        }
    }
    
    func isFavorite(_ businessId: UUID) -> Bool {
        return favoriteBusinesses.contains(businessId)
    }
    
    // MARK: - Recently Viewed Management
    func addToRecentlyViewed(_ businessId: UUID) {
        // Remove if already exists
        recentlyViewedBusinesses.removeAll { $0 == businessId }
        
        // Add to front
        recentlyViewedBusinesses.insert(businessId, at: 0)
        
        // Keep only last 10
        if recentlyViewedBusinesses.count > 10 {
            recentlyViewedBusinesses = Array(recentlyViewedBusinesses.prefix(10))
        }
    }
    
    // MARK: - Profile Updates
    func updateFromMSAL(email: String, displayName: String) {
        self.email = email
        self.displayName = displayName
        
        // Parse first/last name from display name if not set
        if firstName.isEmpty || lastName.isEmpty {
            let components = displayName.split(separator: " ")
            if components.count >= 2 {
                firstName = String(components.first ?? "")
                lastName = String(components.last ?? "")
            }
        }
        
        lastLoginDate = Date()
        updateProfileCompletion()
    }
    
    // MARK: - Reset Profile
    func resetProfile() {
        userId = UUID()
        email = ""
        firstName = ""
        lastName = ""
        displayName = ""
        profileImageURL = nil
        
        college = nil
        classificationLevel = .freshman
        major = ""
        graduationYear = nil
        
        phoneNumber = ""
        instagramHandle = ""
        preferredContactMethod = .email
        
        hasBusinessProfile = false
        businesses.removeAll()
        primaryBusinessId = nil
        
        preferences = UserPreferences()
        favoriteBusinesses.removeAll()
        recentlyViewedBusinesses.removeAll()
        
        hasCompletedOnboarding = false
        lastLoginDate = nil
        isProfileComplete = false
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable {
    // Notification Settings
    var enablePushNotifications: Bool = true
    var enableBookingReminders: Bool = true
    var enablePromotionalNotifications: Bool = false
    var reminderTimeBeforeBooking: Int = 30 // minutes
    
    // Privacy Settings
    var showEmailToBusinesses: Bool = true
    var showPhoneToBusinesses: Bool = false
    var allowBusinessesToContactMe: Bool = true
    
    // App Settings
    var preferredMapType: MapType = .standard
    var autoLocationEnabled: Bool = true
    var showOnlineBusinessesFirst: Bool = false
    var preferredLanguage: String = "en"
    
    // Theme Settings
    var useCollegeColors: Bool = true
    var darkModeEnabled: Bool = false
    var reducedMotionEnabled: Bool = false
}

// MARK: - Contact Method
enum ContactMethod: String, CaseIterable, Identifiable, Codable {
    case email = "Email"
    case phone = "Phone"
    case instagram = "Instagram"
    case inApp = "In-App Messaging"
    
    var id: String { rawValue }
    
    var displayName: String {
        return self.rawValue
    }
    
    var systemIcon: String {
        switch self {
        case .email: return "envelope"
        case .phone: return "phone"
        case .instagram: return "camera"
        case .inApp: return "message"
        }
    }
}

// MARK: - Map Type
enum MapType: String, CaseIterable, Identifiable, Codable {
    case standard = "Standard"
    case satellite = "Satellite"
    case hybrid = "Hybrid"
    
    var id: String { rawValue }
    
    var displayName: String {
        return self.rawValue
    }
}