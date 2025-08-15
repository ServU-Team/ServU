//
//  BusinessType.swift
//  ServU
//
//  Created by Amber Still on 8/9/25.
//


//
//  BusinessType.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  CONSOLIDATED - Single source of truth for business types and categories
//

import SwiftUI
import Foundation

// MARK: - Business Type
enum BusinessType: String, CaseIterable, Identifiable, Codable {
    case services = "Services"
    case products = "Products"
    case both = "Services & Products"
    
    var id: String { rawValue }
    
    var displayName: String {
        return self.rawValue
    }
    
    var systemIcon: String {
        switch self {
        case .services: return "wrench.and.screwdriver"
        case .products: return "bag"
        case .both: return "star.circle"
        }
    }
    
    var description: String {
        switch self {
        case .services:
            return "Offer services like tutoring, hair styling, photography, or cleaning"
        case .products:
            return "Sell products like clothing, electronics, textbooks, or food items"
        case .both:
            return "Combine both services and products in your business"
        }
    }
}

// MARK: - Service Category
enum ServiceCategory: String, CaseIterable, Identifiable, Codable {
    case photoVideo = "Photo/Video"
    case hairStylist = "Hair Stylist"
    case barber = "Barber"
    case lashTech = "Lash Tech"
    case nailTech = "Nail Tech"
    case tutor = "Tutor"
    case foodDelivery = "Food Delivery"
    case cleaning = "Cleaning"
    case eventPlanning = "Event Planning"
    case other = "Other Services"
    
    var id: String { rawValue }
    
    var systemIcon: String {
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
        return self.rawValue
    }
    
    var color: Color {
        switch self {
        case .photoVideo: return .purple
        case .hairStylist: return .pink
        case .barber: return .blue
        case .lashTech: return .orange
        case .nailTech: return .red
        case .tutor: return .green
        case .foodDelivery: return .yellow
        case .cleaning: return .cyan
        case .eventPlanning: return .indigo
        case .other: return .gray
        }
    }
}

// MARK: - Product Category
enum ProductCategory: String, CaseIterable, Identifiable, Codable {
    case clothing = "Clothing"
    case electronics = "Electronics"
    case books = "Books & Study Materials"
    case food = "Food & Beverages"
    case health = "Health & Beauty"
    case home = "Home & Living"
    case sports = "Sports & Recreation"
    case art = "Art & Crafts"
    case other = "Other Products"
    
    var id: String { rawValue }
    
    var systemIcon: String {
        switch self {
        case .clothing: return "tshirt"
        case .electronics: return "laptopcomputer"
        case .books: return "book.fill"
        case .food: return "fork.knife"
        case .health: return "heart.fill"
        case .home: return "house.fill"
        case .sports: return "sportscourt"
        case .art: return "paintbrush.pointed.fill"
        case .other: return "shippingbox"
        }
    }
    
    var displayName: String {
        return self.rawValue
    }
    
    var color: Color {
        switch self {
        case .clothing: return .purple
        case .electronics: return .blue
        case .books: return .green
        case .food: return .orange
        case .health: return .pink
        case .home: return .brown
        case .sports: return .red
        case .art: return .indigo
        case .other: return .gray
        }
    }
}

// MARK: - Price Range
enum PriceRange: String, CaseIterable, Identifiable, Codable {
    case budget = "$"
    case moderate = "$$"
    case premium = "$$$"
    case luxury = "$$$$"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .budget: return "Budget-Friendly ($)"
        case .moderate: return "Moderate ($$)"
        case .premium: return "Premium ($$$)"
        case .luxury: return "Luxury ($$$$)"
        }
    }
    
    var description: String {
        switch self {
        case .budget: return "$1 - $25"
        case .moderate: return "$26 - $75"
        case .premium: return "$76 - $200"
        case .luxury: return "$200+"
        }
    }
    
    var color: Color {
        switch self {
        case .budget: return .green
        case .moderate: return .blue
        case .premium: return .orange
        case .luxury: return .purple
        }
    }
}

// MARK: - Classification Level
enum ClassificationLevel: String, CaseIterable, Identifiable, Codable {
    case freshman = "Freshman"
    case sophomore = "Sophomore"
    case junior = "Junior"
    case senior = "Senior"
    case graduate = "Graduate Student"
    case faculty = "Faculty"
    case staff = "Staff"
    
    var id: String { rawValue }
    
    var displayName: String {
        return self.rawValue
    }
    
    var systemIcon: String {
        switch self {
        case .freshman: return "1.circle"
        case .sophomore: return "2.circle"
        case .junior: return "3.circle"
        case .senior: return "4.circle"
        case .graduate: return "graduationcap"
        case .faculty: return "person.badge.plus"
        case .staff: return "person.2"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .freshman: return 1
        case .sophomore: return 2
        case .junior: return 3
        case .senior: return 4
        case .graduate: return 5
        case .faculty: return 6
        case .staff: return 7
        }
    }
}

// MARK: - Deposit Type
enum DepositType: String, CaseIterable, Identifiable, Codable {
    case percentage = "Percentage"
    case fixedAmount = "Fixed Amount"
    
    var id: String { rawValue }
    
    var displayName: String {
        return self.rawValue
    }
    
    var systemIcon: String {
        switch self {
        case .percentage: return "percent"
        case .fixedAmount: return "dollarsign.circle"
        }
    }
}

// MARK: - Business Status
enum BusinessStatus: String, CaseIterable, Identifiable, Codable {
    case active = "Active"
    case inactive = "Inactive"
    case pending = "Pending Approval"
    case suspended = "Suspended"
    
    var id: String { rawValue }
    
    var displayName: String {
        return self.rawValue
    }
    
    var color: Color {
        switch self {
        case .active: return .green
        case .inactive: return .gray
        case .pending: return .orange
        case .suspended: return .red
        }
    }
    
    var systemIcon: String {
        switch self {
        case .active: return "checkmark.circle.fill"
        case .inactive: return "pause.circle"
        case .pending: return "clock.badge.questionmark"
        case .suspended: return "xmark.octagon"
        }
    }
}
