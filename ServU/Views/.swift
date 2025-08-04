//
//  PaymentIntegrationView.swift
//  ServU
//
//  Created by Amber Still on 8/4/25.
//


//
//  PaymentIntegrationView.swift
//  ServU
//
//  Created by Quian Bowden on 8/3/25.
//  Enhanced payment integration view with real Stripe support
//

import SwiftUI
import UIKit
import Foundation

// MARK: - Payment Integration View
struct PaymentIntegrationView: View {
    @StateObject private var paymentManager = PaymentManager()
    @State private var showingPaymentResult = false
    @State private var paymentResultMessage = ""
    @State private var showingStripeInfo = false
    
    let booking: Booking?
    let cartItems: [CartItem]?
    let shippingOption: ShippingOption?
    let paymentType: ServUPaymentType
    
    // MARK: - Initializers
    
    init(for booking: Booking, type: ServUPaymentType) {
        self.booking = booking
        self.cartItems = nil
        self.shippingOption = nil
        self.paymentType = type
    }
    
    init(for cartItems: [CartItem], shipping: ShippingOption? = nil) {
        self.booking = nil
        self.cartItems = cartItems
        self.shippingOption = shipping
        self.paymentType = .full // Product purchases are always full payments
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Payment Summary
            PaymentSummaryCard()
            
            // Stripe Configuration Info (Debug Mode Only)
            #if DEBUG
            if showingStripeInfo {
                StripeInfoCard()
            }
            #endif
    
    @ViewBuilder
    func PaymentButton() -> some View {
        Button(action: initiatePayment) {
            HStack {
                if paymentManager.isProcessingPayment {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(paymentButtonTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(paymentManager.isProcessingPayment ? Color.gray : Color.servURed)
            .cornerRadius(12)
            .disabled(paymentManager.isProcessingPayment)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(paymentManager.isProcessingPayment ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: paymentManager.isProcessingPayment)
    }
            
            // Payment Button
            PaymentButton()
            
            // Payment Status
            PaymentStatusView()
            
            Spacer()
        }
        .alert("Payment Result", isPresented: $showingPaymentResult) {
            Button("OK") { 
                paymentManager.resetPaymentState()
            }
        } message: {
            Text(paymentResultMessage)
        }
        .onAppear {
            // Configure Stripe when view appears
            StripeConfig.configure()
        }
        .toolbar {
            #if DEBUG
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Debug") {
                    showingStripeInfo.toggle()
                }
                .foregroundColor(.blue)
            }
            #endif
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    func PaymentSummaryCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let booking = booking {
                ServiceSummaryView(booking: booking, paymentType: paymentType)
            } else if let items = cartItems {
                ProductSummaryView(items: items, shipping: shippingOption)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    @ViewBuilder
    func PaymentStatusView() -> some View {
        VStack(spacing: 12) {
            if paymentManager.isProcessingPayment {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Processing payment...")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("This may take a few seconds")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            if let error = paymentManager.paymentError {
                ErrorMessageView(message: error)
            }
            
            if paymentManager.paymentSuccess {
                SuccessMessageView()
            }
        }
    }
    
    #if DEBUG
    @ViewBuilder
    func StripeInfoCard() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(.blue)
                Text("Stripe Configuration")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button("Hide") {
                    showingStripeInfo = false
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            Text(StripeConfig.getEnvironmentInfo())
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.vertical, 4)
            
            HStack {
                Image(systemName: StripeConfig.validateConfiguration() ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(StripeConfig.validateConfiguration() ? .green : .red)
                Text(StripeConfig.validateConfiguration() ? "Configuration Valid" : "Configuration Invalid")
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    #endif
        Button(action: initiatePayment) {
            HStack {
                if paymentManager.isProcessingPayment {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(paymentButtonTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.servURed)
            .cornerRadius(12)
            .disabled(paymentManager.isProcessingPayment)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(paymentManager.isProcessingPayment ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: paymentManager.isProcessingPayment)
    }
    
    var paymentButtonTitle: String {
        if let booking = booking {
            switch paymentType {
            case .deposit:
                return "Pay Deposit ($\(String(format: "%.2f", booking.service.calculatedDepositAmount)))"
            case .full:
                return "Pay Full Amount ($\(String(format: "%.2f", booking.totalPrice)))"
            case .remainingBalance:
                return "Pay Remaining Balance ($\(String(format: "%.2f", booking.service.remainingBalance)))"
            }
        } else if let items = cartItems {
            let total = items.reduce(0) { $0 + $1.totalPrice } + (shippingOption?.price ?? 0.0)
            return "Complete Purchase ($\(String(format: "%.2f", total)))"
        } else {
            return "Pay Now"
        }
    }
    
    // MARK: - Payment Actions
    
    func initiatePayment() {
        // Reset previous state
        paymentManager.resetPaymentState()
        
        if let booking = booking {
            switch paymentType {
            case .deposit:
                paymentManager.processDepositPayment(for: booking) { success, error in
                    handlePaymentResult(success: success, error: error)
                }
                
            case .full:
                paymentManager.processFullPayment(for: booking) { success, error in
                    handlePaymentResult(success: success, error: error)
                }
                
            case .remainingBalance:
                paymentManager.processRemainingBalancePayment(for: booking) { success, error in
                    handlePaymentResult(success: success, error: error)
                }
            }
        } else if let items = cartItems {
            paymentManager.processProductPayment(for: items, shipping: shippingOption) { success, error in
                handlePaymentResult(success: success, error: error)
            }
        }
    }
    
    func handlePaymentResult(success: Bool, error: String?) {
        DispatchQueue.main.async {
            if success {
                paymentResultMessage = "🎉 Payment completed successfully!\n\nYou will receive a confirmation email shortly."
                
                // Add haptic feedback for success
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
            } else {
                paymentResultMessage = "❌ Payment failed\n\n\(error ?? "An unknown error occurred. Please try again.")"
                
                // Add haptic feedback for failure
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.error)
            }
            showingPaymentResult = true
        }
    }
}

// MARK: - Summary Views

struct ServiceSummaryView: View {
    let booking: Booking
    let paymentType: ServUPaymentType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Service:")
                Spacer()
                Text(booking.service.name)
                    .fontWeight(.medium)
            }
            
            switch paymentType {
            case .deposit:
                HStack {
                    Text("Deposit Amount:")
                    Spacer()
                    Text("$\(String(format: "%.2f", booking.service.calculatedDepositAmount))")
                        .fontWeight(.semibold)
                        .foregroundColor(.servURed)
                }
                
                HStack {
                    Text("Remaining Balance:")
                    Spacer()
                    Text("$\(String(format: "%.2f", booking.service.remainingBalance))")
                        .foregroundColor(.secondary)
                }
                
            case .full:
                HStack {
                    Text("Full Payment:")
                    Spacer()
                    Text("$\(String(format: "%.2f", booking.totalPrice))")
                        .fontWeight(.semibold)
                        .foregroundColor(.servURed)
                }
                
            case .remainingBalance:
                HStack {
                    Text("Deposit Paid:")
                    Spacer()
                    Text("$\(String(format: "%.2f", booking.service.calculatedDepositAmount))")
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Remaining Balance:")
                    Spacer()
                    Text("$\(String(format: "%.2f", booking.service.remainingBalance))")
                        .fontWeight(.semibold)
                        .foregroundColor(.servURed)
                }
            }
            
            Divider()
            
            HStack {
                Text("Total Service Cost:")
                Spacer()
                Text("$\(String(format: "%.2f", booking.service.price))")
                    .fontWeight(.semibold)
            }
        }
        .font(.subheadline)
    }
}

struct ProductSummaryView: View {
    let items: [CartItem]
    let shipping: ShippingOption?
    
    var subtotal: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var total: Double {
        subtotal + (shipping?.price ?? 0.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items) { item in
                HStack {
                    Text("\(item.quantity)x \(item.displayName)")
                    Spacer()
                    Text("$\(String(format: "%.2f", item.totalPrice))")
                        .fontWeight(.medium)
                }
                .font(.subheadline)
            }
            
            Divider()
            
            HStack {
                Text("Subtotal:")
                Spacer()
                Text("$\(String(format: "%.2f", subtotal))")
                    .fontWeight(.medium)
            }
            
            if let shipping = shipping {
                HStack {
                    Text("Shipping:")
                    Spacer()
                    Text("$\(String(format: "%.2f", shipping.price))")
                        .fontWeight(.medium)
                }
            }
            
            Divider()
            
            HStack {
                Text("Total:")
                Spacer()
                Text("$\(String(format: "%.2f", total))")
                    .fontWeight(.semibold)
                    .foregroundColor(.servURed)
            }
        }
        .font(.subheadline)
    }
}

// MARK: - Message Views

struct ErrorMessageView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.red)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

struct SuccessMessageView: View {
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text("Payment completed successfully!")
                .font(.subheadline)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Preview
struct PaymentIntegrationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Service Payment Preview
            PaymentIntegrationView(for: sampleBooking, type: .deposit)
                .padding()
                .previewDisplayName("Service Deposit")
            
            // Product Payment Preview
            PaymentIntegrationView(for: sampleCartItems, shipping: sampleShippingOption)
                .padding()
                .previewDisplayName("Product Purchase")
        }
    }
    
    // Sample booking for preview
    static var sampleBooking: Booking {
        let sampleService = Service(
            name: "Portrait Photography",
            description: "Professional portrait session",
            price: 150.0,
            duration: "2 hours",
            isAvailable: true,
            requiresDeposit: true,
            depositAmount: 50.0,
            depositType: .fixed,
            depositPolicy: "50% deposit required"
        )
        
        let sampleBusiness = Business(
            name: "Campus Photography",
            category: .photoVideo,
            description: "Professional photography services",
            rating: 4.8,
            priceRange: .moderate,
            imageURL: nil,
            isActive: true,
            location: "Campus Area",
            contactInfo: ContactInfo(email: "info@example.com", phone: "(555) 123-4567"),
            services: [sampleService],
            availability: BusinessHours.defaultHours
        )
        
        return Booking(
            id: UUID(),
            service: sampleService,
            business: sampleBusiness,
            customerName: "John Doe",
            customerEmail: "john@example.com",
            customerPhone: "(555) 123-4567",
            appointmentDate: Date(),
            startTime: Date(),
            endTime: Date().addingTimeInterval(7200),
            status: .confirmed,
            notes: "",
            totalPrice: 150.0,
            paymentStatus: .pending
        )
    }
    
    // Sample cart items for preview
    static var sampleCartItems: [CartItem] {
        let product1 = Product(
            name: "Campus T-Shirt",
            description: "Official university merchandise",
            category: .clothing,
            basePrice: 25.0,
            images: [],
            variants: [],
            inventory: ProductInventory(quantity: 50),
            specifications: [],
            tags: ["clothing", "university", "apparel"],
            isActive: true
        )
        
        let product2 = Product(
            name: "Campus Hoodie",
            description: "Comfortable university hoodie",
            category: .clothing,
            basePrice: 45.0,
            images: [],
            variants: [],
            inventory: ProductInventory(quantity: 25),
            specifications: [],
            tags: ["clothing", "university", "hoodie"],
            isActive: true
        )
        
        return [
            CartItem(product: product1, quantity: 2),
            CartItem(product: product2, quantity: 1)
        ]
    }
    
    // Sample shipping option for preview
    static var sampleShippingOption: ShippingOption {
        return ShippingOption.standardShipping
    }
}