//
//  DepositType.swift
//  ServU
//
//  Created by Amber Still on 8/5/25.
//


//
//  CoreModels.swift
//  ServU
//
//  Created by Quian Bowden on 8/5/25.
//

import Foundation
import SwiftUI

// MARK: - Core Enums and Types

// MARK: - Deposit Type (SINGLE SOURCE OF TRUTH)
enum DepositType: String, CaseIterable, Codable {
    case fixed = "Fixed Amount"
    case percentage = "Percentage"
    
    var displayName: String {
        return self.rawValue
    }
    
    var description: String {
        switch self {
        case .fixed:
            return "Fixed dollar amount"
        case .percentage:
            return "Percentage of service price"
        }
    }
}

// MARK: - Payment Status (SINGLE SOURCE OF TRUTH)
enum PaymentStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case depositPaid = "Deposit Paid"
    case fullyPaid = "Fully Paid"
    case refunded = "Refunded"
    case failed = "Failed"
    case notRequired = "No Payment Required"
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .depositPaid: return .blue
        case .fullyPaid: return .green
        case .refunded: return .gray
        case .failed: return .red
        case .notRequired: return .green
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .depositPaid: return "creditcard"
        case .fullyPaid: return "checkmark.circle.fill"
        case .refunded: return "arrow.counterclockwise"
        case .failed: return "xmark.circle"
        case .notRequired: return "checkmark.circle"
        }
    }
}

// MARK: - Booking Status
enum BookingStatus: String, CaseIterable, Codable {
    case pending = "PENDING"
    case confirmed = "CONFIRMED"
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
    case noShow = "NO_SHOW"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .noShow: return "No Show"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .confirmed: return "checkmark.circle.fill"
        case .inProgress: return "play.circle.fill"
        case .completed: return "checkmark.seal.fill"
        case .cancelled: return "xmark.circle.fill"
        case .noShow: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .confirmed: return .blue
        case .inProgress: return .purple
        case .completed: return .green
        case .cancelled: return .red
        case .noShow: return .gray
        }
    }
}

// MARK: - Service Category
enum ServiceCategory: String, CaseIterable, Identifiable, Codable {
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
}

// MARK: - Price Range
enum PriceRange: String, CaseIterable, Identifiable, Codable {
    case budget = "$"
    case moderate = "$$"
    case premium = "$$$"
    case luxury = "$$$$"
    
    var id: String { rawValue }
}

// MARK: - Classification Level
enum ClassificationLevel: String, CaseIterable, Codable {
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

struct BusinessHours: Codable {
    var monday: DayHours?
    var tuesday: DayHours?
    var wednesday: DayHours?
    var thursday: DayHours?
    var friday: DayHours?
    var saturday: DayHours?
    var sunday: DayHours?
}

struct DayHours: Codable {
    var openTime: Date
    var closeTime: Date
    var isOpen: Bool = true
}

// MARK: - Business Hours Extension
extension BusinessHours {
    static var defaultHours: BusinessHours {
        let openTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
        let closeTime = Calendar.current.date(from: DateComponents(hour: 17, minute: 0)) ?? Date()
        
        let dayHours = DayHours(openTime: openTime, closeTime: closeTime, isOpen: true)
        
        return BusinessHours(
            monday: dayHours,
            tuesday: dayHours,
            wednesday: dayHours,
            thursday: dayHours,
            friday: dayHours,
            saturday: DayHours(openTime: openTime, closeTime: closeTime, isOpen: false),
            sunday: DayHours(openTime: openTime, closeTime: closeTime, isOpen: false)
        )
    }
    
    var isOpenToday: Bool {
        let today = Calendar.current.component(.weekday, from: Date())
        let todayHours = getDayHours(for: today)
        return todayHours?.isOpen ?? false
    }
    
    func getDayHours(for weekday: Int) -> DayHours? {
        switch weekday {
        case 1: return sunday
        case 2: return monday
        case 3: return tuesday
        case 4: return wednesday
        case 5: return thursday
        case 6: return friday
        case 7: return saturday
        default: return nil
        }
    }
    
    var todayHours: String {
        let today = Calendar.current.component(.weekday, from: Date())
        guard let dayHours = getDayHours(for: today), dayHours.isOpen else {
            return "Closed today"
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        return "\(formatter.string(from: dayHours.openTime)) - \(formatter.string(from: dayHours.closeTime))"
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
    
    var displayName: String {
        switch self {
        case .campusPickup: return "Campus Pickup"
        case .dormDelivery: return "Dorm Delivery"
        case .localDelivery: return "Local Delivery"
        case .standardShipping: return "Standard Shipping"
        case .expressShipping: return "Express Shipping"
        case .freeShipping: return "Free Shipping"
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
    
    var cost: Double {
        switch self {
        case .campusPickup: return 0.0
        case .dormDelivery: return 3.0
        case .localDelivery: return 5.0
        case .standardShipping: return 7.99
        case .expressShipping: return 12.99
        case .freeShipping: return 0.0
        }
    }
    
    var estimatedDelivery: String {
        switch self {
        case .campusPickup: return "Same day"
        case .dormDelivery: return "Same day"
        case .localDelivery: return "1-2 days"
        case .standardShipping: return "3-5 days"
        case .expressShipping: return "1-2 days"
        case .freeShipping: return "5-7 days"
        }
    }
    
    var description: String {
        return "Delivery via \(displayName.lowercased())"
    }
}