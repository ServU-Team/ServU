//
//  ServUService.swift
//  ServU
//
//  Created by Amber Still on 7/31/25.
//


//
//  Models.swift
//  ServU
//
//  Created by Quian Bowden on 6/27/25.
//  Updated by Assistant on 7/31/25.
//  Added ServUService model for enhanced service booking
//

import Foundation
import SwiftUI

// MARK: - Enhanced Service Model (NEW)
struct ServUService: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var price: Double
    var duration: String // e.g., "1 hour", "30 minutes"
    var isAvailable: Bool = true
    
    // Deposit/Payment Properties
    var requiresDeposit: Bool = false
    var depositAmount: Double = 0.0
    var depositType: DepositType = .fixed
    var depositPolicy: String = ""
    
    // Computed Properties
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
}

// MARK: - Deposit Type (NEW)
enum DepositType: String, CaseIterable {
    case fixed = "Fixed Amount"
    case percentage = "Percentage"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Payment Status (NEW)
enum PaymentStatus: String, CaseIterable {
    case pending = "Pending"
    case depositPaid = "Deposit Paid"
    case fullyPaid = "Fully Paid"
    case refunded = "Refunded"
    case failed = "Failed"
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .depositPaid: return .blue
        case .fullyPaid: return .green
        case .refunded: return .gray
        case .failed: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .depositPaid: return "creditcard"
        case .fullyPaid: return "checkmark.circle.fill"
        case .refunded: return "arrow.counterclockwise"
        case .failed: return "xmark.circle"
        }
    }
}

// MARK: - User Profile Model (ORIGINAL)
class UserProfile: ObservableObject {
    // Microsoft Graph data
    @Published var id: String = ""
    @Published var displayName: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var jobTitle: String?
    @Published var profileImageData: Data?
    
    // ServU-specific data (user can edit these)
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

// MARK: - College Classification (ORIGINAL)
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

// MARK: - College Model (ORIGINAL)
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
    
    // Color scheme for UI theming
    var colorScheme: CollegeColorScheme {
        CollegeColorScheme(
            primary: primaryColor,
            secondary: secondaryColor,
            background: primaryColor.opacity(0.1),
            accent: secondaryColor
        )
    }
}

// MARK: - College Color Scheme (ORIGINAL)
struct CollegeColorScheme {
    let primary: Color
    let secondary: Color
    let background: Color
    let accent: Color
}

// MARK: - Business Model (ORIGINAL - Updated to use ServUService)
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
    var services: [ServUService] = [] // Updated to use ServUService
    var availability: BusinessHours
}

// MARK: - Service Category (ORIGINAL)
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

// MARK: - Supporting Models (ORIGINAL)
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
    var monday: DaySchedule
    var tuesday: DaySchedule
    var wednesday: DaySchedule
    var thursday: DaySchedule
    var friday: DaySchedule
    var saturday: DaySchedule
    var sunday: DaySchedule
    
    static var defaultHours: BusinessHours {
        let daySchedule = DaySchedule(isOpen: true, openTime: "9:00 AM", closeTime: "5:00 PM")
        return BusinessHours(
            monday: daySchedule,
            tuesday: daySchedule,
            wednesday: daySchedule,
            thursday: daySchedule,
            friday: daySchedule,
            saturday: DaySchedule(isOpen: true, openTime: "10:00 AM", closeTime: "4:00 PM"),
            sunday: DaySchedule(isOpen: false, openTime: "", closeTime: "")
        )
    }
}

struct DaySchedule {
    var isOpen: Bool
    var openTime: String
    var closeTime: String
}

// MARK: - Legacy Service Model (DEPRECATED - Use ServUService instead)
struct Service: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var price: Double
    var duration: String // e.g., "1 hour", "30 minutes"
    var isAvailable: Bool = true
}

// MARK: - College Data Service (ORIGINAL)
class CollegeDataService {
    
    // Static college database - in a real app, this might come from an API
    private static let colleges: [College] = [
        // HBCUs
        College(
            id: "tuskegee",
            name: "Tuskegee University",
            domain: "tuskegee.edu",
            primaryColor: Color(red: 0.8, green: 0.6, blue: 0.0), // Gold
            secondaryColor: Color(red: 0.4, green: 0.0, blue: 0.0), // Maroon
            logoURL: nil,
            state: "Alabama",
            city: "Tuskegee",
            isHBCU: true
        ),
        College(
            id: "howard",
            name: "Howard University",
            domain: "howard.edu",
            primaryColor: Color.blue,
            secondaryColor: Color.red,
            logoURL: nil,
            state: "Washington DC",
            city: "Washington",
            isHBCU: true
        ),
        College(
            id: "spelman",
            name: "Spelman College",
            domain: "spelman.edu",
            primaryColor: Color.blue,
            secondaryColor: Color.white,
            logoURL: nil,
            state: "Georgia",
            city: "Atlanta",
            isHBCU: true
        ),
        College(
            id: "morehouse",
            name: "Morehouse College",
            domain: "morehouse.edu",
            primaryColor: Color(red: 0.5, green: 0.0, blue: 0.13), // Maroon
            secondaryColor: Color.white,
            logoURL: nil,
            state: "Georgia",
            city: "Atlanta",
            isHBCU: true
        ),
        // Add more colleges as needed
        College(
            id: "example",
            name: "Example University",
            domain: "example.edu",
            primaryColor: Color.blue,
            secondaryColor: Color.orange,
            logoURL: nil,
            state: "Example State",
            city: "Example City",
            isHBCU: false
        )
    ]
    
    /// Extracts college information from email domain
    static func getCollegeInfo(from email: String) -> College? {
        let domain = extractDomain(from: email)
        return colleges.first { $0.domain.lowercased() == domain.lowercased() }
    }
    
    /// Gets all available colleges
    static func getAllColleges() -> [College] {
        return colleges
    }
    
    /// Extracts domain from email address
    private static func extractDomain(from email: String) -> String {
        let components = email.components(separatedBy: "@")
        return components.count > 1 ? components[1] : ""
    }
    
    /// Default college for unknown domains
    static func defaultCollege() -> College {
        return College(
            id: "unknown",
            name: "Unknown College",
            domain: "",
            primaryColor: Color.blue,
            secondaryColor: Color.gray,
            logoURL: nil,
            state: "",
            city: "",
            isHBCU: false
        )
    }
}

// MARK: - Enhanced Business Model (NEW - FOR PRODUCTS)
struct EnhancedBusiness: Identifiable {
    let id = UUID()
    var name: String
    var businessType: BusinessType
    var description: String
    var rating: Double
    var priceRange: PriceRange
    var imageURL: String?
    var isActive: Bool = true
    var location: String
    var contactInfo: ContactInfo
    var ownerId: String
    var ownerName: String
    
    // Service-specific properties
    var serviceCategories: [ServiceCategory] = []
    var services: [ServUService] = [] // Updated to use ServUService
    var availability: BusinessHours
    
    // Product-specific properties
    var products: [Product] = []
    var productCategories: [ProductCategory] = []
    var shippingOptions: [ShippingOption] = []
    var returnPolicy: String = ""
    
    // Business verification and features
    var isVerified: Bool = false
    var joinedDate: Date = Date()
    var totalSales: Int = 0
    var responseTime: String = "Usually responds within 1 hour"
    
    var displayCategories: String {
        switch businessType {
        case .services:
            return serviceCategories.map { $0.displayName }.joined(separator: ", ")
        case .products:
            return productCategories.map { $0.displayName }.joined(separator: ", ")
        case .both:
            let serviceNames = serviceCategories.map { $0.displayName }
            let productNames = productCategories.map { $0.displayName }
            return (serviceNames + productNames).joined(separator: ", ")
        }
    }
}

// MARK: - Business Type (NEW)
enum BusinessType: String, CaseIterable {
    case services = "Services"
    case products = "Products" 
    case both = "Services & Products"
    
    var icon: String {
        switch self {
        case .services: return "hand.raised.fill"
        case .products: return "bag.fill"
        case .both: return "building.2.fill"
        }
    }
    
    var description: String {
        switch self {
        case .services: return "Offer services like tutoring, photography, styling"
        case .products: return "Sell physical products like clothing, electronics, food"
        case .both: return "Offer both services and sell products"
        }
    }
}

// MARK: - Product Model (NEW)
struct Product: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var category: ProductCategory
    var basePrice: Double
    var images: [ProductImage]
    var variants: [ProductVariant]
    var inventory: ProductInventory
    var specifications: [ProductSpecification]
    var tags: [String]
    var isActive: Bool = true
    var createdDate: Date = Date()
    var lastUpdated: Date = Date()
    
    // Computed properties
    var displayPrice: String {
        if variants.isEmpty {
            return String(format: "$%.2f", basePrice)
        } else {
            let prices = variants.map { $0.price }
            let minPrice = prices.min() ?? basePrice
            let maxPrice = prices.max() ?? basePrice
            
            if minPrice == maxPrice {
                return String(format: "$%.2f", minPrice)
            } else {
                return String(format: "$%.2f - $%.2f", minPrice, maxPrice)
            }
        }
    }
    
    var totalInventory: Int {
        if variants.isEmpty {
            return inventory.quantity
        } else {
            return variants.reduce(0) { $0 + $1.inventory.quantity }
        }
    }
    
    var isInStock: Bool {
        return totalInventory > 0
    }
    
    var primaryImage: ProductImage? {
        return images.first { $0.isPrimary } ?? images.first
    }
}

// MARK: - Product Category (NEW)
enum ProductCategory: String, CaseIterable {
    case clothing = "Clothing"
    case accessories = "Accessories"
    case electronics = "Electronics"
    case books = "Books & Supplies"
    case food = "Food & Beverages"
    case health = "Health & Beauty"
    case home = "Home & Dorm"
    case sports = "Sports & Fitness"
    case art = "Art & Crafts"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .clothing: return "tshirt.fill"
        case .accessories: return "bag.fill"
        case .electronics: return "iphone"
        case .books: return "book.fill"
        case .food: return "takeoutbag.and.cup.and.straw.fill"
        case .health: return "heart.fill"
        case .home: return "house.fill"
        case .sports: return "sportscourt.fill"
        case .art: return "paintbrush.fill"
        case .other: return "star.fill"
        }
    }
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Product Image (NEW)
struct ProductImage: Identifiable {
    let id = UUID()
    var imageURL: String
    var isPrimary: Bool = false
    var altText: String = ""
    var imageData: Data? // For locally stored images
    
    var displayImage: UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }
}

// MARK: - Product Variant (NEW)
struct ProductVariant: Identifiable {
    let id = UUID()
    var name: String // e.g., "Medium - Red"
    var price: Double
    var sku: String
    var attributes: [VariantAttribute] // size, color, etc.
    var inventory: ProductInventory
    var isActive: Bool = true
    
    var displayName: String {
        let attributeNames = attributes.map { "\($0.value)" }
        return attributeNames.joined(separator: " - ")
    }
}

// MARK: - Variant Attribute (NEW)
struct VariantAttribute: Identifiable {
    let id = UUID()
    var name: String // "Size", "Color"
    var value: String // "Medium", "Red"
    var displayOrder: Int = 0
}

// MARK: - Product Inventory (NEW)
struct ProductInventory {
    var quantity: Int
    var lowStockThreshold: Int = 5
    var trackInventory: Bool = true
    
    var isLowStock: Bool {
        return trackInventory && quantity <= lowStockThreshold
    }
    
    var stockStatus: StockStatus {
        if !trackInventory { return .unlimited }
        if quantity == 0 { return .outOfStock }
        if quantity <= lowStockThreshold { return .lowStock }
        return .inStock
    }
}

// MARK: - Stock Status (NEW)
enum StockStatus: String {
    case inStock = "In Stock"
    case lowStock = "Low Stock"
    case outOfStock = "Out of Stock"
    case unlimited = "Available"
    
    var color: Color {
        switch self {
        case .inStock: return .green
        case .lowStock: return .orange
        case .outOfStock: return .red
        case .unlimited: return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .inStock: return "checkmark.circle.fill"
        case .lowStock: return "exclamationmark.triangle.fill"
        case .outOfStock: return "xmark.circle.fill"
        case .unlimited: return "infinity.circle.fill"
        }
    }
}

// MARK: - Product Specification (NEW)
struct ProductSpecification: Identifiable {
    let id = UUID()
    var name: String
    var value: String
}

// MARK: - Shipping Option (NEW)
struct ShippingOption: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var price: Double
    var estimatedDays: String
    var isAvailable: Bool = true
    
    static let campusPickup = ShippingOption(
        name: "Campus Pickup",
        description: "Pick up on campus - free!",
        price: 0.0,
        estimatedDays: "Same day"
    )
    
    static let dormDelivery = ShippingOption(
        name: "Dorm Delivery",
        description: "Delivered to your dorm",
        price: 3.00,
        estimatedDays: "1-2 days"
    )
    
    static let standardShipping = ShippingOption(
        name: "Standard Shipping",
        description: "Ship anywhere in the US",
        price: 8.99,
        estimatedDays: "3-5 days"
    )
}

// MARK: - Shopping Cart Item (NEW)
struct CartItem: Identifiable {
    let id = UUID()
    var product: Product
    var selectedVariant: ProductVariant?
    var quantity: Int
    var addedDate: Date = Date()
    
    var unitPrice: Double {
        return selectedVariant?.price ?? product.basePrice
    }
    
    var totalPrice: Double {
        return unitPrice * Double(quantity)
    }
    
    var displayName: String {
        if let variant = selectedVariant {
            return "\(product.name) - \(variant.displayName)"
        }
        return product.name
    }
}

// MARK: - Shopping Cart Manager (NEW)
class ShoppingCartManager: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var selectedShippingOption: ShippingOption?
    
    var subtotal: Double {
        return items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var shippingCost: Double {
        return selectedShippingOption?.price ?? 0.0
    }
    
    var total: Double {
        return subtotal + shippingCost
    }
    
    var itemCount: Int {
        return items.reduce(0) { $0 + $1.quantity }
    }
    
    func addItem(_ product: Product, variant: ProductVariant? = nil, quantity: Int = 1) {
        // Check if item already exists in cart
        if let existingIndex = items.firstIndex(where: { 
            $0.product.id == product.id && $0.selectedVariant?.id == variant?.id 
        }) {
            items[existingIndex].quantity += quantity
        } else {
            let cartItem = CartItem(product: product, selectedVariant: variant, quantity: quantity)
            items.append(cartItem)
        }
    }
    
    func removeItem(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if quantity <= 0 {
                items.remove(at: index)
            } else {
                items[index].quantity = quantity
            }
        }
    }
    
    func clearCart() {
        items.removeAll()
        selectedShippingOption = nil
    }
}