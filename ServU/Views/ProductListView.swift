//
//  ProductListView.swift
//  ServU
//
//  Created by Amber Still on 7/30/25.
//


//
//  ProductListView.swift
//  ServU
//
//  Created by Quian Bowden on 6/27/25.
//  Updated by Assistant on 7/29/25.
//  Fixed Preview to include cartManager parameter
//

import SwiftUI

struct ProductListView: View {
    let business: EnhancedBusiness
    @ObservedObject var userProfile: UserProfile
    @ObservedObject var cartManager: ShoppingCartManager // ✅ Shared cart manager
    
    @State private var selectedCategory: ProductCategory? = nil
    @State private var showingCart = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Business Header
                businessHeaderView
                
                // Category Filter
                if business.productCategories.count > 1 {
                    categoryFilterView
                }
                
                // Products Grid
                productsGridView
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCart = true }) {
                        ZStack {
                            Image(systemName: "bag")
                                .font(.system(size: 20))
                            
                            if cartManager.itemCount > 0 {
                                Text("\(cartManager.itemCount)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 18, height: 18)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCart) {
                // Use ProductCartView instead of CartView
                ProductCartView(cartManager: cartManager, userProfile: userProfile)
            }
        }
    }
    
    // MARK: - Business Header
    private var businessHeaderView: some View {
        VStack(spacing: 16) {
            // Back Button
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Business Info
            VStack(spacing: 12) {
                // Business Logo/Icon
                Circle()
                    .fill(userProfile.college?.primaryColor ?? .blue)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(String(business.name.prefix(2)))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(spacing: 6) {
                    Text(business.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(business.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 20)
                    
                    HStack(spacing: 16) {
                        // Rating
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", business.rating))
                                .fontWeight(.semibold)
                            Text("(\(business.totalSales) sales)")
                                .foregroundColor(.secondary)
                        }
                        .font(.subheadline)
                        
                        // Verification Badge
                        if business.isVerified {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.blue)
                                Text("Verified")
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                            .font(.caption)
                        }
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color(.systemGray6).opacity(0.3))
    }
    
    // MARK: - Category Filter
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All Products
                CategoryFilterButton(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    userProfile: userProfile
                ) {
                    selectedCategory = nil
                }
                
                // Individual Categories
                ForEach(business.productCategories, id: \.self) { category in
                    CategoryFilterButton(
                        title: category.displayName,
                        isSelected: selectedCategory == category,
                        userProfile: userProfile
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Products Grid
    private var productsGridView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(filteredProducts) { product in
                    ProductCard(
                        product: product,
                        business: business,
                        userProfile: userProfile,
                        cartManager: cartManager
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100) // Space for tab bar
        }
    }
    
    // MARK: - Computed Properties
    private var filteredProducts: [Product] {
        if let selectedCategory = selectedCategory {
            return business.products.filter { $0.category == selectedCategory }
        }
        return business.products
    }
}

// MARK: - Category Filter Button
struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    @ObservedObject var userProfile: UserProfile
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : (userProfile.college?.primaryColor ?? .blue))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? (userProfile.college?.primaryColor ?? .blue) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(userProfile.college?.primaryColor ?? .blue, lineWidth: 2)
                )
                .cornerRadius(20)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: Product
    let business: EnhancedBusiness
    @ObservedObject var userProfile: UserProfile
    @ObservedObject var cartManager: ShoppingCartManager
    
    @State private var showingProductDetail = false
    
    var body: some View {
        Button(action: { showingProductDetail = true }) {
            VStack(alignment: .leading, spacing: 12) {
                // Product Image
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color(.systemGray5), Color(.systemGray6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 160)
                    .cornerRadius(12)
                    .overlay(
                        VStack {
                            Image(systemName: product.category.icon)
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text("Product Image")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
                    .overlay(
                        // Stock Status Badge
                        VStack {
                            HStack {
                                Spacer()
                                stockStatusBadge
                                    .padding(.trailing, 8)
                                    .padding(.top, 8)
                            }
                            Spacer()
                        }
                    )
                
                // Product Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(product.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(product.displayPrice)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                    
                    if !product.tags.isEmpty {
                        HStack {
                            ForEach(Array(product.tags.prefix(2)), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(4)
                            }
                            
                            if product.tags.count > 2 {
                                Text("+\(product.tags.count - 2)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Quick Add Button
                Button(action: quickAddToCart) {
                    HStack {
                        Image(systemName: "bag.badge.plus")
                            .font(.system(size: 14))
                        Text("Quick Add")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(userProfile.college?.primaryColor ?? .blue)
                    .cornerRadius(8)
                }
                .disabled(!product.isInStock)
                .opacity(product.isInStock ? 1.0 : 0.6)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .sheet(isPresented: $showingProductDetail) {
            ProductDetailView(
                product: product,
                business: business,
                userProfile: userProfile,
                cartManager: cartManager
            )
        }
    }
    
    private var stockStatusBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: product.inventory.stockStatus.icon)
                .font(.caption2)
            
            Text(product.inventory.stockStatus.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundColor(product.inventory.stockStatus.color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func quickAddToCart() {
        if product.variants.isEmpty {
            cartManager.addItem(product, variant: nil, quantity: 1)
        } else {
            // For products with variants, open detail view
            showingProductDetail = true
        }
    }
}

// ✅ FIXED: Added cartManager parameter to Preview
#Preview {
    let sampleProducts = [
        Product(
            name: "Sample Hoodie",
            description: "A comfortable hoodie",
            category: .clothing,
            basePrice: 45.0,
            images: [],
            variants: [],
            inventory: ProductInventory(quantity: 10),
            specifications: [],
            tags: ["hoodie", "comfortable"]
        ),
        Product(
            name: "Sample T-Shirt",
            description: "A cool t-shirt",
            category: .clothing,
            basePrice: 25.0,
            images: [],
            variants: [],
            inventory: ProductInventory(quantity: 5),
            specifications: [],
            tags: ["t-shirt", "cool"]
        )
    ]
    
    let sampleBusiness = EnhancedBusiness(
        name: "Sample Store",
        businessType: .products,
        description: "A sample clothing store",
        rating: 4.8,
        priceRange: .moderate,
        location: "Campus",
        contactInfo: ContactInfo(email: "test@test.com", phone: "555-0123"),
        ownerId: "sample",
        ownerName: "Sample Owner",
        availability: BusinessHours.defaultHours,
        products: sampleProducts,
        productCategories: [.clothing],
        shippingOptions: [.campusPickup]
    )
    
    return ProductListView(
        business: sampleBusiness,
        userProfile: UserProfile(),
        cartManager: ShoppingCartManager() // ✅ FIXED: Added missing cartManager
    )
}