//
//  ManageServicesView.swift
//  ServU
//
//  Created by Amber Still on 7/31/25.
//


//
//  ManageServicesView.swift
//  ServU
//
//  Created by Quian Bowden on 7/31/25.
//

import SwiftUI

struct ManageServicesView: View {
    let business: Business
    @ObservedObject var userProfile: UserProfile
    @Environment(\.presentationMode) var presentationMode
    
    @State private var services: [Service] = []
    @State private var showingAddService = false
    @State private var selectedService: Service?
    @State private var showingEditService = false
    @State private var showingDeleteAlert = false
    @State private var serviceToDelete: Service?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(business.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                            
                            Text("Manage Services & Products")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { showingAddService = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .background(Color(.systemGray6).opacity(0.3))
                
                // Services List
                if services.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No Services Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Add your first service to start accepting bookings!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button("Add Service") {
                            showingAddService = true
                        }
                        .buttonStyle(ServUPrimaryButtonStyle(backgroundColor: userProfile.college?.primaryColor ?? .blue))
                        .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(services) { service in
                                ManageableServiceCard(
                                    service: service,
                                    userProfile: userProfile,
                                    onEdit: {
                                        selectedService = service
                                        showingEditService = true
                                    },
                                    onDelete: {
                                        serviceToDelete = service
                                        showingDeleteAlert = true
                                    },
                                    onToggleAvailability: {
                                        toggleServiceAvailability(service)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
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
            .sheet(isPresented: $showingAddService) {
                AddServiceView(userProfile: userProfile) { newService in
                    services.append(newService)
                }
            }
            .sheet(isPresented: $showingEditService) {
                if let service = selectedService {
                    EditServiceView(service: service, userProfile: userProfile) { updatedService in
                        if let index = services.firstIndex(where: { $0.id == updatedService.id }) {
                            services[index] = updatedService
                        }
                    }
                }
            }
            .alert("Delete Service", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let serviceToDelete = serviceToDelete {
                        deleteService(serviceToDelete)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this service? This action cannot be undone.")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                }
            }
        }
        .onAppear {
            loadServices()
        }
    }
    
    private func loadServices() {
        services = business.services
    }
    
    private func toggleServiceAvailability(_ service: Service) {
        if let index = services.firstIndex(where: { $0.id == service.id }) {
            services[index].isAvailable.toggle()
            HapticFeedback.light()
        }
    }
    
    private func deleteService(_ service: Service) {
        services.removeAll { $0.id == service.id }
        serviceToDelete = nil
        HapticFeedback.success()
    }
}

// MARK: - Manageable Service Card
struct ManageableServiceCard: View {
    let service: Service
    @ObservedObject var userProfile: UserProfile
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleAvailability: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Service Header
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(service.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Availability Toggle
                        Button(action: onToggleAvailability) {
                            Text(service.isAvailable ? "Available" : "Unavailable")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(service.isAvailable ? .green : .red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(service.isAvailable ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    
                    Text(service.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle")
                            Text(String(format: "$%.2f", service.price))
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.green)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text(service.duration)
                        }
                        .foregroundColor(.blue)
                        
                        if service.requiresDeposit {
                            HStack(spacing: 4) {
                                Image(systemName: "creditcard")
                                Text("Deposit: \(service.displayDepositAmount)")
                            }
                            .foregroundColor(.orange)
                        }
                        
                        Spacer()
                    }
                    .font(.caption)
                }
            }
            
            // Service Stats
            HStack(spacing: 20) {
                VStack {
                    Text("\(Int.random(in: 0...25))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                    Text("Bookings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("$\(Int.random(in: 100...800))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Revenue")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(String(format: "%.1f", Double.random(in: 4.0...5.0)))★")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    Text("Rating")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                            .frame(width: 32, height: 32)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .servUCardShadow()
    }
}

// MARK: - Add Service View
struct AddServiceView: View {
    @ObservedObject var userProfile: UserProfile
    let onSave: (Service) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var serviceName = ""
    @State private var serviceDescription = ""
    @State private var servicePrice: Double = 50.0
    @State private var serviceDuration = "1 hour"
    @State private var requiresDeposit = false
    @State private var depositAmount: Double = 10.0
    @State private var depositType: DepositType = .fixed
    @State private var depositPolicy = "Deposit is non-refundable if appointment is missed or cancelled less than 24 hours in advance."
    
    private let durationOptions = ["30 minutes", "45 minutes", "1 hour", "1.5 hours", "2 hours", "3 hours", "Custom"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Service Details
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Service Details")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        
                        ServiceFormCard(title: "Basic Information") {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Service Name *")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    TextField("e.g., Haircut & Style", text: $serviceName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Description *")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    TextEditor(text: $serviceDescription)
                                        .frame(minHeight: 80)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
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
                                            
                                            TextField("50.00", value: $servicePrice, format: .number)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                .keyboardType(.decimalPad)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Duration *")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Picker("Duration", selection: $serviceDuration) {
                                            ForEach(durationOptions, id: \.self) { duration in
                                                Text(duration).tag(duration)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        ServiceFormCard(title: "Deposit Settings") {
                            VStack(alignment: .leading, spacing: 16) {
                                Toggle("Require Deposit", isOn: $requiresDeposit)
                                    .toggleStyle(SwitchToggleStyle(tint: userProfile.college?.primaryColor ?? .blue))
                                
                                if requiresDeposit {
                                    VStack(alignment: .leading, spacing: 16) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Deposit Type")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            Picker("Deposit Type", selection: $depositType) {
                                                ForEach(DepositType.allCases, id: \.self) { type in
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(type.rawValue)
                                                            .fontWeight(.medium)
                                                        Text(type.description)
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                    }
                                                    .tag(type)
                                                }
                                            }
                                            .pickerStyle(SegmentedPickerStyle())
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(depositType == .fixed ? "Deposit Amount" : "Deposit Percentage")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            HStack {
                                                if depositType == .fixed {
                                                    Text("$")
                                                        .font(.headline)
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                TextField(depositType == .fixed ? "10.00" : "20", value: $depositAmount, format: .number)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                                    .keyboardType(.decimalPad)
                                                
                                                if depositType == .percentage {
                                                    Text("%")
                                                        .font(.headline)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            
                                            // Preview
                                            if depositType == .percentage && servicePrice > 0 {
                                                Text("Preview: $\(servicePrice * (depositAmount / 100), specifier: "%.2f") deposit")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Deposit Policy")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            TextEditor(text: $depositPolicy)
                                                .frame(minHeight: 60)
                                                .padding(8)
                                                .background(Color(.systemGray6))
                                                .cornerRadius(8)
                                            
                                            Text("This policy will be shown to customers before booking")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6).opacity(0.5))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: saveService) {
                            Text("Add Service")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(userProfile.college?.primaryColor ?? .blue)
                                .cornerRadius(12)
                        }
                        .disabled(!canSaveService)
                        .opacity(canSaveService ? 1.0 : 0.6)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Add Service")
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
        }
    }
    
    private var canSaveService: Bool {
        return !serviceName.isEmpty && 
               !serviceDescription.isEmpty && 
               servicePrice > 0
    }
    
    private func saveService() {
        let newService = Service(
            name: serviceName,
            description: serviceDescription,
            price: servicePrice,
            duration: serviceDuration,
            isAvailable: true,
            requiresDeposit: requiresDeposit,
            depositAmount: depositAmount,
            depositType: depositType,
            depositPolicy: depositPolicy
        )
        
        onSave(newService)
        HapticFeedback.success()
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Edit Service View
struct EditServiceView: View {
    @State private var service: Service
    @ObservedObject var userProfile: UserProfile
    let onSave: (Service) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var serviceName: String
    @State private var serviceDescription: String
    @State private var servicePrice: Double
    @State private var serviceDuration: String
    @State private var requiresDeposit: Bool
    @State private var depositAmount: Double
    @State private var depositType: DepositType
    @State private var depositPolicy: String
    
    private let durationOptions = ["30 minutes", "45 minutes", "1 hour", "1.5 hours", "2 hours", "3 hours", "Custom"]
    
    init(service: Service, userProfile: UserProfile, onSave: @escaping (Service) -> Void) {
        self.service = service
        self.userProfile = userProfile
        self.onSave = onSave
        
        // Initialize state variables
        self._serviceName = State(initialValue: service.name)
        self._serviceDescription = State(initialValue: service.description)
        self._servicePrice = State(initialValue: service.price)
        self._serviceDuration = State(initialValue: service.duration)
        self._requiresDeposit = State(initialValue: service.requiresDeposit)
        self._depositAmount = State(initialValue: service.depositAmount)
        self._depositType = State(initialValue: service.depositType)
        self._depositPolicy = State(initialValue: service.depositPolicy)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Service Details
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Edit Service")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        
                        ServiceFormCard(title: "Basic Information") {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Service Name *")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    TextField("e.g., Haircut & Style", text: $serviceName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Description *")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    TextEditor(text: $serviceDescription)
                                        .frame(minHeight: 80)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
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
                                            
                                            TextField("50.00", value: $servicePrice, format: .number)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                .keyboardType(.decimalPad)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Duration *")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Picker("Duration", selection: $serviceDuration) {
                                            ForEach(durationOptions, id: \.self) { duration in
                                                Text(duration).tag(duration)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        ServiceFormCard(title: "Deposit Settings") {
                            VStack(alignment: .leading, spacing: 16) {
                                Toggle("Require Deposit", isOn: $requiresDeposit)
                                    .toggleStyle(SwitchToggleStyle(tint: userProfile.college?.primaryColor ?? .blue))
                                
                                if requiresDeposit {
                                    VStack(alignment: .leading, spacing: 16) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Deposit Type")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            Picker("Deposit Type", selection: $depositType) {
                                                ForEach(DepositType.allCases, id: \.self) { type in
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(type.rawValue)
                                                            .fontWeight(.medium)
                                                        Text(type.description)
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                    }
                                                    .tag(type)
                                                }
                                            }
                                            .pickerStyle(SegmentedPickerStyle())
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(depositType == .fixed ? "Deposit Amount" : "Deposit Percentage")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            HStack {
                                                if depositType == .fixed {
                                                    Text("$")
                                                        .font(.headline)
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                TextField(depositType == .fixed ? "10.00" : "20", value: $depositAmount, format: .number)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                                    .keyboardType(.decimalPad)
                                                
                                                if depositType == .percentage {
                                                    Text("%")
                                                        .font(.headline)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            
                                            // Preview
                                            if depositType == .percentage && servicePrice > 0 {
                                                Text("Preview: $\(servicePrice * (depositAmount / 100), specifier: "%.2f") deposit")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Deposit Policy")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            TextEditor(text: $depositPolicy)
                                                .frame(minHeight: 60)
                                                .padding(8)
                                                .background(Color(.systemGray6))
                                                .cornerRadius(8)
                                            
                                            Text("This policy will be shown to customers before booking")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6).opacity(0.5))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: saveService) {
                            Text("Save Changes")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(userProfile.college?.primaryColor ?? .blue)
                                .cornerRadius(12)
                        }
                        .disabled(!canSaveService)
                        .opacity(canSaveService ? 1.0 : 0.6)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Edit Service")
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
        }
    }
    
    private var canSaveService: Bool {
        return !serviceName.isEmpty && 
               !serviceDescription.isEmpty && 
               servicePrice > 0
    }
    
    private func saveService() {
        var updatedService = service
        updatedService.name = serviceName
        updatedService.description = serviceDescription
        updatedService.price = servicePrice
        updatedService.duration = serviceDuration
        updatedService.requiresDeposit = requiresDeposit
        updatedService.depositAmount = depositAmount
        updatedService.depositType = depositType
        updatedService.depositPolicy = depositPolicy
        
        onSave(updatedService)
        HapticFeedback.success()
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Service Form Card
struct ServiceFormCard<Content: View>: View {
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

// MARK: - Service Row View (for registration)
struct ServiceRowView: View {
    let service: Service
    @ObservedObject var userProfile: UserProfile
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(service.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(service.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    Text("$\(String(format: "%.2f", service.price))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text(service.duration)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    if service.requiresDeposit {
                        Text("Deposit: \(service.displayDepositAmount)")
                            .font(.caption)
                            .foregroundColor(.orange)
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
    let sampleBusiness = Business(
        name: "Sample Business",
        category: .photoVideo,
        description: "Sample description",
        rating: 4.8,
        priceRange: .moderate,
        location: "Sample Location",
        contactInfo: ContactInfo(email: "test@test.com", phone: "555-0123"),
        availability: BusinessHours.defaultHours
    )
    
    return ManageServicesView(business: sampleBusiness, userProfile: UserProfile())
}