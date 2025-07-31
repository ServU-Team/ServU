//
//  BusinessConversionUtilities.swift
//  ServU
//
//  Created by Quian Bowden on 6/27/25.
//  Updated by Assistant on 7/31/25.
//  Fixed Service to ServUService conversion to preserve deposit properties
//

import Foundation

// MARK: - Business Model Conversion Utilities
// These help bridge between old Business model and new EnhancedBusiness model

extension Business {
    /// Converts old Business model to new EnhancedBusiness model
    func toEnhancedBusiness() -> EnhancedBusiness {
        return EnhancedBusiness(
            name: self.name,
            businessType: .services, // Default to services for old businesses
            description: self.description,
            rating: self.rating,
            priceRange: self.priceRange,
            imageURL: self.imageURL,
            isActive: self.isActive,
            location: self.location,
            contactInfo: self.contactInfo,
            ownerId: "legacy_\(UUID().uuidString.prefix(8))",
            ownerName: "Business Owner",
            serviceCategories: [self.category],
            services: self.services.map { $0.toServUService() }, // Convert all services
            availability: self.availability,
            products: [], // No products for legacy businesses
            productCategories: [],
            shippingOptions: [],
            returnPolicy: "",
            isVerified: false,
            joinedDate: Date(),
            totalSales: Int.random(in: 20...100),
            responseTime: "Usually responds within 1 hour"
        )
    }
}

extension EnhancedBusiness {
    /// Converts new EnhancedBusiness model to old Business model (for compatibility)
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
            services: self.services.map { $0.toLegacyService() }, // Convert all services
            availability: self.availability
        )
    }
    
    /// Checks if business has products
    var hasProducts: Bool {
        return businessType == .products || businessType == .both
    }
    
    /// Checks if business has services
    var hasServices: Bool {
        return businessType == .services || businessType == .both
    }
    
    /// Gets the primary business category for display
    var primaryCategory: String {
        if !serviceCategories.isEmpty {
            return serviceCategories.first?.displayName ?? "Service"
        } else if !productCategories.isEmpty {
            return productCategories.first?.displayName ?? "Products"
        } else {
            return "Business"
        }
    }
    
    /// Gets total inventory count across all products
    var totalProductInventory: Int {
        return products.reduce(0) { $0 + $1.totalInventory }
    }
    
    /// Gets products that are currently in stock
    var inStockProducts: [Product] {
        return products.filter { $0.isInStock }
    }
    
    /// Gets the price range for products
    var productPriceRange: (min: Double, max: Double)? {
        guard !products.isEmpty else { return nil }
        
        let prices = products.map { $0.basePrice }
        return (min: prices.min() ?? 0, max: prices.max() ?? 0)
    }
}

// MARK: - Service Conversion Utilities
extension ServUService {
    /// Converts ServUService to legacy Service model for backward compatibility
    func toLegacyService() -> Service {
        return Service(
            name: self.name,
            description: self.description,
            price: self.price,
            duration: self.duration,
            isAvailable: self.isAvailable,
            requiresDeposit: self.requiresDeposit,
            depositAmount: self.depositAmount,
            depositType: self.depositType,
            depositPolicy: self.depositPolicy
        )
    }
}

extension Service {
    /// Converts legacy Service to ServUService model
    /// ✅ FIXED: Now preserves all deposit-related properties
    func toServUService() -> ServUService {
        return ServUService(
            name: self.name,
            description: self.description,
            price: self.price,
            duration: self.duration,
            isAvailable: self.isAvailable,
            requiresDeposit: self.requiresDeposit,
            depositAmount: self.depositAmount,
            depositType: self.depositType,
            depositPolicy: self.depositPolicy
        )
    }
}

// MARK: - Product Utilities
extension Product {
    /// Gets the cheapest variant price, or base price if no variants
    var minPrice: Double {
        if variants.isEmpty {
            return basePrice
        }
        return variants.map { $0.price }.min() ?? basePrice
    }
    
    /// Gets the most expensive variant price, or base price if no variants
    var maxPrice: Double {
        if variants.isEmpty {
            return basePrice
        }
        return variants.map { $0.price }.max() ?? basePrice
    }
    
    /// Gets available variants (in stock)
    var availableVariants: [ProductVariant] {
        return variants.filter { $0.inventory.quantity > 0 }
    }
    
    /// Checks if product has size variants
    var hasSizeVariants: Bool {
        return variants.contains { variant in
            variant.attributes.contains { $0.name.lowercased() == "size" }
        }
    }
    
    /// Checks if product has color variants
    var hasColorVariants: Bool {
        return variants.contains { variant in
            variant.attributes.contains { $0.name.lowercased() == "color" }
        }
    }
    
    /// Gets unique sizes available
    var availableSizes: [String] {
        let sizes = variants.compactMap { variant in
            variant.attributes.first { $0.name.lowercased() == "size" }?.value
        }
        return Array(Set(sizes)).sorted()
    }
    
    /// Gets unique colors available
    var availableColors: [String] {
        let colors = variants.compactMap { variant in
            variant.attributes.first { $0.name.lowercased() == "color" }?.value
        }
        return Array(Set(colors)).sorted()
    }
}

// MARK: - Shopping Cart Utilities
extension ShoppingCartManager {
    /// Gets cart items for a specific business
    func getItems(for business: EnhancedBusiness) -> [CartItem] {
        return items.filter { item in
            // This would need to be enhanced with business tracking
            // For now, return all items
            return true
        }
    }
    
    /// Gets total number of unique products in cart
    var uniqueProductCount: Int {
        return items.count
    }
    
    /// Checks if cart has items from multiple businesses
    var hasMultipleBusinesses: Bool {
        // This would need business tracking on cart items
        // For now, return false
        return false
    }
    
    /// Gets cart items by category
    func getItems(for category: ProductCategory) -> [CartItem] {
        return items.filter { $0.product.category == category }
    }
    
    /// Removes all items of a specific product
    func removeAllItems(for product: Product) {
        items.removeAll { $0.product.id == product.id }
    }
    
    /// Updates shipping option and recalculates totals
    func updateShipping(_ option: ShippingOption) {
        selectedShippingOption = option
    }
    
    /// Gets formatted total with currency
    var formattedTotal: String {
        return String(format: "$%.2f", total)
    }
    
    /// Gets formatted subtotal with currency
    var formattedSubtotal: String {
        return String(format: "$%.2f", subtotal)
    }
    
    /// Gets formatted shipping cost with currency
    var formattedShippingCost: String {
        if shippingCost == 0 {
            return "FREE"
        }
        return String(format: "$%.2f", shippingCost)
    }
}

// MARK: - Service Category Extensions
extension ServiceCategory {
    /// Maps service categories to product categories for filtering
    var relatedProductCategories: [ProductCategory] {
        switch self {
        case .photoVideo:
            return [.electronics, .art]
        case .hairStylist, .barber:
            return [.health]
        case .lashTech, .nailTech:
            return [.health]
        case .tutor:
            return [.books]
        case .foodDelivery:
            return [.food]
        case .cleaning:
            return [.home]
        case .eventPlanning:
            return [.other]
        case .other:
            return [.other]
        }
    }
}

// MARK: - Booking Utilities
extension Booking {
    /// Gets formatted deposit amount
    var formattedDepositAmount: String {
        if requiresDeposit {
            return String(format: "$%.2f", depositAmount)
        }
        return "$0.00"
    }
    
    /// Gets formatted remaining balance
    var formattedRemainingBalance: String {
        return String(format: "$%.2f", remainingBalance)
    }
    
    /// Gets formatted total price
    var formattedTotalPrice: String {
        return String(format: "$%.2f", totalPrice)
    }
    
    /// Checks if booking requires payment action
    var requiresPaymentAction: Bool {
        switch paymentStatus {
        case .pending:
            return true
        case .depositPaid:
            return !service.requiresDeposit // If no deposit required, need full payment
        case .fullyPaid, .refunded, .failed, .notRequired:
            return false
        }
    }
    
    /// Gets next payment action description
    var nextPaymentAction: String {
        switch paymentStatus {
        case .pending:
            return service.requiresDeposit ? "Pay Deposit" : "Pay Full Amount"
        case .depositPaid:
            return "Pay Remaining Balance"
        case .fullyPaid:
            return "Paid in Full"
        case .refunded:
            return "Refunded"
        case .failed:
            return "Payment Failed - Retry"
        case .notRequired:
            return "No Payment Required"
        }
    }
}

// MARK: - Platform Fee Configuration (NEW)
struct PlatformFeeConfig {
    static let serviceFeePercentage: Double = 5.0 // 5% platform fee
    static let stripeFeePercentage: Double = 2.9 // 2.9% Stripe fee
    static let stripeFeeFixed: Double = 0.30 // $0.30 Stripe fixed fee
    
    /// Calculates platform fee for a given amount
    static func calculatePlatformFee(for amount: Double) -> Double {
        return amount * (serviceFeePercentage / 100.0)
    }
    
    /// Calculates Stripe processing fee for a given amount
    static func calculateStripeFee(for amount: Double) -> Double {
        return (amount * (stripeFeePercentage / 100.0)) + stripeFeeFixed
    }
    
    /// Calculates total fees (platform + Stripe)
    static func calculateTotalFees(for amount: Double) -> Double {
        return calculatePlatformFee(for: amount) + calculateStripeFee(for: amount)
    }
    
    /// Calculates how much the business owner receives after fees
    static func calculateBusinessPayout(for amount: Double) -> Double {
        return amount - calculateTotalFees(for: amount)
    }
    
    /// Gets fee breakdown for display
    static func getFeeBreakdown(for amount: Double) -> (platformFee: Double, stripeFee: Double, businessPayout: Double) {
        let platformFee = calculatePlatformFee(for: amount)
        let stripeFee = calculateStripeFee(for: amount)
        let businessPayout = calculateBusinessPayout(for: amount)
        
        return (platformFee: platformFee, stripeFee: stripeFee, businessPayout: businessPayout)
    }
}
