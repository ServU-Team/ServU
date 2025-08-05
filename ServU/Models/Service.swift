//
//  Service.swift
//  ServU
//
//  Created by Amber Still on 8/4/25.
//


//
//  ServUService.swift
//  ServU
//
//  Created by Quian Bowden on 8/4/25.
//  Fixed Service model compatibility with deposit features
//

import Foundation
import SwiftUI

// MARK: - Service Model (Updated for compatibility)
struct Service: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var price: Double
    var duration: String
    var isAvailable: Bool = true
    
    // Deposit Properties
    var requiresDeposit: Bool = false
    var depositAmount: Double = 0.0
    var depositType: DepositType = .fixed
    var depositPolicy: String = ""
    
    // MARK: - Computed Properties
    var displayDepositAmount: String {
        switch depositType {
        case .fixed:
            return String(format: "$%.2f", depositAmount)
        case .percentage:
            let amount = price * (depositAmount / 100.0)
            return String(format: "$%.2f (%.0f%%)", amount, depositAmount)
        }
    }
    
    var calculatedDepositAmount: Double {
        switch depositType {
        case .fixed:
            return depositAmount
        case .percentage:
            return price * (depositAmount / 100.0)
        }
    }
    
    var remainingBalance: Double {
        return price - calculatedDepositAmount
    }
    
    // MARK: - Initializer
    init(name: String, description: String, price: Double, duration: String, isAvailable: Bool = true, requiresDeposit: Bool = false, depositAmount: Double = 0.0, depositType: DepositType = .fixed, depositPolicy: String = "") {
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

// MARK: - Business Model
struct Business: Identifiable {
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
}

// MARK: - Service Category
enum ServiceCategory: String, CaseIterable {
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
}

// MARK: - Supporting Models
enum PriceRange: String, CaseIterable {
    case budget = "$"
    case moderate = "$$"
    case premium = "$$$"
    case luxury = "$$$$"
}

struct ContactInfo {
    var email: String
    var phone: String
    var instagram: String?
    var website: String?
}

struct BusinessHours {
    var monday: DayHours?
    var tuesday: DayHours?
    var wednesday: DayHours?
    var thursday: DayHours?
    var friday: DayHours?
    var saturday: DayHours?
    var sunday: DayHours?
}

struct DayHours {
    var openTime: Date
    var closeTime: Date
    var isOpen: Bool = true
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
    @Published var walletBalance: Double = 0.0
    @Published var phoneNumber: String = ""
    @Published var isBusinessOwner: Bool = false
    @Published var businesses: [Business] = []
    
    // Computed properties
    var profileImage: UIImage? {
        guard let data = profileImageData else { return nil }
        return UIImage(data: data)
    }
    
    var fullName: String {
        if !firstName.isEmpty && !lastName.isEmpty {
            return "\(firstName) \(lastName)"
        }
        return displayName
    }
    
    var collegeDomain: String {
        let components = email.components(separatedBy: "@")
        return components.count > 1 ? components[1] : ""
    }
}

// MARK: - College Classification
enum ClassificationLevel: String, CaseIterable {
    case freshman = "Freshman"
    case sophomore = "Sophomore"
    case junior = "Junior"
    case senior = "Senior"
    case graduate = "Graduate Student"
    case faculty = "Faculty"
    case staff = "Staff"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - College Model
struct College {
    let id: String
    let name: String
    let domain: String
    let primaryColor: Color
    let secondaryColor: Color
    let logoURL: String?
    let state: String
    let city: String
    let isHBCU: Bool
    
    var colorScheme: CollegeColorScheme {
        CollegeColorScheme(
            primary: primaryColor,
            secondary: secondaryColor,
            background: primaryColor.opacity(0.1),
            accent: secondaryColor
        )
    }
}

// MARK: - College Color Scheme
struct CollegeColorScheme {
    let primary: Color
    let secondary: Color
    let background: Color
    let accent: Color
}