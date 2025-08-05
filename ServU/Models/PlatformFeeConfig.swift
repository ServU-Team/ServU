//
//  PlatformFeeConfig.swift
//  ServU
//
//  Created by Amber Still on 8/5/25.
//


//
//  PlatformFeeConfig.swift
//  ServU
//
//  Created by Quian Bowden on 8/5/25.
//

import Foundation
import SwiftUI

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

// MARK: - Utility Extensions
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