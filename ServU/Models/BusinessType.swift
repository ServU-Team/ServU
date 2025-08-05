//
//  BusinessType.swift
//  ServU
//
//  Created by Amber Still on 8/5/25.
//


//
//  BusinessModels.swift
//  ServU
//
//  Created by Quian Bowden on 8/4/25.
//

import Foundation
import SwiftUI

// MARK: - Business Type
enum BusinessType: String, CaseIterable, Identifiable {
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
    
    var icon: String {
        switch self {
        case .services: return "hands.sparkles.fill"
        case .products: return "bag.fill"
        case .both: return "square.grid.2x2.fill"
        }
    }
}

// MARK: - Shipping Option
enum ShippingOption: String, CaseIterable, Identifiable {
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
}

// MARK: - Enhanced Business
struct EnhancedBusiness: Codable, Identifiable {
    let id = UUID()
    var name: String
    var businessType: BusinessType
    var description: String
    var rating: Double
    var priceRange: PriceRange
    var imageURL: String?
    var isActive: Bool
    var location: String
    var contactInfo: ContactInfo
    var ownerId: String
    var ownerName: String
    var serviceCategories: [ServiceCategory]
    var services: [ServUService]
    var availability: BusinessHours
    var products: [Product]
    var productCategories: [ProductCategory]
    var shippingOptions: [ShippingOption]
    var returnPolicy: String
    var isVerified: Bool
    var joinedDate: Date
    var totalSales: Int
    var responseTime: String
    
    init(name: String, businessType: BusinessType, description: String, rating: Double, priceRange: PriceRange, imageURL: String? = nil, isActive: Bool = true, location: String, contactInfo: ContactInfo, ownerId: String, ownerName: String, serviceCategories: [ServiceCategory] = [], services: [ServUService] = [], availability: BusinessHours, products: [Product] = [], productCategories: [ProductCategory] = [], shippingOptions: [ShippingOption] = [], returnPolicy: String = "", isVerified: Bool = false, joinedDate: Date = Date(), totalSales: Int = 0, responseTime: String = "Usually responds within 1 hour") {
        self.name = name
        self.businessType = businessType
        self.description = description
        self.rating = rating
        self.priceRange = priceRange
        self.imageURL = imageURL
        self.isActive = isActive
        self.location = location
        self.contactInfo = contactInfo
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.serviceCategories = serviceCategories
        self.services = services
        self.availability = availability
        self.products = products
        self.productCategories = productCategories
        self.shippingOptions = shippingOptions
        self.returnPolicy = returnPolicy
        self.isVerified = isVerified
        self.joinedDate = joinedDate
        self.totalSales = totalSales
        self.responseTime = responseTime
    }
    
    // MARK: - Computed Properties
    var displayCategories: String {
        let allCategories = serviceCategories.map { $0.displayName } + productCategories.map { $0.displayName }
        return allCategories.joined(separator: ", ")
    }
    
    var hasProducts: Bool {
        return businessType == .products || businessType == .both
    }
    
    var hasServices: Bool {
        return businessType == .services || businessType == .both
    }
    
    var inStockProducts: [Product] {
        return products.filter { $0.isInStock }
    }
    
    var availableServices: [ServUService] {
        return services.filter { $0.isAvailable }
    }
    
    var reviewCount: Int {
        return Int(rating * 50) + Int.random(in: 10...100) // Simulated review count
    }
    
    var formattedRating: String {
        return String(format: "%.1f", rating)
    }
    
    var ratingStars: String {
        let fullStars = Int(rating)
        let hasHalfStar = rating - Double(fullStars) >= 0.5
        let emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0)
        
        return String(repeating: "★", count: fullStars) +
               (hasHalfStar ? "☆" : "") +
               String(repeating: "☆", count: emptyStars)
    }
    
    var primaryCategory: String {
        if !serviceCategories.isEmpty {
            return serviceCategories.first?.displayName ?? "Service"
        } else if !productCategories.isEmpty {
            return productCategories.first?.displayName ?? "Products"
        } else {
            return "Business"
        }
    }
    
    var totalProductInventory: Int {
        return products.reduce(0) { $0 + $1.totalInventory }
    }
    
    var productPriceRange: (min: Double, max: Double)? {
        guard !products.isEmpty else { return nil }
        
        let prices = products.map { $0.basePrice }
        return (min: prices.min() ?? 0, max: prices.max() ?? 0)
    }
    
    var servicePriceRange: (min: Double, max: Double)? {
        guard !services.isEmpty else { return nil }
        
        let prices = services.map { $0.price }
        return (min: prices.min() ?? 0, max: prices.max() ?? 0)
    }
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