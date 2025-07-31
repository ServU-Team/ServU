//
//  ProductDetailView.swift
//  ServU
//
//  Created by Amber Still on 7/29/25.
//


//
//  ProductDetailView.swift
//  ServU
//
//  Created by Quian Bowden on 6/27/25.
//  Updated by Assistant on 7/29/25.
//  Fixed to use shared cart manager
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    let business: EnhancedBusiness
    @ObservedObject var userProfile: UserProfile
    @ObservedObject var cartManager: ShoppingCartManager // ✅ FIXED: Accept shared cart manager
    
    @State private var selectedVariant: ProductVariant?
    @State private var selectedQuantity: Int = 1
    @State private var selectedImageIndex: Int = 0
    @State private var showingCart = false
    @State private var showingAddedToCart = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Product Images
                    productImagesView
                    
                    // Product Info
                    productInfoView
                    
                    // Variant Selection
                    if !product.variants.isEmpty {
                        variantSelectionView
                    }
                    
                    // Quantity Selection
                    quantitySelectionView
                    
                    // Product Description
                    productDescriptionView
                    
                    // Shipping Information
                    shippingInfoView
                    
                    // Business Information
                    businessInfoView
                    
                    Spacer(minLength: 120) // Space for buttons
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
            .overlay(
                // Fixed bottom buttons
                bottomButtonsView,
                alignment: .bottom
            )
            .alert("Added to Cart!", isPresented: $showingAddedToCart) {
                Button("Continue Shopping", role: .cancel) { }
                Button("View Cart") {
                    showingCart = true
                }
            } message: {
                Text("\(product.name) has been added to your cart.")
            }
            .sheet(isPresented: $showingCart) {
                ProductCartView(cartManager: cartManager, userProfile: userProfile)
            }
        }
    }
    
    // MARK: - Product Images
    private var productImagesView: some View {
        VStack(spacing: 0) {
            // Back Button and Actions
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: { /* TODO: Add to wishlist */ }) {
                        Image(systemName: "heart")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Button(action: { showingCart = true }) {
                        ZStack {
                            Image(systemName: "bag")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                            
                            if cartManager.itemCount > 0 {
                                Text("\(cartManager.itemCount)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 18, height: 18)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 12, y: -12)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
            .zIndex(1)
            
            // Product Image
            ZStack {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color(.systemGray5), Color(.systemGray6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 400)
                
                // Placeholder product image
                VStack {
                    Image(systemName: product.category.icon)
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    
                    Text("Product Image")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                // Stock Status Badge
                VStack {
                    HStack {
                        Spacer()
                        stockStatusBadge
                            .padding(.trailing, 20)
                            .padding(.top, 20)
                    }
                    Spacer()
                }
            }
        }
        .clipped()
    }
    
    // MARK: - Product Info
    private var productInfoView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(business.name)
                        .font(.subheadline)
                        .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        .fontWeight(.medium)
                    
                    Text(currentPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            
            // Product Tags
            if !product.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(product.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(userProfile.college?.primaryColor.opacity(0.1) ?? Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Variant Selection
    private var variantSelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Options")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            let groupedAttributes = Dictionary(grouping: product.variants) { variant in
                variant.attributes.first?.name ?? "Option"
            }
            
            ForEach(Array(groupedAttributes.keys).sorted(), id: \.self) { attributeName in
                VStack(alignment: .leading, spacing: 8) {
                    Text(attributeName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(Set(groupedAttributes[attributeName]?.compactMap { variant in
                                variant.attributes.first { $0.name == attributeName }?.value
                            } ?? [])).sorted(), id: \.self) { value in
                                VariantOptionButton(
                                    title: value,
                                    isSelected: selectedVariant?.attributes.first { $0.name == attributeName }?.value == value,
                                    isAvailable: product.variants.contains { variant in
                                        variant.attributes.contains { $0.name == attributeName && $0.value == value } &&
                                        variant.inventory.quantity > 0
                                    },
                                    userProfile: userProfile
                                ) {
                                    selectVariantWith(attributeName: attributeName, value: value)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .background(Color(.systemGray6).opacity(0.5))
    }
    
    // MARK: - Quantity Selection
    private var quantitySelectionView: some View {
        HStack {
            Text("Quantity")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            HStack(spacing: 0) {
                Button(action: { 
                    if selectedQuantity > 1 { 
                        selectedQuantity -= 1 
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(Color(.systemGray5))
                }
                .disabled(selectedQuantity <= 1)
                
                Text("\(selectedQuantity)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(width: 60, height: 40)
                    .background(Color(.systemGray6))
                
                Button(action: { 
                    if selectedQuantity < maxQuantity { 
                        selectedQuantity += 1 
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(Color(.systemGray5))
                }
                .disabled(selectedQuantity >= maxQuantity)
            }
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Product Description
    private var productDescriptionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(product.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
            
            if !product.specifications.isEmpty {
                Text("Specifications")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(product.specifications) { spec in
                        HStack {
                            Text(spec.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(spec.value)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Shipping Info
    private var shippingInfoView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shipping Options")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(business.shippingOptions) { option in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(option.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(option.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(option.price == 0 ? "FREE" : String(format: "$%.2f", option.price))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(option.price == 0 ? .green : .primary)
                        
                        Text(option.estimatedDays)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Business Info
    private var businessInfoView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sold by")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                Circle()
                    .fill(userProfile.college?.primaryColor ?? .blue)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(business.name.prefix(1)))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(business.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            
                            Text(String(format: "%.1f", business.rating))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(business.totalSales) sales")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if business.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                Button("View Store") {
                    // TODO: Navigate to business profile
                }
                .font(.caption)
                .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(userProfile.college?.primaryColor.opacity(0.1) ?? Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemGray6).opacity(0.3))
    }
    
    // MARK: - Bottom Buttons
    private var bottomButtonsView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Add to Cart Button
                Button(action: addToCart) {
                    HStack {
                        Image(systemName: "bag.badge.plus")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Add to Cart")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .disabled(!canAddToCart)
                .opacity(canAddToCart ? 1.0 : 0.6)
                
                // Buy Now Button
                Button(action: buyNow) {
                    Text("Buy Now")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(userProfile.college?.primaryColor ?? .blue)
                        .cornerRadius(12)
                }
                .disabled(!canAddToCart)
                .opacity(canAddToCart ? 1.0 : 0.6)
            }
            
            // Total Price
            HStack {
                Text("Total:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(String(format: "$%.2f", totalPrice))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
    }
    
    // MARK: - Supporting Views
    private var stockStatusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: currentStockStatus.icon)
                .font(.caption2)
            
            Text(currentStockStatus.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundColor(currentStockStatus.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Computed Properties
    private var currentPrice: String {
        if let variant = selectedVariant {
            return String(format: "$%.2f", variant.price)
        }
        return product.displayPrice
    }
    
    private var totalPrice: Double {
        let unitPrice = selectedVariant?.price ?? product.basePrice
        return unitPrice * Double(selectedQuantity)
    }
    
    private var currentStockStatus: StockStatus {
        if let variant = selectedVariant {
            return variant.inventory.stockStatus
        }
        return product.inventory.stockStatus
    }
    
    private var maxQuantity: Int {
        let availableStock = selectedVariant?.inventory.quantity ?? product.totalInventory
        return min(availableStock, 10) // Cap at 10 items per order
    }
    
    private var canAddToCart: Bool {
        if product.variants.isEmpty {
            return product.isInStock && selectedQuantity > 0
        } else {
            return selectedVariant != nil && 
                   selectedVariant!.inventory.quantity >= selectedQuantity &&
                   selectedQuantity > 0
        }
    }
    
    // MARK: - Actions
    private func selectVariantWith(attributeName: String, value: String) {
        // Find variant that matches the selected attribute
        if let variant = product.variants.first(where: { variant in
            variant.attributes.contains { $0.name == attributeName && $0.value == value }
        }) {
            selectedVariant = variant
            selectedQuantity = 1 // Reset quantity when variant changes
        }
    }
    
    private func addToCart() {
        cartManager.addItem(product, variant: selectedVariant, quantity: selectedQuantity)
        showingAddedToCart = true
    }
    
    private func buyNow() {
        addToCart()
        showingCart = true
    }
}

// MARK: - Supporting Views

struct VariantOptionButton: View {
    let title: String
    let isSelected: Bool
    let isAvailable: Bool
    @ObservedObject var userProfile: UserProfile
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 2)
                )
                .cornerRadius(8)
        }
        .disabled(!isAvailable)
        .opacity(isAvailable ? 1.0 : 0.5)
    }
    
    private var textColor: Color {
        if !isAvailable { return .gray }
        if isSelected { return .white }
        return userProfile.college?.primaryColor ?? .blue
    }
    
    private var backgroundColor: Color {
        if !isAvailable { return Color(.systemGray6) }
        if isSelected { return userProfile.college?.primaryColor ?? .blue }
        return Color.clear
    }
    
    private var borderColor: Color {
        if !isAvailable { return .gray }
        return userProfile.college?.primaryColor ?? .blue
    }
}

// ✅ RENAMED: ProductCartView to avoid conflicts with MainCartView
struct ProductCartView: View {
    @ObservedObject var cartManager: ShoppingCartManager
    @ObservedObject var userProfile: UserProfile
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                if cartManager.items.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bag")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Your cart is empty")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Add some items to get started!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(cartManager.items) { item in
                            ProductCartItemRow(item: item, cartManager: cartManager)
                        }
                        .onDelete(perform: deleteItems)
                    }
                    
                    // Cart Summary
                    VStack(spacing: 12) {
                        HStack {
                            Text("Subtotal")
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "$%.2f", cartManager.subtotal))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        Button("Proceed to Checkout") {
                            // TODO: Implement checkout
                            presentationMode.wrappedValue.dismiss()
                        }
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(userProfile.college?.primaryColor ?? .blue)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("Cart (\(cartManager.itemCount))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            cartManager.removeItem(cartManager.items[index])
        }
    }
}

// ✅ RENAMED: ProductCartItemRow to avoid conflicts with MainCartItemRow
struct ProductCartItemRow: View {
    let item: CartItem
    @ObservedObject var cartManager: ShoppingCartManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image Placeholder
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                .overlay(
                    Image(systemName: item.product.category.icon)
                        .font(.title3)
                        .foregroundColor(.gray)
                )
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(String(format: "$%.2f each", item.unitPrice))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Quantity and Price
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 8) {
                    Button(action: { 
                        cartManager.updateQuantity(for: item, quantity: item.quantity - 1)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .disabled(item.quantity <= 1)
                    
                    Text("\(item.quantity)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(minWidth: 20)
                    
                    Button(action: { 
                        cartManager.updateQuantity(for: item, quantity: item.quantity + 1)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                Text(String(format: "$%.2f", item.totalPrice))
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let sampleProduct = Product(
        name: "Sample T-Shirt",
        description: "A comfortable cotton t-shirt",
        category: .clothing,
        basePrice: 25.0,
        images: [],
        variants: [],
        inventory: ProductInventory(quantity: 10),
        specifications: [],
        tags: ["cotton", "casual"]
    )
    
    let sampleBusiness = EnhancedBusiness(
        name: "Sample Store",
        businessType: .products,
        description: "Sample store",
        rating: 4.5,
        priceRange: .moderate,
        location: "Campus",
        contactInfo: ContactInfo(email: "test@test.com", phone: "555-0123"),
        ownerId: "sample",
        ownerName: "Sample Owner",
        availability: BusinessHours.defaultHours,
        shippingOptions: [.campusPickup]
    )
    
    return ProductDetailView(
        product: sampleProduct,
        business: sampleBusiness,
        userProfile: UserProfile(),
        cartManager: ShoppingCartManager()
    )
}