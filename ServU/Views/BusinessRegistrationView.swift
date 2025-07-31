//
//  BusinessRegistrationView.swift
//  ServU
//
//  Created by Amber Still on 7/31/25.
//


//
//  BusinessRegistrationView.swift
//  ServU
//
//  Created by Quian Bowden on 7/31/25.
//

import SwiftUI

struct BusinessRegistrationView: View {
    @ObservedObject var userProfile: UserProfile
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingTermsPopup = true
    @State private var hasAcceptedTerms = false
    @State private var currentStep: RegistrationStep = .businessInfo
    @State private var isSubmitting = false
    
    // Business Information
    @State private var businessName = ""
    @State private var businessDescription = ""
    @State private var selectedBusinessType: BusinessType = .services
    @State private var selectedServiceCategories: Set<ServiceCategory> = []
    @State private var selectedProductCategories: Set<ProductCategory> = []
    @State private var businessLocation = ""
    @State private var contactEmail = ""
    @State private var contactPhone = ""
    @State private var instagramHandle = ""
    @State private var website = ""
    
    // Services
    @State private var services: [Service] = []
    @State private var showingAddService = false
    
    // Products
    @State private var products: [Product] = []
    @State private var showingAddProduct = false
    
    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    // Background with college colors
                    LinearGradient(
                        gradient: Gradient(colors: [
                            userProfile.college?.colorScheme.background ?? Color(.systemGray6),
                            Color(.systemBackground)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .edgesIgnoringSafeArea(.all)
                    
                    if hasAcceptedTerms {
                        registrationContent
                    }
                }
                .navigationTitle("Register Business")
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
            
            // Terms and Conditions Popup
            if showingTermsPopup {
                TermsAndConditionsPopup(
                    userProfile: userProfile,
                    isPresented: $showingTermsPopup,
                    hasAccepted: $hasAcceptedTerms
                )
            }
            
            // Loading Overlay
            if isSubmitting {
                ServULoadingView(message: "Registering your business...")
            }
        }
    }
    
    // MARK: - Registration Content
    private var registrationContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Progress Indicator
                progressIndicator
                
                // Step Content
                stepContent
                
                // Action Buttons
                actionButtons
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        HStack(spacing: 0) {
            ForEach(RegistrationStep.allCases.indices, id: \.self) { index in
                let step = RegistrationStep.allCases[index]
                let isActive = step.rawValue <= currentStep.rawValue
                let isCurrent = step == currentStep
                
                HStack(spacing: 0) {
                    // Step Circle
                    Circle()
                        .fill(isActive ? userProfile.college?.primaryColor ?? .blue : Color.gray.opacity(0.3))
                        .frame(width: isCurrent ? 32 : 24, height: isCurrent ? 32 : 24)
                        .overlay(
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(isActive ? .white : .gray)
                        )
                        .animation(.spring(response: 0.3), value: currentStep)
                    
                    // Connector Line
                    if index < RegistrationStep.allCases.count - 1 {
                        Rectangle()
                            .fill(isActive ? userProfile.college?.primaryColor ?? .blue : Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Step Content
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .businessInfo:
            businessInfoStep
        case .serviceSetup:
            serviceSetupStep
        case .review:
            reviewStep
        }
    }
    
    // MARK: - Business Info Step
    private var businessInfoStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Business Information")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(userProfile.college?.primaryColor ?? .blue)
            
            RegistrationCard(title: "Basic Details") {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Business Name *")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        TextField("Enter your business name", text: $businessName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description *")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        TextEditor(text: $businessDescription)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Business Type *")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Picker("Business Type", selection: $selectedBusinessType) {
                            ForEach(BusinessType.allCases, id: \.self) { type in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(type.rawValue)
                                        .fontWeight(.medium)
                                    Text(type.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            }
            
            if selectedBusinessType == .services || selectedBusinessType == .both {
                RegistrationCard(title: "Service Categories") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(ServiceCategory.allCases, id: \.self) { category in
                            CategorySelectionButton(
                                title: category.displayName,
                                icon: category.icon,
                                isSelected: selectedServiceCategories.contains(category),
                                userProfile: userProfile
                            ) {
                                if selectedServiceCategories.contains(category) {
                                    selectedServiceCategories.remove(category)
                                } else {
                                    selectedServiceCategories.insert(category)
                                }
                            }
                        }
                    }
                }
            }
            
            if selectedBusinessType == .products || selectedBusinessType == .both {
                RegistrationCard(title: "Product Categories") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(ProductCategory.allCases, id: \.self) { category in
                            CategorySelectionButton(
                                title: category.displayName,
                                icon: category.icon,
                                isSelected: selectedProductCategories.contains(category),
                                userProfile: userProfile
                            ) {
                                if selectedProductCategories.contains(category) {
                                    selectedProductCategories.remove(category)
                                } else {
                                    selectedProductCategories.insert(category)
                                }
                            }
                        }
                    }
                }
            }
            
            RegistrationCard(title: "Contact Information") {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location *")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        TextField("e.g., Tuskegee University Campus", text: $businessLocation)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Contact Email *")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        TextField("business@email.com", text: $contactEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone Number *")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        TextField("(555) 123-4567", text: $contactPhone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instagram Handle (Optional)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        TextField("@yourbusiness", text: $instagramHandle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Website (Optional)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        TextField("www.yourbusiness.com", text: $website)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    }
                }
            }
        }
    }
    
    // MARK: - Service Setup Step
    private var serviceSetupStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Services & Products")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(userProfile.college?.primaryColor ?? .blue)
            
            if selectedBusinessType == .services || selectedBusinessType == .both {
                RegistrationCard(title: "Services") {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Add the services you offer")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("Add Service") {
                                showingAddService = true
                            }
                            .buttonStyle(ServUPrimaryButtonStyle(backgroundColor: userProfile.college?.primaryColor ?? .blue))
                            .font(.caption)
                        }
                        
                        if services.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "wrench.and.screwdriver")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("No services added yet")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(services) { service in
                                    ServiceRowView(service: service, userProfile: userProfile) {
                                        // Edit service
                                    } onDelete: {
                                        services.removeAll { $0.id == service.id }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if selectedBusinessType == .products || selectedBusinessType == .both {
                RegistrationCard(title: "Products") {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Add the products you sell")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("Add Product") {
                                showingAddProduct = true
                            }
                            .buttonStyle(ServUPrimaryButtonStyle(backgroundColor: userProfile.college?.primaryColor ?? .blue))
                            .font(.caption)
                        }
                        
                        if products.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "bag")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("No products added yet")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(products) { product in
                                    ProductRowView(product: product, userProfile: userProfile) {
                                        // Edit product
                                    } onDelete: {
                                        products.removeAll { $0.id == product.id }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddService) {
            AddServiceView(userProfile: userProfile) { newService in
                services.append(newService)
            }
        }
        .sheet(isPresented: $showingAddProduct) {
            AddProductView(userProfile: userProfile) { newProduct in
                products.append(newProduct)
            }
        }
    }
    
    // MARK: - Review Step
    private var reviewStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Review & Submit")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(userProfile.college?.primaryColor ?? .blue)
            
            RegistrationCard(title: "Business Summary") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Name:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(businessName)
                    }
                    
                    HStack {
                        Text("Type:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(selectedBusinessType.rawValue)
                    }
                    
                    HStack {
                        Text("Location:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(businessLocation)
                    }
                    
                    if selectedBusinessType == .services || selectedBusinessType == .both {
                        HStack(alignment: .top) {
                            Text("Services:")
                                .fontWeight(.semibold)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                ForEach(services, id: \.id) { service in
                                    Text("\(service.name) - $\(String(format: "%.0f", service.price))")
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                    
                    if selectedBusinessType == .products || selectedBusinessType == .both {
                        HStack(alignment: .top) {
                            Text("Products:")
                                .fontWeight(.semibold)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                ForEach(products, id: \.id) { product in
                                    Text("\(product.name) - \(product.displayPrice)")
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
            }
            
            RegistrationCard(title: "Platform Fees") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Understanding Our Fees")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Platform Fee:")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(PlatformFeeConfig.serviceFeePercentage, specifier: "%.1f")%")
                                .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        }
                        
                        HStack {
                            Text("Payment Processing:")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(PlatformFeeConfig.stripeFeePercentage, specifier: "%.1f")% + $\(PlatformFeeConfig.stripeFeeFixed, specifier: "%.2f")")
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        Text("Example: For a $100 service")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        let exampleAmount = 100.0
                        HStack {
                            Text("You receive:")
                                .fontWeight(.medium)
                            Spacer()
                            Text("$\(PlatformFeeConfig.calculateBusinessPayout(for: exampleAmount), specifier: "%.2f")")
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: primaryAction) {
                Text(primaryButtonTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(userProfile.college?.primaryColor ?? .blue)
                    .cornerRadius(12)
            }
            .disabled(!canProceed)
            .opacity(canProceed ? 1.0 : 0.6)
            
            if currentStep != .businessInfo {
                Button(action: previousStep) {
                    Text("Back")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(userProfile.college?.primaryColor ?? .blue, lineWidth: 2)
                        )
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var canProceed: Bool {
        switch currentStep {
        case .businessInfo:
            return !businessName.isEmpty && 
                   !businessDescription.isEmpty && 
                   !businessLocation.isEmpty && 
                   !contactEmail.isEmpty && 
                   !contactPhone.isEmpty &&
                   (!selectedServiceCategories.isEmpty || !selectedProductCategories.isEmpty)
        case .serviceSetup:
            if selectedBusinessType == .services {
                return !services.isEmpty
            } else if selectedBusinessType == .products {
                return !products.isEmpty
            } else { // both
                return !services.isEmpty && !products.isEmpty
            }
        case .review:
            return true
        }
    }
    
    private var primaryButtonTitle: String {
        switch currentStep {
        case .businessInfo:
            return "Continue"
        case .serviceSetup:
            return "Review"
        case .review:
            return "Register Business"
        }
    }
    
    // MARK: - Actions
    private func primaryAction() {
        switch currentStep {
        case .businessInfo:
            currentStep = .serviceSetup
        case .serviceSetup:
            currentStep = .review
        case .review:
            submitRegistration()
        }
    }
    
    private func previousStep() {
        switch currentStep {
        case .businessInfo:
            break
        case .serviceSetup:
            currentStep = .businessInfo
        case .review:
            currentStep = .serviceSetup
        }
    }
    
    private func submitRegistration() {
        isSubmitting = true
        
        // Create the business
        let contactInfo = ContactInfo(
            email: contactEmail,
            phone: contactPhone,
            instagram: instagramHandle.isEmpty ? nil : instagramHandle,
            website: website.isEmpty ? nil : website
        )
        
        let business = Business(
            name: businessName,
            category: selectedServiceCategories.first ?? .other,
            description: businessDescription,
            rating: 5.0, // New businesses start with 5.0
            priceRange: .moderate, // Default
            imageURL: nil,
            isActive: true,
            location: businessLocation,
            contactInfo: contactInfo,
            services: services,
            availability: BusinessHours.defaultHours
        )
        
        // Simulate registration process
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // Add business to user profile
            userProfile.businesses.append(business)
            userProfile.isBusinessOwner = true
            
            isSubmitting = false
            HapticFeedback.success()
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Registration Steps
enum RegistrationStep: Int, CaseIterable {
    case businessInfo = 0
    case serviceSetup = 1
    case review = 2
}

// MARK: - Supporting Views

struct RegistrationCard<Content: View>: View {
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

struct CategorySelectionButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    @ObservedObject var userProfile: UserProfile
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : (userProfile.college?.primaryColor ?? .blue))
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isSelected ? (userProfile.college?.primaryColor ?? .blue) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(userProfile.college?.primaryColor ?? .blue, lineWidth: isSelected ? 0 : 1)
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

#Preview {
    BusinessRegistrationView(userProfile: UserProfile())
}