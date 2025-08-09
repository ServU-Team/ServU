//
//  EnhancedBusiness.swift
//  ServU
//
//  Created by Amber Still on 8/9/25.
//


//
//  EnhancedModels.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  Enhanced business and product models with extended functionality
//

import SwiftUI
import Foundation
import CoreLocation

// MARK: - Enhanced Business Model
struct EnhancedBusiness: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let businessType: BusinessType
    let serviceCategories: [ServiceCategory]
    let productCategories: [ProductCategory]
    let priceRange: PriceRange
    let ownerId: UUID
    let ownerName: String
    let location: BusinessLocation
    let contactInfo: ContactInfo
    let businessHours: BusinessHours
    let profileImageURL: String?
    let coverImageURL: String?
    let rating: Double
    let reviewCount: Int
    let isVerified: Bool
    let isOnline: Bool
    let isFeatured: Bool
    let createdAt: Date
    let updatedAt: Date
    let status: BusinessStatus
    
    // Enhanced Properties
    let services: [Service]
    let products: [Product]
    let portfolio: [PortfolioItem]
    let socialMedia: SocialMediaLinks
    let businessMetrics: BusinessMetrics
    let paymentMethods: [PaymentMethod]
    let policies: BusinessPolicies
    
    // Computed Properties
    var displayRating: String {
        return String(format: "%.1f", rating)
    }
    
    var primaryCategory: ServiceCategory? {
        return serviceCategories.first
    }
    
    var isCurrentlyOpen: Bool {
        return businessHours.isOpenToday // Implementation from BusinessHours extension
    }
    
    var totalServiceCount: Int {
        return services.count
    }
    
    var totalProductCount: Int {
        return products.count
    }
    
    var hasProducts: Bool {
        return businessType == .products || businessType == .both
    }
    
    var hasServices: Bool {
        return businessType == .services || businessType == .both
    }
    
    var averageServicePrice: Double {
        guard !services.isEmpty else { return 0 }
        return services.reduce(0) { $0 + $1.price } / Double(services.count)
    }
    
    var averageProductPrice: Double {
        guard !products.isEmpty else { return 0 }
        return products.reduce(0) { $0 + $1.price } / Double(products.count)
    }
    
    var distanceFromUser: Double? {
        // Will be calculated dynamically based on user location
        return nil
    }
    
    // Business Status Helpers
    var isActive: Bool {
        return status == .active
    }
    
    var canAcceptBookings: Bool {
        return isActive && hasServices
    }
    
    var canSellProducts: Bool {
        return isActive && hasProducts
    }
}

// MARK: - Enhanced Product Model
struct Product: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let price: Double
    let category: ProductCategory
    let businessId: UUID
    let imageURLs: [String]
    let isAvailable: Bool
    let stockQuantity: Int?
    let isDigital: Bool
    let weight: Double?
    let dimensions: ProductDimensions?
    let tags: [String]
    let createdAt: Date
    let updatedAt: Date
    
    // Enhanced Properties
    let variants: [ProductVariant]
    let specifications: [ProductSpecification]
    let shippingInfo: ShippingInfo?
    let customizationOptions: [CustomizationOption]
    
    // Computed Properties
    var priceFormatted: String {
        return String(format: "$%.2f", price)
    }
    
    var primaryImageURL: String? {
        return imageURLs.first
    }
    
    var isInStock: Bool {
        if let stock = stockQuantity {
            return stock > 0
        }
        return isAvailable
    }
    
    var stockStatus: StockStatus {
        guard let stock = stockQuantity else {
            return isAvailable ? .available : .outOfStock
        }
        
        if stock == 0 {
            return .outOfStock
        } else if stock <= 5 {
            return .lowStock
        } else {
            return .inStock
        }
    }
    
    var hasVariants: Bool {
        return !variants.isEmpty
    }
    
    var isCustomizable: Bool {
        return !customizationOptions.isEmpty
    }
    
    var requiresShipping: Bool {
        return !isDigital && shippingInfo != nil
    }
}

// MARK: - Service Model (Enhanced)
struct Service: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let price: Double
    let duration: String
    let category: ServiceCategory
    let businessId: UUID
    let imageURLs: [String]
    let isAvailable: Bool
    let requiresDeposit: Bool
    let depositAmount: Double
    let depositType: DepositType
    let depositPolicy: String
    let cancellationPolicy: String
    let tags: [String]
    let createdAt: Date
    let updatedAt: Date
    
    // Enhanced Properties
    let addOnServices: [AddOnService]
    let availability: ServiceAvailability
    let requirements: [ServiceRequirement]
    let portfolio: [PortfolioItem]
    
    // Computed Properties
    var priceFormatted: String {
        return String(format: "$%.2f", price)
    }
    
    var depositFormatted: String {
        if depositType == .percentage {
            return String(format: "%.0f%%", depositAmount)
        } else {
            return String(format: "$%.2f", depositAmount)
        }
    }
    
    var primaryImageURL: String? {
        return imageURLs.first
    }
    
    var hasAddOns: Bool {
        return !addOnServices.isEmpty
    }
    
    var totalDurationMinutes: Int {
        // Parse duration string (e.g., "2 hours", "30 minutes")
        // Simple implementation - can be enhanced
        return 60
    }
}

// MARK: - Supporting Models

struct BusinessLocation: Codable {
    let address: String
    let city: String
    let state: String
    let zipCode: String
    let coordinate: Coordinate?
    let isServiceArea: Bool // For businesses that travel to customers
    let serviceRadius: Double? // In miles
    
    var fullAddress: String {
        return "\(address), \(city), \(state) \(zipCode)"
    }
}

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    var clLocation: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct PortfolioItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String?
    let imageURL: String
    let category: String
    let createdAt: Date
}

struct SocialMediaLinks: Codable {
    let instagram: String?
    let tiktok: String?
    let facebook: String?
    let twitter: String?
    let website: String?
    let linkedin: String?
}

struct BusinessMetrics: Codable {
    let totalBookings: Int
    let totalSales: Double
    let averageRating: Double
    let repeatCustomerRate: Double
    let responseTime: TimeInterval // Average response time in seconds
    let completionRate: Double // Percentage of completed bookings
}

enum PaymentMethod: String, CaseIterable, Codable {
    case cash = "Cash"
    case venmo = "Venmo"
    case cashApp = "Cash App"
    case zelle = "Zelle"
    case paypal = "PayPal"
    case card = "Credit/Debit Card"
    case applePay = "Apple Pay"
    
    var displayName: String {
        return self.rawValue
    }
    
    var systemIcon: String {
        switch self {
        case .cash: return "dollarsign.circle"
        case .venmo: return "v.circle"
        case .cashApp: return "c.circle"
        case .zelle: return "z.circle"
        case .paypal: return "p.circle"
        case .card: return "creditcard"
        case .applePay: return "applelogo"
        }
    }
}

struct BusinessPolicies: Codable {
    let cancellationPolicy: String
    let refundPolicy: String
    let reschedulePolicy: String
    let latePolicyMinutes: Int
    let noShowPolicy: String
    let depositPolicy: String
    let paymentTerms: String
}

// MARK: - Product Support Models

struct ProductVariant: Identifiable, Codable {
    let id: UUID
    let name: String
    let price: Double
    let stockQuantity: Int?
    let attributes: [String: String] // e.g., ["Color": "Red", "Size": "Large"]
    let imageURL: String?
    let isAvailable: Bool
}

struct ProductDimensions: Codable {
    let length: Double
    let width: Double
    let height: Double
    let unit: String // "inches", "cm", etc.
    
    var formatted: String {
        return "\(length) × \(width) × \(height) \(unit)"
    }
}

struct ProductSpecification: Identifiable, Codable {
    let id: UUID
    let name: String
    let value: String
    let category: String?
}

struct ShippingInfo: Codable {
    let shippingCost: Double
    let freeShippingThreshold: Double?
    let estimatedDeliveryDays: Int
    let shippingMethods: [ShippingMethod]
    let handlingTime: Int // Days to process order
}

struct ShippingMethod: Identifiable, Codable {
    let id: UUID
    let name: String
    let cost: Double
    let estimatedDays: Int
    let description: String?
}

struct CustomizationOption: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: CustomizationType
    let options: [String]
    let additionalCost: Double
    let isRequired: Bool
}

enum CustomizationType: String, CaseIterable, Codable {
    case text = "Text Input"
    case color = "Color Selection"
    case size = "Size Selection"
    case material = "Material Selection"
    case quantity = "Quantity"
    case dropdown = "Dropdown Selection"
}

enum StockStatus: String, CaseIterable {
    case inStock = "In Stock"
    case lowStock = "Low Stock"
    case outOfStock = "Out of Stock"
    case available = "Available"
    
    var color: Color {
        switch self {
        case .inStock, .available: return .green
        case .lowStock: return .orange
        case .outOfStock: return .red
        }
    }
    
    var systemIcon: String {
        switch self {
        case .inStock, .available: return "checkmark.circle.fill"
        case .lowStock: return "exclamationmark.triangle.fill"
        case .outOfStock: return "xmark.circle.fill"
        }
    }
}

// MARK: - Service Support Models

struct AddOnService: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let price: Double
    let duration: String
    let isOptional: Bool
}

struct ServiceAvailability: Codable {
    let daysOfWeek: [Int] // 1-7, Sunday = 1
    let timeSlots: [TimeSlot]
    let bookingWindow: Int // Days in advance for booking
    let bufferTime: Int // Minutes between appointments
}

struct TimeSlot: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let isAvailable: Bool
    let maxBookings: Int
}

struct ServiceRequirement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let isRequired: Bool
    let type: RequirementType
}

enum RequirementType: String, CaseIterable, Codable {
    case preparation = "Preparation"
    case materials = "Materials to Bring"
    case restrictions = "Restrictions"
    case policies = "Policies"
    case health = "Health & Safety"
}