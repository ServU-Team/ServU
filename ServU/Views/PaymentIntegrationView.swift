//
//  PaymentIntegrationView.swift
//  ServU
//
//  Created by Amber Still on 8/2/25.
//


//
//  PaymentIntegrationView.swift
//  ServU
//
//  Created by Quian Bowden on 8/2/25.
//  Simple payment integration view for ServU
//

import SwiftUI

// MARK: - Payment Integration View
struct PaymentIntegrationView: View {
    @StateObject private var paymentManager = PaymentManager()
    @State private var showingPaymentResult = false
    @State private var paymentResultMessage = ""
    
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
            
            // Payment Button
            PaymentButton()
            
            // Payment Status
            if paymentManager.isProcessingPayment {
                ProgressView("Processing payment...")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            
            if let error = paymentManager.paymentError {
                ErrorMessageView(message: error)
            }
            
            if paymentManager.paymentSuccess {
                SuccessMessageView()
            }
        }
        .alert("Payment Result", isPresented: $showingPaymentResult) {
            Button("OK") { 
                paymentManager.resetPaymentState()
            }
        } message: {
            Text(paymentResultMessage)
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func PaymentSummaryCard() -> some View {
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
    private func PaymentButton() -> some View {
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
    
    private var paymentButtonTitle: String {
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
    
    private func initiatePayment() {
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
    
    private func handlePaymentResult(success: Bool, error: String?) {
        if success {
            paymentResultMessage = "Payment completed successfully!"
        } else {
            paymentResultMessage = error ?? "An unknown error occurred"
        }
        showingPaymentResult = true
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
    
    private var subtotal: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    private var total: Double {
        subtotal + (shipping?.price ?? 0.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items) { item in
                HStack {
                    Text("\(item.quantity)x \(item.product.name)")
                    Spacer()
                    Text("$\(String(format: "%.2f", item.totalPrice))")
                        .fontWeight(.medium)
                }
            }
            
            if let shipping = shipping {
                HStack {
                    Text("Shipping (\(shipping.name)):")
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

struct ErrorMessageView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.red)
            Spacer()
        }
        .padding(12)
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
            Spacer()
        }
        .padding(12)
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Preview
struct PaymentIntegrationView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PaymentIntegrationView(
                for: Booking.sampleBooking,
                type: .deposit
            )
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Sample Data Extension
extension Booking {
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
            id: UUID(),
            name: "Sample Photography",
            category: .photoVideo,
            description: "Professional photography services",
            rating: 4.8,
            priceRange: .moderate,
            imageURL: "",
            isActive: true,
            location: "Campus Area",
            contactInfo: ContactInfo(email: "info@example.com", phone: "(555) 123-4567"),
            services: [],
            availability: BusinessHours.allDay
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
            paymentStatus: .pending,
            createdAt: Date()
        )
    }
}