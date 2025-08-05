//
//  Service.swift
//  ServU
//
//  Created by Amber Still on 8/4/25.
//


//
//  Service.swift
//  ServU
//
//  Created by Quian Bowden on 6/27/25.
//  Updated by Quian Bowden on 8/4/25.
//

import Foundation
import SwiftUI

// MARK: - Legacy Service Model (for backward compatibility)
struct Service: Codable, Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var price: Double
    var duration: String
    var isAvailable: Bool
    var requiresDeposit: Bool
    var depositAmount: Double?
    var depositType: DepositType?
    var depositPolicy: String?
    
    init(name: String, description: String, price: Double, duration: String, isAvailable: Bool = true, requiresDeposit: Bool = false, depositAmount: Double? = nil, depositType: DepositType? = nil, depositPolicy: String? = nil) {
        self.name = name
        self.description = description
        self.price = price
        self.duration = duration
        self.isAvailable = isAvailable
        self.requiresDeposit = requiresDeposit
        self.depositAmount = depositAmount
        self.depositType = depositType
        self.depositPolicy = depositPolicy
    }
}

// MARK: - Legacy Business Model (for backward compatibility)
struct Business: Codable, Identifiable {
    let id = UUID()
    var name: String
    var category: ServiceCategory
    var description: String
    var rating: Double
    var priceRange: PriceRange
    var imageURL: String?
    var isActive: Bool = true
    var location: String
    var contactInfo: ContactInfo
    var services: [Service] = []
    var availability: BusinessHours
    
    init(name: String, category: ServiceCategory, description: String, rating: Double, priceRange: PriceRange, imageURL: String? = nil, isActive: Bool = true, location: String, contactInfo: ContactInfo, services: [Service] = [], availability: BusinessHours) {
        self.name = name
        self.category = category
        self.description = description
        self.rating = rating
        self.priceRange = priceRange
        self.imageURL = imageURL
        self.isActive = isActive
        self.location = location
        self.contactInfo = contactInfo
        self.services = services
        self.availability = availability
    }
}

// MARK: - Service Category
enum ServiceCategory: String, CaseIterable, Identifiable {
    case photoVideo = "PHOTO/VIDEO"
    case hairStylist = "HAIR STYLIST"
    case barber = "BARBER"
    case lashTech = "LASH TECH"
    case nailTech = "NAIL TECH"
    case tutor = "TUTOR"
    case foodDelivery = "FOOD"
    case cleaning = "CLEANING"
    case eventPlanning = "EVENT PLANNING"
    case other = "OTHER"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .photoVideo: return "camera.fill"
        case .hairStylist: return "scissors"
        case .barber: return "mustache.fill"
        case .lashTech: return "eye.fill"
        case .nailTech: return "hand.raised.fill"
        case .tutor: return "book.fill"
        case .foodDelivery: return "takeoutbag.and.cup.and.straw.fill"
        case .cleaning: return "sparkles"
        case .eventPlanning: return "party.popper.fill"
        case .other: return "star.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .photoVideo: return "Photo/Video"
        case .hairStylist: return "Hair Stylist"
        case .barber: return "Barber"
        case .lashTech: return "Lash Tech"
        case .nailTech: return "Nail Tech"
        case .tutor: return "Tutor"
        case .foodDelivery: return "Food"
        case .cleaning: return "Cleaning"
        case .eventPlanning: return "Event Planning"
        case .other: return "Other Services"
        }
    }
    
    var color: Color {
        switch self {
        case .photoVideo: return .purple
        case .hairStylist: return .pink
        case .barber: return .blue
        case .lashTech: return .cyan
        case .nailTech: return .orange
        case .tutor: return .green
        case .foodDelivery: return .red
        case .cleaning: return .teal
        case .eventPlanning: return .indigo
        case .other: return .gray
        }
    }
}

// MARK: - Supporting Models
enum PriceRange: String, CaseIterable, Identifiable {
    case budget = "$"
    case moderate = "$$"
    case premium = "$$$"
    case luxury = "$$$$"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .budget: return "Budget ($)"
        case .moderate: return "Moderate ($$)"
        case .premium: return "Premium ($$$)"
        case .luxury: return "Luxury ($$$$)"
        }
    }
}

struct ContactInfo: Codable {
    var email: String
    var phone: String
    var instagram: String?
    var website: String?
    
    init(email: String, phone: String, instagram: String? = nil, website: String? = nil) {
        self.email = email
        self.phone = phone
        self.instagram = instagram
        self.website = website
    }
}

struct BusinessHours: Codable {
    var monday: DayHours?
    var tuesday: DayHours?
    var wednesday: DayHours?
    var thursday: DayHours?
    var friday: DayHours?
    var saturday: DayHours?
    var sunday: DayHours?
    
    init(monday: DayHours? = nil, tuesday: DayHours? = nil, wednesday: DayHours? = nil, thursday: DayHours? = nil, friday: DayHours? = nil, saturday: DayHours? = nil, sunday: DayHours? = nil) {
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
    }
}

struct DayHours: Codable {
    var openTime: Date
    var closeTime: Date
    var isOpen: Bool = true
    
    init(openTime: Date, closeTime: Date, isOpen: Bool = true) {
        self.openTime = openTime
        self.closeTime = closeTime
        self.isOpen = isOpen
    }
}

// MARK: - User Profile Model
class UserProfile: ObservableObject {
    // Microsoft Graph data
    @Published var id: String = ""
    @Published var displayName: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var jobTitle: String?
    @Published var profileImageData: Data?
    
    // ServU-specific data
    @Published var bio: String = ""
    @Published var major: String = ""
    @Published var classificationLevel: ClassificationLevel = .freshman
    @Published var college: College?
    @Published var preferences: UserPreferences = UserPreferences()
    @Published var savedBusinesses: [String] = []
    @Published var recentSearches: [String] = []
    
    init() {}
}

// MARK: - User Supporting Models
enum ClassificationLevel: String, CaseIterable, Identifiable {
    case freshman = "FRESHMAN"
    case sophomore = "SOPHOMORE"
    case junior = "JUNIOR"
    case senior = "SENIOR"
    case graduate = "GRADUATE"
    case faculty = "FACULTY"
    case staff = "STAFF"
    case alumni = "ALUMNI"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .freshman: return "Freshman"
        case .sophomore: return "Sophomore"
        case .junior: return "Junior"
        case .senior: return "Senior"
        case .graduate: return "Graduate Student"
        case .faculty: return "Faculty"
        case .staff: return "Staff"
        case .alumni: return "Alumni"
        }
    }
}

struct College: Codable, Identifiable {
    let id = UUID()
    var name: String
    var abbreviation: String
    var primaryColor: Color
    var secondaryColor: Color
    var logoURL: String?
    
    init(name: String, abbreviation: String, primaryColor: Color, secondaryColor: Color, logoURL: String? = nil) {
        self.name = name
        self.abbreviation = abbreviation
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.logoURL = logoURL
    }
}

struct UserPreferences: Codable {
    var notificationsEnabled: Bool = true
    var emailUpdates: Bool = true
    var preferredPaymentMethod: String?
    var defaultShippingOption: ShippingOption = .campusPickup
    var theme: AppTheme = .system
    var language: String = "en"
    
    init() {}
}

enum AppTheme: String, CaseIterable, Identifiable {
    case light = "LIGHT"
    case dark = "DARK"
    case system = "SYSTEM"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
}