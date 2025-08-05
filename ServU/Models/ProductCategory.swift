//
//  ProductCategory.swift
//  ServU
//
//  Created by Amber Still on 8/5/25.
//


//
//  ProductCategory.swift
//  ServU
//
//  Created by Quian Bowden on 8/4/25.
//

import Foundation
import SwiftUI

// MARK: - Product Category
enum ProductCategory: String, CaseIterable, Identifiable, Codable {
    case clothing = "CLOTHING"
    case electronics = "ELECTRONICS"
    case books = "BOOKS"
    case food = "FOOD"
    case health = "HEALTH"
    case art = "ART"
    case sports = "SPORTS"
    case beauty = "BEAUTY"
    case home = "HOME"
    case other = "OTHER"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .clothing: return "Clothing"
        case .electronics: return "Electronics"
        case .books: return "Books"
        case .food: return "Food & Beverages"
        case .health: return "Health & Wellness"
        case .art: return "Art & Crafts"
        case .sports: return "Sports & Recreation"
        case .beauty: return "Beauty"
        case .home: return "Home & Garden"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .clothing: return "tshirt.fill"
        case .electronics: return "laptopcomputer"
        case .books: return "book.fill"
        case .food: return "fork.knife"
        case .health: return "heart.fill"
        case .art: return "paintbrush.fill"
        case .sports: return "figure.run"
        case .beauty: return "sparkles"
        case .home: return "house.fill"
        case .other: return "bag.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .clothing: return .purple
        case .electronics: return .blue
        case .books: return .brown
        case .food: return .orange
        case .health: return .green
        case .art: return .pink
        case .sports: return .red
        case .beauty: return .cyan
        case .home: return .indigo
        case .other: return .gray
        }
    }
}

// MARK: - Stock Status
enum StockStatus: String, CaseIterable, Codable {
    case inStock = "In Stock"
    case lowStock = "Low Stock"
    case outOfStock = "Out of Stock"
    case preOrder = "Pre-Order"
    case discontinued = "Discontinued"
    
    var icon: String {
        switch self {
        case .inStock: return "checkmark.circle.fill"
        case .lowStock: return "exclamationmark.triangle.fill"
        case .outOfStock: return "xmark.circle.fill"
        case .preOrder: return "clock.fill"
        case .discontinued: return "minus.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .inStock: return .green
        case .lowStock: return .orange
        case .outOfStock: return .red
        case .preOrder: return .blue
        case .discontinued: return .gray
        }
    }
}

// MARK: - Product Inventory
struct ProductInventory: Codable, Identifiable {
    let id = UUID()
    var quantity: Int
    var lowStockThreshold: Int
    var trackInventory: Bool
    var reservedQuantity: Int
    var lastRestocked: Date?
    
    enum CodingKeys: String, CodingKey {
        case quantity, lowStockThreshold, trackInventory, reservedQuantity, lastRestocked
    }
    
    init(quantity: Int, lowStockThreshold: Int = 5, trackInventory: Bool = true, reservedQuantity: Int = 0, lastRestocked: Date? = nil) {
        self.quantity = quantity
        self.lowStockThreshold = lowStockThreshold
        self.trackInventory = trackInventory
        self.reservedQuantity = reservedQuantity
        self.lastRestocked = lastRestocked
    }
    
    var availableQuantity: Int {
        return max(0, quantity - reservedQuantity)
    }
    
    var stockStatus: StockStatus {
        if !trackInventory { return .inStock }
        if quantity <= 0 { return .outOfStock }
        if quantity <= lowStockThreshold { return .lowStock }
        return .inStock
    }
    
    var isInStock: Bool {
        return stockStatus == .inStock || stockStatus == .lowStock
    }
}

// MARK: - Product Image
struct ProductImage: Codable, Identifiable {
    let id = UUID()
    var imageURL: String
    var isPrimary: Bool
    var altText: String
    var displayOrder: Int
    
    enum CodingKeys: String, CodingKey {
        case imageURL, isPrimary, altText, displayOrder
    }
    
    init(imageURL: String, isPrimary: Bool = false, altText: String, displayOrder: Int = 0) {
        self.imageURL = imageURL
        self.isPrimary = isPrimary
        self.altText = altText
        self.displayOrder = displayOrder
    }
}

// MARK: - Product Specification
struct ProductSpecification: Codable, Identifiable {
    let id = UUID()
    var name: String
    var value: String
    var displayOrder: Int
    
    enum CodingKeys: String, CodingKey {
        case name, value, displayOrder
    }
    
    init(name: String, value: String, displayOrder: Int = 0) {
        self.name = name
        self.value = value
        self.displayOrder = displayOrder
    }
}

// MARK: - Variant Attribute
struct VariantAttribute: Codable, Identifiable {
    let id = UUID()
    var name: String
    var value: String
    var displayOrder: Int
    
    enum CodingKeys: String, CodingKey {
        case name, value, displayOrder
    }
    
    init(name: String, value: String, displayOrder: Int = 0) {
        self.name = name
        self.value = value
        self.displayOrder = displayOrder
    }
}

// MARK: - Product Variant
struct ProductVariant: Codable, Identifiable {
    let id = UUID()
    var name: String
    var price: Double
    var sku: String
    var attributes: [VariantAttribute]
    var inventory: ProductInventory
    var isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, price, sku, attributes, inventory, isActive
    }
    
    init(name: String, price: Double, sku: String, attributes: [VariantAttribute], inventory: ProductInventory, isActive: Bool = true) {
        self.name = name
        self.price = price
        self.sku = sku
        self.attributes = attributes
        self.inventory = inventory
        self.isActive = isActive
    }
    
    var displayName: String {
        let attributeValues = attributes.map { $0.value }.joined(separator: ", ")
        return attributeValues.isEmpty ? name : "\(name) - \(attributeValues)"
    }
    
    var isInStock: Bool {
        return inventory.isInStock && isActive
    }
}

// MARK: - Product
struct Product: Codable, Identifiable {
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
    var isActive: Bool
    var createdDate: Date
    var lastModified: Date
    
    enum CodingKeys: String, CodingKey {
        case name, description, category, basePrice, images, variants
        case inventory, specifications, tags, isActive, createdDate, lastModified
    }
    
    init(name: String, description: String, category: ProductCategory, basePrice: Double, images: [ProductImage] = [], variants: [ProductVariant] = [], inventory: ProductInventory, specifications: [ProductSpecification] = [], tags: [String] = [], isActive: Bool = true) {
        self.name = name
        self.description = description
        self.category = category
        self.basePrice = basePrice
        self.images = images
        self.variants = variants
        self.inventory = inventory
        self.specifications = specifications
        self.tags = tags
        self.isActive = isActive
        self.createdDate = Date()
        self.lastModified = Date()
    }
    
    // MARK: - Computed Properties
    var primaryImage: ProductImage? {
        return images.first { $0.isPrimary } ?? images.first
    }
    
    var isInStock: Bool {
        if variants.isEmpty {
            return inventory.isInStock && isActive
        } else {
            return variants.contains { $0.isInStock } && isActive
        }
    }
    
    var totalInventory: Int {
        if variants.isEmpty {
            return inventory.quantity
        } else {
            return variants.reduce(0) { $0 + $1.inventory.quantity }
        }
    }
    
    var minPrice: Double {
        if variants.isEmpty {
            return basePrice
        } else {
            return variants.map { $0.price }.min() ?? basePrice
        }
    }
    
    var maxPrice: Double {
        if variants.isEmpty {
            return basePrice
        } else {
            return variants.map { $0.price }.max() ?? basePrice
        }
    }
    
    var priceRange: String {
        if variants.isEmpty {
            return String(format: "$%.2f", basePrice)
        } else {
            let min = minPrice
            let max = maxPrice
            if min == max {
                return String(format: "$%.2f", min)
            } else {
                return String(format: "$%.2f - $%.2f", min, max)
            }
        }
    }
    
    var stockStatus: StockStatus {
        if variants.isEmpty {
            return inventory.stockStatus
        } else {
            let inStockVariants = variants.filter { $0.isInStock }
            if inStockVariants.isEmpty {
                return .outOfStock
            } else if inStockVariants.count < variants.count {
                return .lowStock
            } else {
                return .inStock
            }
        }
    }
}