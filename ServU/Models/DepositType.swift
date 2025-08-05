//
//  DepositType.swift
//  ServU
//
//  Created by Amber Still on 8/5/25.
//


//
//  Service.swift
//  ServU
//
//  Created by Quian Bowden on 8/4/25.
//

import Foundation
import SwiftUI

// MARK: - Deposit Type
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

// MARK: - Service Model (Updated for compatibility)
struct Service: Identifiable, Codable {
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
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case name, description, price, duration, isAvailable
        case requiresDeposit, depositAmount, depositType, depositPolicy
    }
    
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
struct Business: Identifiable, Codable {
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
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case name, category, description, rating, priceRange, imageURL
        case isActive, location, contactInfo, services, availability
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

// MARK: - Supporting Models
enum PriceRange: String, CaseIterable, Identifiable, Codable {
    case budget = "$"
    case moderate = "$$"
    case premium = "$$$"
    case luxury = "$$$$"
    
    var id: String { rawValue }
}

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
    
    var price: Double { return cost } // Alias for compatibility
    
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
    
    var estimatedDays: String { return estimatedDelivery } // Alias for compatibility
    var name: String { return displayName } // Alias for compatibility
    var description: String { return "Delivery via \(displayName.lowercased())" } // Default description
}

// MARK: - Cart Item Model
struct CartItem: Identifiable, Codable {
    let id = UUID()
    var product: Product
    var selectedVariant: ProductVariant?
    var quantity: Int
    var addedDate: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case product, selectedVariant, quantity, addedDate
    }
    
    var unitPrice: Double {
        return selectedVariant?.price ?? product.basePrice
    }
    
    var totalPrice: Double {
        return unitPrice * Double(quantity)
    }
    
    var formattedTotalPrice: String {
        return String(format: "$%.2f", totalPrice)
    }
    
    var displayName: String {
        if let variant = selectedVariant {
            return "\(product.name) - \(variant.name)"
        }
        return product.name
    }
    
    var canIncreaseQuantity: Bool {
        let availableStock = selectedVariant?.inventory.quantity ?? product.inventory.quantity
        return quantity < availableStock
    }
}

// MARK: - Shopping Cart Model
struct ShoppingCart: Codable {
    var items: [CartItem] = []
    var selectedShippingOption: ShippingOption?
    var appliedCouponCode: String?
    var lastUpdated: Date = Date()
    
    var subtotal: Double {
        return items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var shippingCost: Double {
        return selectedShippingOption?.cost ?? 0.0
    }
    
    var total: Double {
        return subtotal + shippingCost
    }
    
    var itemCount: Int {
        return items.reduce(0) { $0 + $1.quantity }
    }
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    var formattedSubtotal: String {
        return String(format: "$%.2f", subtotal)
    }
    
    var formattedShippingCost: String {
        if shippingCost == 0 {
            return "FREE"
        }
        return String(format: "$%.2f", shippingCost)
    }
    
    var formattedTotal: String {
        return String(format: "$%.2f", total)
    }
    
    mutating func addItem(_ item: CartItem) {
        if let existingIndex = items.firstIndex(where: { 
            $0.product.id == item.product.id && $0.selectedVariant?.id == item.selectedVariant?.id 
        }) {
            items[existingIndex].quantity += item.quantity
        } else {
            items.append(item)
        }
        lastUpdated = Date()
    }
    
    mutating func removeItem(at index: Int) {
        guard index < items.count else { return }
        items.remove(at: index)
        lastUpdated = Date()
    }
    
    mutating func updateQuantity(for itemId: UUID, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            if quantity <= 0 {
                items.remove(at: index)
            } else {
                items[index].quantity = quantity
            }
            lastUpdated = Date()
        }
    }
    
    mutating func clear() {
        items.removeAll()
        selectedShippingOption = nil
        appliedCouponCode = nil
        lastUpdated = Date()
    }
}