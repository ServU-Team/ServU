//
//  CartItem.swift
//  ServU
//
//  Created by Amber Still on 8/5/25.
//


//
//  CartItem.swift
//  ServU
//
//  Created by Quian Bowden on 8/5/25.
//

import Foundation
import SwiftUI

// MARK: - Cart Item (SINGLE DEFINITION)
struct CartItem: Identifiable, Codable {
    let id = UUID()
    var product: Product
    var selectedVariant: ProductVariant?
    var quantity: Int
    var addedDate: Date
    var businessId: String?
    
    enum CodingKeys: String, CodingKey {
        case product, selectedVariant, quantity, addedDate, businessId
    }
    
    init(product: Product, selectedVariant: ProductVariant? = nil, quantity: Int, businessId: String? = nil) {
        self.product = product
        self.selectedVariant = selectedVariant
        self.quantity = quantity
        self.addedDate = Date()
        self.businessId = businessId
    }
    
    // MARK: - Computed Properties
    var unitPrice: Double {
        return selectedVariant?.price ?? product.basePrice
    }
    
    var totalPrice: Double {
        return unitPrice * Double(quantity)
    }
    
    var displayName: String {
        if let variant = selectedVariant {
            return "\(product.name) - \(variant.displayName)"
        } else {
            return product.name
        }
    }
    
    var isInStock: Bool {
        if let variant = selectedVariant {
            return variant.isInStock && variant.inventory.quantity >= quantity
        } else {
            return product.isInStock && product.inventory.quantity >= quantity
        }
    }
    
    var availableQuantity: Int {
        if let variant = selectedVariant {
            return variant.inventory.availableQuantity
        } else {
            return product.inventory.availableQuantity
        }
    }
    
    var stockStatus: StockStatus {
        if let variant = selectedVariant {
            return variant.inventory.stockStatus
        } else {
            return product.inventory.stockStatus
        }
    }
    
    var formattedTotalPrice: String {
        return String(format: "$%.2f", totalPrice)
    }
    
    var canIncreaseQuantity: Bool {
        return quantity < availableQuantity
    }
}

// MARK: - Shopping Cart Manager (SINGLE SOURCE OF TRUTH)
class ShoppingCartManager: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var selectedShippingOption: ShippingOption = .campusPickup
    @Published var appliedPromoCode: String?
    @Published var promoDiscount: Double = 0.0
    
    // MARK: - Computed Properties
    var itemCount: Int {
        return items.reduce(0) { $0 + $1.quantity }
    }
    
    var uniqueItemCount: Int {
        return items.count
    }
    
    var subtotal: Double {
        return items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var shippingCost: Double {
        if subtotal >= 50 && selectedShippingOption != .expressShipping {
            return 0.0 // Free shipping over $50
        }
        return selectedShippingOption.cost
    }
    
    var tax: Double {
        return subtotal * 0.08 // 8% tax rate
    }
    
    var discount: Double {
        return promoDiscount
    }
    
    var total: Double {
        return subtotal + shippingCost + tax - discount
    }
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    // MARK: - Formatted Strings
    var formattedSubtotal: String {
        return String(format: "$%.2f", subtotal)
    }
    
    var formattedShippingCost: String {
        if shippingCost == 0 {
            return "FREE"
        }
        return String(format: "$%.2f", shippingCost)
    }
    
    var formattedTax: String {
        return String(format: "$%.2f", tax)
    }
    
    var formattedDiscount: String {
        return String(format: "-$%.2f", discount)
    }
    
    var formattedTotal: String {
        return String(format: "$%.2f", total)
    }
    
    // MARK: - Cart Operations
    func addItem(_ product: Product, variant: ProductVariant? = nil, quantity: Int = 1, businessId: String? = nil) {
        // Check if item already exists
        if let existingIndex = items.firstIndex(where: { item in
            item.product.id == product.id && item.selectedVariant?.id == variant?.id
        }) {
            // Update quantity of existing item
            items[existingIndex].quantity += quantity
        } else {
            // Add new item
            let newItem = CartItem(
                product: product,
                selectedVariant: variant,
                quantity: quantity,
                businessId: businessId
            )
            items.append(newItem)
        }
        
        objectWillChange.send()
    }
    
    func removeItem(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
        objectWillChange.send()
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if quantity <= 0 {
                items.remove(at: index)
            } else {
                items[index].quantity = min(quantity, item.availableQuantity)
            }
            objectWillChange.send()
        }
    }
    
    func clearCart() {
        items.removeAll()
        appliedPromoCode = nil
        promoDiscount = 0.0
        objectWillChange.send()
    }
    
    func getItem(for product: Product, variant: ProductVariant? = nil) -> CartItem? {
        return items.first { item in
            item.product.id == product.id && item.selectedVariant?.id == variant?.id
        }
    }
    
    func isInCart(_ product: Product, variant: ProductVariant? = nil) -> Bool {
        return getItem(for: product, variant: variant) != nil
    }
    
    func getQuantity(for product: Product, variant: ProductVariant? = nil) -> Int {
        return getItem(for: product, variant: variant)?.quantity ?? 0
    }
    
    // MARK: - Business Grouping
    func getItemsForBusiness(businessId: String) -> [CartItem] {
        return items.filter { item in
            item.businessId == businessId
        }
    }
    
    var groupedByBusiness: [String: [CartItem]] {
        return Dictionary(grouping: items) { item in
            item.businessId ?? "unknown"
        }
    }
    
    var hasMultipleBusinesses: Bool {
        let businessIds = Set(items.compactMap { $0.businessId })
        return businessIds.count > 1
    }
    
    // MARK: - Validation
    func validateCart() -> [String] {
        var errors: [String] = []
        
        for item in items {
            if !item.isInStock {
                errors.append("\(item.displayName) is no longer in stock")
            }
            
            if item.quantity > item.availableQuantity {
                errors.append("\(item.displayName) only has \(item.availableQuantity) available")
            }
        }
        
        return errors
    }
    
    var isValid: Bool {
        return validateCart().isEmpty
    }
}