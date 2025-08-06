//
//  AddServiceView.swift
//  ServU
//
//  Created by Amber Still on 8/6/25.
//


//
//  MissingViews.swift
//  ServU
//
//  Created by Quian Bowden on 8/5/25.
//  Missing views to fix compilation errors
//

import SwiftUI

// MARK: - Add Service View
struct AddServiceView: View {
    @ObservedObject var userProfile: UserProfile
    let onServiceAdded: (Service) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var serviceName = ""
    @State private var serviceDescription = ""
    @State private var servicePrice = ""
    @State private var serviceDuration = ""
    @State private var requiresDeposit = false
    @State private var depositAmount = ""
    @State private var depositType: DepositType = .fixed
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Service Details")) {
                    TextField("Service Name", text: $serviceName)
                    TextField("Description", text: $serviceDescription, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Price ($)", text: $servicePrice)
                        .keyboardType(.decimalPad)
                    TextField("Duration (e.g., 1 hour)", text: $serviceDuration)
                }
                
                Section(header: Text("Deposit Settings")) {
                    Toggle("Requires Deposit", isOn: $requiresDeposit)
                    
                    if requiresDeposit {
                        Picker("Deposit Type", selection: $depositType) {
                            ForEach(DepositType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        
                        TextField(depositType == .fixed ? "Deposit Amount ($)" : "Deposit Percentage (%)", text: $depositAmount)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle("Add Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveService()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        return !serviceName.isEmpty && 
               !serviceDescription.isEmpty && 
               !servicePrice.isEmpty && 
               !serviceDuration.isEmpty &&
               Double(servicePrice) != nil
    }
    
    private func saveService() {
        guard let price = Double(servicePrice) else { return }
        
        let deposit = requiresDeposit ? (Double(depositAmount) ?? 0.0) : 0.0
        
        let service = Service(
            name: serviceName,
            description: serviceDescription,
            price: price,
            duration: serviceDuration,
            requiresDeposit: requiresDeposit,
            depositAmount: deposit,
            depositType: depositType
        )
        
        onServiceAdded(service)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Add Product View
struct AddProductView: View {
    @ObservedObject var userProfile: UserProfile
    let onProductAdded: (Product) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var productName = ""
    @State private var productDescription = ""
    @State private var productPrice = ""
    @State private var selectedCategory: ProductCategory = .clothing
    @State private var inventory = 10
    @State private var tags = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Details")) {
                    TextField("Product Name", text: $productName)
                    TextField("Description", text: $productDescription, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ProductCategory.allCases) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                    
                    TextField("Price ($)", text: $productPrice)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Inventory & Tags")) {
                    Stepper("Quantity: \(inventory)", value: $inventory, in: 0...1000)
                    
                    TextField("Tags (comma separated)", text: $tags)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("Add Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProduct()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        return !productName.isEmpty && 
               !productDescription.isEmpty && 
               !productPrice.isEmpty && 
               Double(productPrice) != nil
    }
    
    private func saveProduct() {
        guard let price = Double(productPrice) else { return }
        
        let productTags = tags.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        
        let product = Product(
            name: productName,
            description: productDescription,
            category: selectedCategory,
            basePrice: price,
            inventory: ProductInventory(quantity: inventory),
            tags: productTags
        )
        
        onProductAdded(product)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Service Row View
struct ServiceRowView: View {
    let service: Service
    @ObservedObject var userProfile: UserProfile
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(service.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(String(format: "$%.2f", service.price))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(userProfile.college?.primaryColor ?? .blue)
            }
            
            Text(service.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Label(service.duration, systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if service.requiresDeposit {
                    Label("Deposit Required", systemImage: "creditcard")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                Button("Edit", action: onEdit)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Button("Delete", action: onDelete)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(12)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - Product Row View
struct ProductRowView: View {
    let product: Product
    @ObservedObject var userProfile: UserProfile
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(product.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(product.displayPrice)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(userProfile.college?.primaryColor ?? .blue)
            }
            
            Text(product.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Label(product.category.displayName, systemImage: product.category.icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(product.totalInventory) in stock", systemImage: "cube.box")
                    .font(.caption)
                    .foregroundColor(product.isInStock ? .green : .red)
                
                Spacer()
                
                Button("Edit", action: onEdit)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Button("Delete", action: onDelete)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(12)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - Terms and Conditions Popup
struct TermsAndConditionsPopup: View {
    @ObservedObject var userProfile: UserProfile
    @Binding var isPresented: Bool
    @Binding var hasAccepted: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Business Registration Terms")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("By registering a business on ServU, you agree to:")
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Provide accurate information about your services/products")
                            Text("• Maintain professional standards in all interactions")
                            Text("• Honor all bookings and transactions")
                            Text("• Pay platform fees as outlined")
                            Text("• Follow university guidelines and policies")
                            Text("• Maintain appropriate licenses if required")
                        }
                        
                        Text("Platform Fees:")
                            .fontWeight(.semibold)
                            .padding(.top)
                        
                        Text("ServU charges \(PlatformFeeConfig.serviceFeePercentage, specifier: "%.1f")% platform fee plus Stripe processing fees (\(PlatformFeeConfig.stripeFeePercentage, specifier: "%.1f")% + $\(PlatformFeeConfig.stripeFeeFixed, specifier: "%.2f")) on all transactions.")
                    }
                    .font(.subheadline)
                }
                .frame(maxHeight: 300)
                
                HStack(spacing: 16) {
                    Button("Decline") {
                        isPresented = false
                        hasAccepted = false
                    }
                    .buttonStyle(ServUSecondaryButtonStyle())
                    
                    Button("Accept & Continue") {
                        hasAccepted = true
                        isPresented = false
                    }
                    .buttonStyle(ServUPrimaryButtonStyle(backgroundColor: userProfile.college?.primaryColor ?? .blue))
                }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 20)
            .padding(.horizontal, 40)
        }
    }
}