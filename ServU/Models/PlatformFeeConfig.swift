//
//  PlatformFeeConfig.swift
//  ServU
//
//  Created by Amber Still on 8/5/25.
//


//
//  BusinessConversionUtilities.swift
//  ServU
//
//  Created by Quian Bowden on 6/27/25.
//  Updated by Quian Bowden on 8/4/25.
//  Fixed all scope and conversion issues
//

import Foundation
import SwiftUI

// MARK: - Business Model Conversion Utilities
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
            services: self.services.map { $0.toServUService() },
            availability: self.availability,
            products: [],
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
            services: self.services.map { $0.toLegacyService() },
            availability: self.availability
        )
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
            item.businessId == business.id.uuidString
        }
    }
    
    /// Gets total number of unique products in cart
    var uniqueProductCount: Int {
        return items.count
    }
    
    /// Removes all items of a specific product
    func removeAllItems(for product: Product) {
        items.removeAll { $0.product.id == product.id }
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

// MARK: - Platform Fee Configuration
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