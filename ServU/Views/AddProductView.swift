//
//  AddProductView.swift
//  ServU
//
//  Created by Amber Still on 7/31/25.
//


//
//  AddProductView.swift
//  ServU
//
//  Created by Quian Bowden on 7/31/25.
//

import SwiftUI

struct AddProductView: View {
    @ObservedObject var userProfile: UserProfile
    let onSave: (Product) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var productName = ""
    @State private var productDescription = ""
    @State private var selectedCategory: ProductCategory = .clothing
    @State private var basePrice: Double = 25.0
    @State private var hasVariants = false
    @State private var variants: [ProductVariant] = []
    @State private var inventory = 10
    @State private var trackInventory = true
    @State private var lowStockThreshold = 5
    @State private var productTags = ""
    @State private var showingAddVariant = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Product Details
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Product Details")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        
                        ProductFormCard(title: "Basic Information") {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Product Name *")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    TextField("e.g., Custom T-Shirt", text: $productName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Description *")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    TextEditor(text: $productDescription)
                                        .frame(minHeight: 80)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Category *")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Picker("Category", selection: $selectedCategory) {
                                        ForEach(ProductCategory.allCases, id: \.self) { category in
                                            HStack {
                                                Image(systemName: category.icon)
                                                    .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                                                Text(category.displayName)
                                            }
                                            .tag(category)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Tags (Optional)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    TextField("e.g., cotton, comfortable, unisex", text: $productTags)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Text("Separate tags with commas")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        ProductFormCard(title: "Pricing & Variants") {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Base Price *")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    HStack {
                                        Text("$")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        
                                        TextField("25.00", value: $basePrice, format: .number)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .keyboardType(.decimalPad)
                                    }
                                    
                                    if hasVariants {
                                        Text("This will be the default price. Variants can have different prices.")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Toggle("Has Variants (Size, Color, etc.)", isOn: $hasVariants)
                                    .toggleStyle(SwitchToggleStyle(tint: userProfile.college?.primaryColor ?? .blue))
                                
                                if hasVariants {
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack {
                                            Text("Product Variants")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            Spacer()
                                            
                                            Button("Add Variant") {
                                                showingAddVariant = true
                                            }
                                            .buttonStyle(ServUSecondaryButtonStyle(borderColor: userProfile.college?.primaryColor ?? .blue))
                                            .font(.caption)
                                        }
                                        
                                        if variants.isEmpty {
                                            VStack(spacing: 8) {
                                                Image(systemName: "tshirt")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.gray.opacity(0.5))
                                                
                                                Text("No variants added yet")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                
                                                Text("Add variants like different sizes or colors")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 20)
                                        } else {
                                            VStack(spacing: 12) {
                                                ForEach(variants) { variant in
                                                    ProductVariantRow(
                                                        variant: variant,
                                                        userProfile: userProfile,
                                                        onDelete: {
                                                            variants.removeAll { $0.id == variant.id }
                                                        }
                                                    )
                                                }
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6).opacity(0.5))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        ProductFormCard(title: "Inventory Management") {
                            VStack(alignment: .leading, spacing: 16) {
                                Toggle("Track Inventory", isOn: $trackInventory)
                                    .toggleStyle(SwitchToggleStyle(tint: userProfile.college?.primaryColor ?? .blue))
                                
                                if trackInventory && !hasVariants {
                                    VStack(alignment: .leading, spacing: 16) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Quantity Available")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            TextField("10", value: $inventory, format: .number)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                .keyboardType(.numberPad)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Low Stock Alert")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            TextField("5", value: $lowStockThreshold, format: .number)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                .keyboardType(.numberPad)
                                            
                                            Text("You'll be notified when stock reaches this level")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6).opacity(0.5))
                                    .cornerRadius(8)
                                } else if hasVariants {
                                    Text("Inventory will be tracked individually for each variant")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding()
                                        .background(Color(.systemGray6).opacity(0.5))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: saveProduct) {
                            Text("Add Product")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(userProfile.college?.primaryColor ?? .blue)
                                .cornerRadius(12)
                        }
                        .disabled(!canSaveProduct)
                        .opacity(canSaveProduct ? 1.0 : 0.6)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Add Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        userProfile.college?.colorScheme.background ?? Color(.systemGray6),
                        Color(.systemBackground)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
            .sheet(isPresented: $showingAddVariant) {
                AddVariantView(userProfile: userProfile) { newVariant in
                    variants.append(newVariant)
                }
            }
        }
    }
    
    private var canSaveProduct: Bool {
        let hasValidBasicInfo = !productName.isEmpty && 
                               !productDescription.isEmpty && 
                               basePrice > 0
        
        if hasVariants {
            return hasValidBasicInfo && !variants.isEmpty
        } else {
            return hasValidBasicInfo
        }
    }
    
    private func saveProduct() {
        let productInventory = ProductInventory(
            quantity: hasVariants ? variants.reduce(0) { $0 + $1.inventory.quantity } : inventory,
            lowStockThreshold: lowStockThreshold,
            trackInventory: trackInventory
        )
        
        let tags = productTags.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        let newProduct = Product(
            name: productName,
            description: productDescription,
            category: selectedCategory,
            basePrice: basePrice,
            images: [ProductImage(imageURL: "", isPrimary: true, altText: productName)],
            variants: hasVariants ? variants : [],
            inventory: productInventory,
            specifications: [],
            tags: tags
        )
        
        onSave(newProduct)
        HapticFeedback.success()
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Add Variant View
struct AddVariantView: View {
    @ObservedObject var userProfile: UserProfile
    let onSave: (ProductVariant) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var variantName = ""
    @State private var variantPrice: Double = 25.0
    @State private var variantSKU = ""
    @State private var variantQuantity = 10
    @State private var attributes: [VariantAttribute] = []
    @State private var showingAddAttribute = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Product Variant")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        
                        ProductFormCard(title: "Variant Details") {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Variant Name")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    TextField("e.g., Medium - Blue", text: $variantName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Text("This will be auto-generated from attributes if left empty")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Price *")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        HStack {
                                            Text("$")
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                            
                                            TextField("25.00", value: $variantPrice, format: .number)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                .keyboardType(.decimalPad)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Quantity *")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        TextField("10", value: $variantQuantity, format: .number)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .keyboardType(.numberPad)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("SKU (Optional)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    TextField("e.g., TSH-M-BLU", text: $variantSKU)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .autocapitalization(.allCharacters)
                                }
                            }
                        }
                        
                        ProductFormCard(title: "Attributes") {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Variant Attributes")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    Button("Add Attribute") {
                                        showingAddAttribute = true
                                    }
                                    .buttonStyle(ServUSecondaryButtonStyle(borderColor: userProfile.college?.primaryColor ?? .blue))
                                    .font(.caption)
                                }
                                
                                if attributes.isEmpty {
                                    VStack(spacing: 8) {
                                        Image(systemName: "tag")
                                            .font(.system(size: 30))
                                            .foregroundColor(.gray.opacity(0.5))
                                        
                                        Text("No attributes added")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Text("Add attributes like Size, Color, Material, etc.")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                } else {
                                    VStack(spacing: 12) {
                                        ForEach(attributes.sorted(by: { $0.displayOrder < $1.displayOrder })) { attribute in
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(attribute.name)
                                                        .font(.subheadline)
                                                        .fontWeight(.semibold)
                                                    
                                                    Text(attribute.value)
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                Spacer()
                                                
                                                Button(action: {
                                                    attributes.removeAll { $0.id == attribute.id }
                                                }) {
                                                    Image(systemName: "trash")
                                                        .font(.caption)
                                                        .foregroundColor(.red)
                                                }
                                            }
                                            .padding()
                                            .background(Color(.systemGray6).opacity(0.5))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: saveVariant) {
                            Text("Add Variant")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(userProfile.college?.primaryColor ?? .blue)
                                .cornerRadius(12)
                        }
                        .disabled(!canSaveVariant)
                        .opacity(canSaveVariant ? 1.0 : 0.6)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Add Variant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .sheet(isPresented: $showingAddAttribute) {
                AddAttributeView(userProfile: userProfile) { newAttribute in
                    attributes.append(newAttribute)
                }
            }
        }
    }
    
    private var canSaveVariant: Bool {
        return variantPrice > 0 && variantQuantity >= 0
    }
    
    private func saveVariant() {
        let finalVariantName = variantName.isEmpty ? 
            attributes.map { $0.value }.joined(separator: " - ") : 
            variantName
        
        let finalSKU = variantSKU.isEmpty ? 
            "VAR\(Int.random(in: 1000...9999))" : 
            variantSKU
        
        let newVariant = ProductVariant(
            name: finalVariantName,
            price: variantPrice,
            sku: finalSKU,
            attributes: attributes,
            inventory: ProductInventory(quantity: variantQuantity)
        )
        
        onSave(newVariant)
        HapticFeedback.success()
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Add Attribute View
struct AddAttributeView: View {
    @ObservedObject var userProfile: UserProfile
    let onSave: (VariantAttribute) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var attributeName = ""
    @State private var attributeValue = ""
    
    private let commonAttributes = ["Size", "Color", "Material", "Style", "Pattern"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Add Attribute")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Attribute Name")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        TextField("e.g., Size, Color", text: $attributeName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text("Common attributes:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(commonAttributes, id: \.self) { attribute in
                                    Button(attribute) {
                                        attributeName = attribute
                                    }
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray6))
                                    .foregroundColor(.primary)
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Value")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        TextField("e.g., Medium, Blue", text: $attributeValue)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: saveAttribute) {
                        Text("Add Attribute")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(userProfile.college?.primaryColor ?? .blue)
                            .cornerRadius(12)
                    }
                    .disabled(attributeName.isEmpty || attributeValue.isEmpty)
                    .opacity((attributeName.isEmpty || attributeValue.isEmpty) ? 0.6 : 1.0)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private func saveAttribute() {
        let newAttribute = VariantAttribute(
            name: attributeName,
            value: attributeValue,
            displayOrder: 0
        )
        
        onSave(newAttribute)
        HapticFeedback.success()
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Supporting Views

struct ProductFormCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            content
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .servUCardShadow()
    }
}

struct ProductVariantRow: View {
    let variant: ProductVariant
    @ObservedObject var userProfile: UserProfile
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(variant.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    Text("$\(String(format: "%.2f", variant.price))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text("Qty: \(variant.inventory.quantity)")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    if !variant.sku.isEmpty {
                        Text("SKU: \(variant.sku)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
}

struct ProductRowView: View {
    let product: Product
    @ObservedObject var userProfile: UserProfile
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(product.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    Text(product.displayPrice)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text(product.category.displayName)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    if product.totalInventory > 0 {
                        Text("Stock: \(product.totalInventory)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
}

#Preview {
    AddProductView(userProfile: UserProfile()) { _ in }
}