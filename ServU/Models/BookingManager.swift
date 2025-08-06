//
//  BookingManager.swift
//  ServU
//
//  Created by Amber Still on 8/6/25.
//


//
//  MissingManagers.swift
//  ServU
//
//  Created by Quian Bowden on 8/5/25.
//  Missing managers and models to fix compilation errors
//

import Foundation
import SwiftUI

// MARK: - Booking Manager
class BookingManager: ObservableObject {
    @Published var userBookings: [ServUBooking] = []
    @Published var pendingBookings: [ServUBooking] = []
    @Published var completedBookings: [ServUBooking] = []
    
    init() {
        // Add sample bookings for testing
        createSampleBookings()
    }
    
    private func createSampleBookings() {
        let sampleService = ServUService(
            name: "Sample Service",
            description: "A sample service for testing",
            price: 50.0,
            duration: "1 hour",
            requiresDeposit: true,
            depositAmount: 15.0,
            depositType: .fixed
        )
        
        let sampleBooking = ServUBooking(
            service: sampleService,
            businessName: "Sample Business",
            customerName: "Sample Customer",
            date: Date(),
            timeSlot: TimeSlot(
                startTime: Date(),
                endTime: Date().addingTimeInterval(3600)
            )
        )
        
        userBookings.append(sampleBooking)
    }
    
    func addBooking(_ booking: ServUBooking) {
        userBookings.append(booking)
    }
    
    func cancelBooking(_ booking: ServUBooking) {
        userBookings.removeAll { $0.id == booking.id }
    }
}

// MARK: - ServU Booking Model
struct ServUBooking: Identifiable, Codable {
    let id = UUID()
    var service: ServUService
    var businessName: String
    var customerName: String
    var date: Date
    var timeSlot: TimeSlot
    var status: BookingStatus
    var totalAmount: Double
    var depositPaid: Double
    var notes: String
    
    init(service: ServUService, businessName: String, customerName: String, date: Date, timeSlot: TimeSlot, status: BookingStatus = .pending, notes: String = "") {
        self.service = service
        self.businessName = businessName
        self.customerName = customerName
        self.date = date
        self.timeSlot = timeSlot
        self.status = status
        self.totalAmount = service.price
        self.depositPaid = service.requiresDeposit ? service.calculatedDepositAmount : 0.0
        self.notes = notes
    }
    
    var remainingBalance: Double {
        return totalAmount - depositPaid
    }
    
    var isDepositRequired: Bool {
        return service.requiresDeposit && depositPaid < service.calculatedDepositAmount
    }
}

// MARK: - Booking Status
enum BookingStatus: String, CaseIterable, Codable {
    case pending = "PENDING"
    case confirmed = "CONFIRMED"
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .confirmed: return .blue
        case .inProgress: return .purple
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}

// MARK: - Payment Type
enum PaymentType: String, CaseIterable {
    case deposit = "DEPOSIT"
    case full = "FULL"
    case remaining = "REMAINING"
    
    var displayName: String {
        switch self {
        case .deposit: return "Deposit Payment"
        case .full: return "Full Payment"
        case .remaining: return "Remaining Balance"
        }
    }
}

// MARK: - Stripe Config
struct StripeConfig {
    static let developmentPublishableKey: String? = "pk_test_your_key_here"
    static let productionPublishableKey: String? = nil
    
    static func getEnvironmentInfo() -> String {
        #if DEBUG
        return "Environment: Development\nPublishable Key: \(developmentPublishableKey?.prefix(20) ?? "Not Set")..."
        #else
        return "Environment: Production\nPublishable Key: \(productionPublishableKey?.prefix(20) ?? "Not Set")..."
        #endif
    }
}

// MARK: - MSAL Manager (Placeholder)
class MSALManager: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var currentUser: String = ""
    @Published var loggingText: String = ""
    
    func signInInteractively() {
        // Simulate sign in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isSignedIn = true
            self.currentUser = "student@tuskegee.edu"
            self.updateLogging(text: "Sign in successful")
        }
    }
    
    func signOut() {
        isSignedIn = false
        currentUser = ""
        updateLogging(text: "Signed out successfully")
    }
    
    func loadCurrentAccount() {
        // Check if user is already signed in
        updateLogging(text: "Checking for existing account...")
    }
    
    func updateLogging(text: String) {
        let timestamp = DateFormatter.current.string(from: Date())
        loggingText += "\n[\(timestamp)] \(text)"
    }
    
    func resetKeychainForDevelopment() {
        updateLogging(text: "Keychain reset for development")
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let current: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
}

// MARK: - Welcome View Placeholder
struct WelcomeView: View {
    @ObservedObject var msalManager: MSALManager
    
    var body: some View {
        VStack {
            Text("Welcome to ServU")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Button("Sign In") {
                msalManager.signInInteractively()
            }
            .buttonStyle(ServUPrimaryButtonStyle())
        }
        .padding()
    }
}

// MARK: - Main Tab View Placeholder
struct MainTabView: View {
    @ObservedObject var msalManager: MSALManager
    
    var body: some View {
        TabView {
            Text("Home")
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            Text("Services")
                .tabItem {
                    Image(systemName: "wrench.and.screwdriver.fill")
                    Text("Services")
                }
            
            Text("Products")
                .tabItem {
                    Image(systemName: "bag.fill")
                    Text("Products")
                }
            
            Text("Profile")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}

// MARK: - Payment Integration View Placeholder
struct PaymentIntegrationView: View {
    let booking: ServUBooking
    let type: PaymentType
    
    init(for booking: ServUBooking, type: PaymentType) {
        self.booking = booking
        self.type = type
    }
    
    var body: some View {
        VStack {
            Text("Payment Integration")
                .font(.title)
            
            Text("Booking: \(booking.service.name)")
            Text("Type: \(type.displayName)")
            
            Button("Process Payment") {
                // TODO: Implement Stripe payment
            }
            .buttonStyle(ServUPrimaryButtonStyle())
        }
        .padding()
    }
}

// MARK: - Service Booking View Placeholder
struct ServiceBookingView: View {
    let business: Business
    let service: ServUService
    @ObservedObject var userProfile: UserProfile
    @ObservedObject var bookingManager: BookingManager
    
    var body: some View {
        VStack {
            Text("Book Service")
                .font(.title)
            
            Text("Service: \(service.name)")
            Text("Business: \(business.name)")
            Text("Price: \(service.formattedPrice)")
            
            Button("Book Now") {
                let booking = ServUBooking(
                    service: service,
                    businessName: business.name,
                    customerName: userProfile.fullName,
                    date: Date(),
                    timeSlot: TimeSlot(
                        startTime: Date(),
                        endTime: Date().addingTimeInterval(3600)
                    )
                )
                bookingManager.addBooking(booking)
            }
            .buttonStyle(ServUPrimaryButtonStyle())
        }
        .padding()
    }
}

// MARK: - Shopping Cart Manager
class ShoppingCartManager: ObservableObject {
    @Published var items: [CartItem] = []
    
    var itemCount: Int {
        return items.reduce(0) { $0 + $1.quantity }
    }
    
    var subtotal: Double {
        return items.reduce(0) { $0 + $1.totalPrice }
    }
    
    func addItem(_ product: Product, variant: ProductVariant?, quantity: Int) {
        if let existingIndex = items.firstIndex(where: { 
            $0.product.id == product.id && $0.selectedVariant?.id == variant?.id 
        }) {
            items[existingIndex].quantity += quantity
        } else {
            let newItem = CartItem(product: product, selectedVariant: variant, quantity: quantity)
            items.append(newItem)
        }
    }
    
    func removeItem(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if quantity <= 0 {
                items.remove(at: index)
            } else {
                items[index].quantity = quantity
            }
        }
    }
    
    func clearCart() {
        items.removeAll()
    }
}

// MARK: - Cart Item
struct CartItem: Identifiable, Codable {
    let id = UUID()
    var product: Product
    var selectedVariant: ProductVariant?
    var quantity: Int
    var addedDate: Date
    
    init(product: Product, selectedVariant: ProductVariant? = nil, quantity: Int) {
        self.product = product
        self.selectedVariant = selectedVariant
        self.quantity = quantity
        self.addedDate = Date()
    }
    
    var unitPrice: Double {
        return selectedVariant?.price ?? product.basePrice
    }
    
    var totalPrice: Double {
        return unitPrice * Double(quantity)
    }
    
    var displayName: String {
        if let variant = selectedVariant {
            return "\(product.name) - \(variant.displayName)"
        }
        return product.name
    }
}