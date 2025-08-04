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
//  Created by Quian Bowden on 8/4/25.
//  Fixed payment integration view with no ambiguous references
//

import SwiftUI

// MARK: - Payment Integration View
struct PaymentIntegrationView: View {
    @StateObject private var paymentManager = PaymentManager()
    @State private var showingPaymentResult = false
    @State private var paymentResultMessage = ""
    @State private var isPaymentSuccessful = false
    
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
        self.paymentType = ServUPaymentType.full
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                paymentHeaderView
                paymentSummaryCard
                paymentMethodSection
                
                if paymentManager.isProcessingPayment {
                    processingView
                } else {
                    paymentButton
                }
                
                if let error = paymentManager.paymentError {
                    errorView(error)
                }
                
                if paymentManager.paymentSuccess {
                    successView
                }
            }
            .padding()
        }
        .navigationTitle("Payment")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Payment Result", isPresented: $showingPaymentResult) {
            Button("OK") {
                if isPaymentSuccessful {
                    // Handle successful payment navigation
                }
                paymentManager.resetPaymentState()
            }
        } message: {
            Text(paymentResultMessage)
        }
    }
    
    // MARK: - View Components
    
    private var paymentHeaderView: some View {
        VStack(spacing: 12) {
            Image(systemName: paymentType.icon)
                .font(.system(size: 48, weight: .medium))
                .foregroundColor(paymentType.color)
            
            Text(paymentType.displayName)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(paymentType.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var paymentSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let booking = booking {
                ServiceSummaryView(booking: booking, paymentType: paymentType)
            } else if let items = cartItems {
                ProductSummaryView(items: items, shipping: shippingOption)
            }
            
            Divider()
            
            HStack {
                Text("Amount Due")
                    .font(.headline)
                Spacer()
                Text(formattedAmount)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(paymentType.color)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var paymentMethodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Method")
                .font(.headline)
            
            HStack(spacing: 16) {
                Image(systemName: "creditcard.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Credit/Debit Card")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("Secure payment via Stripe")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(12)
        }
    }
    
    private var paymentButton: some View {
        Button(action: processPayment) {
            HStack(spacing: 12) {
                Image(systemName: "creditcard")
                    .font(.headline)
                Text("Pay \(formattedAmount)")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(paymentType.color)
            .cornerRadius(12)
        }
        .disabled(paymentManager.isProcessingPayment)
    }
    
    private var processingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Processing Payment...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var successView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
            
            Text("Payment Successful!")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
            
            Text("Your payment has been processed successfully.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundColor(.red)
            
            Text("Payment Error")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.red)
            
            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Computed Properties
    
    private var formattedAmount: String {
        let amount = calculatePaymentAmount()
        return String(format: "$%.2f", amount)
    }
    
    // MARK: - Helper Methods
    
    private func calculatePaymentAmount() -> Double {
        if let booking = booking {
            return paymentType.calculateAmount(for: booking.service)
        } else if let items = cartItems {
            let subtotal = items.reduce(0) { $0 + $1.totalPrice }
            return subtotal + (shippingOption?.price ?? 0.0)
        }
        return 0.0
    }
    
    private func processPayment() {
        if let booking = booking {
            processBookingPayment(booking)
        } else if let items = cartItems {
            processProductPayment(items)
        }
    }
    
    private func processBookingPayment(_ booking: Booking) {
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
    }
    
    private func processProductPayment(_ items: [CartItem]) {
        paymentManager.processProductPayment(for: items, shipping: shippingOption) { success, error in
            handlePaymentResult(success: success, error: error)
        }
    }
    
    private func handlePaymentResult(success: Bool, error: String?) {
        DispatchQueue.main.async {
            self.isPaymentSuccessful = success
            
            if success {
                self.paymentResultMessage = "Payment processed successfully!"
            } else {
                self.paymentResultMessage = error ?? "An unexpected error occurred."
            }
            
            self.showingPaymentResult = true
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
                    .foregroundColor(.secondary)
                Spacer()
                Text(booking.service.name)
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Business:")
                    .foregroundColor(.secondary)
                Spacer()
                Text(booking.business.name)
                    .fontWeight(.medium)
            }
            
            switch paymentType {
            case .deposit:
                HStack {
                    Text("Deposit Amount:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.2f", booking.service.calculatedDepositAmount))")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Remaining Balance:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.2f", booking.service.remainingBalance))")
                        .foregroundColor(.orange)
                }
                
            case .full:
                HStack {
                    Text("Full Payment:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.2f", booking.totalPrice))")
                        .fontWeight(.semibold)
                }
                
            case .remainingBalance:
                HStack {
                    Text("Deposit Paid:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.2f", booking.service.calculatedDepositAmount))")
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Remaining Balance:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.2f", booking.service.remainingBalance))")
                        .fontWeight(.semibold)
                }
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.id) { item in
                HStack {
                    Text("\(item.quantity)x \(item.product.name)")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.2f", item.totalPrice))")
                        .fontWeight(.medium)
                }
            }
            
            if let shipping = shipping {
                HStack {
                    Text("Shipping (\(shipping.name)):")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.2f", shipping.price))")
                        .fontWeight(.medium)
                }
            }
            
            Divider()
            
            HStack {
                Text("Subtotal:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("$\(String(format: "%.2f", subtotal))")
                    .fontWeight(.semibold)
            }
        }
        .font(.subheadline)
    }
}