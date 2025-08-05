//
//  Business.swift
//  ServU
//
//  Created by Amber Still on 8/5/25.
//


//
//  BusinessModels.swift
//  ServU
//
//  Created by Quian Bowden on 8/5/25.
//

import Foundation
import SwiftUI

// MARK: - Business Model (Legacy Support)
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
    
    enum CodingKeys: String, CodingKey {
        case name, category, description, rating, priceRange, imageURL
        case isActive, location, contactInfo, services, availability
    }
}

// MARK: - Enhanced Business Model (Main Business Model)
struct EnhancedBusiness: Identifiable, Codable {
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
    
    // Service-related properties
    var serviceCategories: [ServiceCategory]
    var services: [Service]
    var availability: BusinessHours
    
    // Product-related properties
    var productCategories: [ProductCategory]
    var products: [Product]
    var shippingOptions: [ShippingOption]
    var returnPolicy: String
    
    // Business verification and metrics
    var isVerified: Bool
    var joinedDate: Date
    var totalSales: Int
    var responseTime: String
    
    init(name: String, businessType: BusinessType, description: String, rating: Double, priceRange: PriceRange, imageURL: String? = nil, isActive: Bool = true, location: String, contactInfo: ContactInfo, ownerId: String, ownerName: String, serviceCategories: [ServiceCategory] = [], services: [Service] = [], availability: BusinessHours = .defaultHours, productCategories: [ProductCategory] = [], products: [Product] = [], shippingOptions: [ShippingOption] = [], returnPolicy: String = "", isVerified: Bool = false, joinedDate: Date = Date(), totalSales: Int = 0, responseTime: String = "Usually responds within 1 hour") {
        
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
        self.productCategories = productCategories
        self.products = products
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
    
    var hasServices: Bool {
        return businessType == .services || businessType == .both
    }
    
    var hasProducts: Bool {
        return businessType == .products || businessType == .both
    }
    
    var averageServicePrice: Double {
        guard !services.isEmpty else { return 0.0 }
        return services.reduce(0) { $0 + $1.price } / Double(services.count)
    }
    
    var averageProductPrice: Double {
        guard !products.isEmpty else { return 0.0 }
        return products.reduce(0) { $0 + $1.basePrice } / Double(products.count)
    }
    
    var totalProductInventory: Int {
        return products.reduce(0) { $0 + $1.totalInventory }
    }
    
    var isOpenNow: Bool {
        return availability.isOpenToday
    }
    
    var formattedJoinDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: joinedDate)
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
    @Published var businesses: [EnhancedBusiness] = []
    
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