//
//  BusinessType.swift
//  ServU
//
//  Created by Amber Still on 8/6/25.
//


//
//  SupportingTypes.swift
//  ServU
//
//  Created by Quian Bowden on 8/5/25.
//  Supporting types and enums for ServU app
//

import Foundation
import SwiftUI

// MARK: - Business Type
enum BusinessType: String, CaseIterable, Identifiable, Codable {
    case services = "SERVICES"
    case products = "PRODUCTS"
    case both = "BOTH"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .services: return "Services"
        case .products: return "Products"
        case .both: return "Services & Products"
        }
    }
    
    var description: String {
        switch self {
        case .services: return "Offer services to students"
        case .products: return "Sell products to students"
        case .both: return "Offer both services and products"
        }
    }
    
    var icon: String {
        switch self {
        case .services: return "hands.sparkles.fill"
        case .products: return "bag.fill"
        case .both: return "square.grid.2x2.fill"
        }
    }
}

// MARK: - Service Category
enum ServiceCategory: String, CaseIterable, Identifiable, Codable {
    case photoVideo = "PHOTO_VIDEO"
    case hairStylist = "HAIR_STYLIST"
    case barber = "BARBER"
    case lashTech = "LASH_TECH"
    case nailTech = "NAIL_TECH"
    case tutor = "TUTOR"
    case foodDelivery = "FOOD_DELIVERY"
    case cleaning = "CLEANING"
    case eventPlanning = "EVENT_PLANNING"
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
}

// MARK: - Product Category
enum ProductCategory: String, CaseIterable, Identifiable, Codable {
    case clothing = "CLOTHING"
    case electronics = "ELECTRONICS"
    case books = "BOOKS"
    case food = "FOOD"
    case health = "HEALTH"
    case art = "ART"
    case sports = "SPORTS"
    case beauty = "BEAUTY"
    case home = "HOME"
    case other = "OTHER"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .clothing: return "Clothing"
        case .electronics: return "Electronics"
        case .books: return "Books"
        case .food: return "Food & Beverages"
        case .health: return "Health & Wellness"
        case .art: return "Art & Crafts"
        case .sports: return "Sports & Recreation"
        case .beauty: return "Beauty"
        case .home: return "Home & Garden"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .clothing: return "tshirt.fill"
        case .electronics: return "laptopcomputer"
        case .books: return "book.fill"
        case .food: return "fork.knife"
        case .health: return "heart.fill"
        case .art: return "paintbrush.fill"
        case .sports: return "figure.run"
        case .beauty: return "sparkles"
        case .home: return "house.fill"
        case .other: return "bag.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .clothing: return .purple
        case .electronics: return .blue
        case .books: return .brown
        case .food: return .orange
        case .health: return .green
        case .art: return .pink
        case .sports: return .red
        case .beauty: return .cyan
        case .home: return .indigo
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
        case .budget: return "Budget ($)"
        case .moderate: return "Moderate ($$)"
        case .premium: return "Premium ($$$)"
        case .luxury: return "Luxury ($$$$)"
        }
    }
}

// MARK: - Shipping Option
enum ShippingOption: String, CaseIterable, Identifiable, Codable {
    case campusPickup = "CAMPUS_PICKUP"
    case dormDelivery = "DORM_DELIVERY"
    case localDelivery = "LOCAL_DELIVERY"
    case standardShipping = "STANDARD_SHIPPING"
    case expressShipping = "EXPRESS_SHIPPING"
    case freeShipping = "FREE_SHIPPING"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .campusPickup: return "Campus Pickup"
        case .dormDelivery: return "Dorm Delivery"
        case .localDelivery: return "Local Delivery"
        case .standardShipping: return "Standard Shipping"
        case .expressShipping: return "Express Shipping"
        case .freeShipping: return "Free Shipping"
        }
    }
    
    var description: String {
        switch self {
        case .campusPickup: return "Pick up on campus"
        case .dormDelivery: return "Delivery to your dorm"
        case .localDelivery: return "Local area delivery"
        case .standardShipping: return "Standard shipping"
        case .expressShipping: return "Express shipping"
        case .freeShipping: return "Free shipping"
        }
    }
    
    var price: Double {
        switch self {
        case .campusPickup: return 0.0
        case .dormDelivery: return 3.0
        case .localDelivery: return 5.0
        case .standardShipping: return 7.99
        case .expressShipping: return 12.99
        case .freeShipping: return 0.0
        }
    }
    
    var estimatedDays: String {
        switch self {
        case .campusPickup: return "Same day"
        case .dormDelivery: return "Same day"
        case .localDelivery: return "1-2 days"
        case .standardShipping: return "3-5 days"
        case .expressShipping: return "1-2 days"
        case .freeShipping: return "5-7 days"
        }
    }
    
    var icon: String {
        switch self {
        case .campusPickup: return "location.fill"
        case .dormDelivery: return "building.2.fill"
        case .localDelivery: return "car.fill"
        case .standardShipping: return "shippingbox.fill"
        case .expressShipping: return "airplane"
        case .freeShipping: return "gift.fill"
        }
    }
}

// MARK: - Stock Status
enum StockStatus: String, CaseIterable {
    case inStock = "In Stock"
    case lowStock = "Low Stock"
    case outOfStock = "Out of Stock"
    case preOrder = "Pre-Order"
    case discontinued = "Discontinued"
    
    var icon: String {
        switch self {
        case .inStock: return "checkmark.circle.fill"
        case .lowStock: return "exclamationmark.triangle.fill"
        case .outOfStock: return "xmark.circle.fill"
        case .preOrder: return "clock.fill"
        case .discontinued: return "minus.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .inStock: return .green
        case .lowStock: return .orange
        case .outOfStock: return .red
        case .preOrder: return .blue
        case .discontinued: return .gray
        }
    }
}

// MARK: - Deposit Type
enum DepositType: String, CaseIterable, Codable {
    case fixed = "FIXED"
    case percentage = "PERCENTAGE"
    
    var displayName: String {
        switch self {
        case .fixed: return "Fixed Amount"
        case .percentage: return "Percentage"
        }
    }
}

// MARK: - Classification Level
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

// MARK: - Supporting Models
struct ContactInfo: Codable {
    var email: String
    var phone: String
    var instagram: String?
    var website: String?
}

// MARK: - Business Hours and Day Schedule
struct DaySchedule: Codable {
    var openTime: String
    var closeTime: String
    var isOpen: Bool
    
    init(openTime: String = "9:00 AM", closeTime: String = "5:00 PM", isOpen: Bool = true) {
        self.openTime = openTime
        self.closeTime = closeTime
        self.isOpen = isOpen
    }
}

struct BusinessHours: Codable {
    var monday: DaySchedule
    var tuesday: DaySchedule
    var wednesday: DaySchedule
    var thursday: DaySchedule
    var friday: DaySchedule
    var saturday: DaySchedule
    var sunday: DaySchedule
    
    init(monday: DaySchedule = DaySchedule(), tuesday: DaySchedule = DaySchedule(), wednesday: DaySchedule = DaySchedule(), thursday: DaySchedule = DaySchedule(), friday: DaySchedule = DaySchedule(), saturday: DaySchedule = DaySchedule(), sunday: DaySchedule = DaySchedule(isOpen: false)) {
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
    }
    
    static var defaultHours: BusinessHours {
        return BusinessHours()
    }
    
    var isOpenToday: Bool {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        
        switch today {
        case 1: return sunday.isOpen
        case 2: return monday.isOpen
        case 3: return tuesday.isOpen
        case 4: return wednesday.isOpen
        case 5: return thursday.isOpen
        case 6: return friday.isOpen
        case 7: return saturday.isOpen
        default: return false
        }
    }
}

// MARK: - Platform Fee Configuration
struct PlatformFeeConfig {
    static let serviceFeePercentage: Double = 8.5
    static let stripeFeePercentage: Double = 2.9
    static let stripeFeeFixed: Double = 0.30
    
    static func calculateBusinessPayout(for amount: Double) -> Double {
        let serviceFee = amount * (serviceFeePercentage / 100.0)
        let stripeFee = (amount * (stripeFeePercentage / 100.0)) + stripeFeeFixed
        return amount - serviceFee - stripeFee
    }
    
    static func calculateTotalFees(for amount: Double) -> Double {
        let serviceFee = amount * (serviceFeePercentage / 100.0)
        let stripeFee = (amount * (stripeFeePercentage / 100.0)) + stripeFeeFixed
        return serviceFee + stripeFee
    }
}

// MARK: - Service Conversion Extension
extension Service {
    func toServUService() -> ServUService {
        return ServUService(
            name: self.name,
            description: self.description,
            price: self.price,
            duration: self.duration,
            requiresDeposit: self.requiresDeposit,
            depositAmount: self.depositAmount,
            depositType: self.depositType,
            depositPolicy: self.depositPolicy
        )
    }
}

// MARK: - Enhanced Business Extension for Legacy Support
extension EnhancedBusiness {
    func toBusiness() -> Business {
        return Business(
            name: self.name,
            category: self.serviceCategories.first ?? .other,
            description: self.description,
            rating: self.rating,
            priceRange: self.priceRange,
            imageURL: self.imageURL,
            isActive: self.isActive,
            location: self.location,
            contactInfo: self.contactInfo,
            services: self.services,
            availability: self.availability
        )
    }
}