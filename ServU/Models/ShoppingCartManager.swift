//
//  ShoppingCartManager.swift
//  ServU
//
//  Created by Amber Still on 8/9/25.
//


//
//  ShoppingCartManager.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  Cart functionality for products and services
//

import SwiftUI
import Foundation

class ShoppingCartManager: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var isLoading = false
    @Published var showingCart = false
    
    // MARK: - Cart Management
    
    /// Add item to cart or update quantity if already exists
    func addItem(_ product: Product, from business: EnhancedBusiness, quantity: Int = 1) {
        if let existingIndex = items.firstIndex(where: { 
            $0.product.id == product.id && $0.businessId == business.id.uuidString 
        }) {
            // Update existing item quantity
            items[existingIndex].quantity += quantity
        } else {
            // Add new item to cart
            let cartItem = CartItem(
                id: UUID(),
                product: product,
                businessId: business.id.uuidString,
                businessName: business.name,
                quantity: quantity,
                addedAt: Date()
            )
            items.append(cartItem)
        }
        
        // Provide haptic feedback
        HapticFeedback.light()
    }
    
    /// Remove item from cart completely
    func removeItem(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
        HapticFeedback.light()
    }
    
    /// Update quantity of specific item
    func updateQuantity(for item: CartItem, to quantity: Int) {
        if quantity <= 0 {
            removeItem(item)
            return
        }
        
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].quantity = quantity
        }
    }
    
    /// Clear all items from cart
    func clearCart() {
        items.removeAll()
        HapticFeedback.medium()
    }
    
    /// Clear items from specific business
    func clearItems(from businessId: String) {
        items.removeAll { $0.businessId == businessId }
    }
    
    // MARK: - Cart Calculations
    
    /// Total number of items in cart
    var totalItemCount: Int {
        return items.reduce(0) { $0 + $1.quantity }
    }
    
    /// Total number of unique products
    var uniqueProductCount: Int {
        return items.count
    }
    
    /// Total price of all items in cart
    var totalPrice: Double {
        return items.reduce(0) { total, item in
            total + (item.product.price * Double(item.quantity))
        }
    }
    
    /// Total price formatted as currency
    var totalPriceFormatted: String {
        return String(format: "$%.2f", totalPrice)
    }
    
    /// Get subtotal for specific business
    func getSubtotal(for businessId: String) -> Double {
        return items
            .filter { $0.businessId == businessId }
            .reduce(0) { total, item in
                total + (item.product.price * Double(item.quantity))
            }
    }
    
    /// Check if cart is empty
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    /// Check if cart has items from multiple businesses
    var hasMultipleBusinesses: Bool {
        let businessIds = Set(items.map { $0.businessId })
        return businessIds.count > 1
    }
    
    /// Get unique business IDs in cart
    var businessesInCart: Set<String> {
        return Set(items.map { $0.businessId })
    }
    
    // MARK: - Business-Specific Methods
    
    /// Get items from specific business
    func getItems(for businessId: String) -> [CartItem] {
        return items.filter { $0.businessId == businessId }
    }
    
    /// Get all businesses represented in cart
    func getBusinessNames() -> [String] {
        let uniqueBusinessNames = Set(items.map { $0.businessName })
        return Array(uniqueBusinessNames).sorted()
    }
    
    /// Check if product is already in cart
    func isInCart(_ product: Product, from businessId: String) -> Bool {
        return items.contains { 
            $0.product.id == product.id && $0.businessId == businessId 
        }
    }
    
    /// Get quantity of specific product in cart
    func getQuantity(for product: Product, from businessId: String) -> Int {
        return items.first { 
            $0.product.id == product.id && $0.businessId == businessId 
        }?.quantity ?? 0
    }
    
    // MARK: - Checkout Preparation
    
    /// Prepare cart items for checkout
    func prepareForCheckout() -> [CheckoutGroup] {
        let groupedItems = Dictionary(grouping: items) { $0.businessId }
        
        return groupedItems.map { businessId, items in
            CheckoutGroup(
                businessId: businessId,
                businessName: items.first?.businessName ?? "Unknown Business",
                items: items,
                subtotal: getSubtotal(for: businessId)
            )
        }.sorted { $0.businessName < $1.businessName }
    }
    
    // MARK: - Cart Persistence (for future implementation)
    
    /// Save cart to local storage
    func saveCart() {
        // TODO: Implement cart persistence
        // Could save to UserDefaults or Core Data
    }
    
    /// Load cart from local storage
    func loadCart() {
        // TODO: Implement cart loading
        // Could load from UserDefaults or Core Data
    }
    
    // MARK: - Cart Analytics
    
    /// Get most recent item added
    var mostRecentItem: CartItem? {
        return items.max { $0.addedAt < $1.addedAt }
    }
    
    /// Get items added in last session
    func getRecentItems(within timeInterval: TimeInterval = 3600) -> [CartItem] {
        let cutoffDate = Date().addingTimeInterval(-timeInterval)
        return items.filter { $0.addedAt > cutoffDate }
    }
}

// MARK: - Cart Item Model
struct CartItem: Identifiable, Codable {
    let id: UUID
    let product: Product
    let businessId: String
    let businessName: String
    var quantity: Int
    let addedAt: Date
    
    /// Total price for this cart item
    var totalPrice: Double {
        return product.price * Double(quantity)
    }
    
    /// Total price formatted as currency
    var totalPriceFormatted: String {
        return String(format: "$%.2f", totalPrice)
    }
}

// MARK: - Checkout Group Model
struct CheckoutGroup: Identifiable {
    let id = UUID()
    let businessId: String
    let businessName: String
    let items: [CartItem]
    let subtotal: Double
    
    var subtotalFormatted: String {
        return String(format: "$%.2f", subtotal)
    }
    
    var itemCount: Int {
        return items.reduce(0) { $0 + $1.quantity }
    }
}

// MARK: - Cart Extensions
extension ShoppingCartManager {
    /// Quick add with haptic feedback and animation
    func quickAdd(_ product: Product, from business: EnhancedBusiness) {
        addItem(product, from: business, quantity: 1)
        
        // Show brief success indicator
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            showingCart = true
        }
        
        // Auto-hide after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                showingCart = false
            }
        }
    }
    
    /// Increment quantity with validation
    func incrementQuantity(for item: CartItem, maxQuantity: Int = 99) {
        let newQuantity = min(item.quantity + 1, maxQuantity)
        updateQuantity(for: item, to: newQuantity)
    }
    
    /// Decrement quantity with validation
    func decrementQuantity(for item: CartItem) {
        let newQuantity = max(item.quantity - 1, 0)
        updateQuantity(for: item, to: newQuantity)
    }
}