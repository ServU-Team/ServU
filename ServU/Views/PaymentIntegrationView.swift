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
//  Payment integration view for ServU services and products with proper type handling
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
    
    init(for cartItems: [CartItem], shipping: ShippingOption?) {
        self.booking = nil
        self.cartItems = cartItems
        self.shippingOption = shipping
        self.paymentType = .full // Products always use full payment
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            paymentHeaderView
            paymentAmountView
            paymentMethodSection
            
            if paymentManager.isProcessingPayment {
                processingView
            } else {
                paymentButton
            }
            
            if let error = paymentManager.paymentError {
                errorView(error)
            }
        }
        .padding()
        .navigationTitle("Payment")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Payment Result", isPresented: $showingPaymentResult) {
            Button("OK") {
                if isPaymentSuccessful {
                    // Handle successful payment navigation
                }
            }
        } message: {
            Text(paymentResultMessage)
        }
    }
    
    // MARK: - View Components
    
    private var paymentHeaderView: some View {
        VStack(spacing: 8) {
            Image(systemName: paymentType.icon)
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text(paymentType.displayName)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(paymentType.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var paymentAmountView: some View {
        VStack(spacing: 12) {
            Text("Amount Due")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(formattedAmount)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var paymentMethodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Method")
                .font(.headline)
            
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text("Credit/Debit Card")
                        .fontWeight(.medium)
                    Text("Secure payment via Stripe")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 1)
            )
        }
    }
    
    private var paymentButton: some View {
        Button(action: processPayment) {
            HStack {
                Image(systemName: "creditcard")
                Text("Pay \(formattedAmount)")
            }
            .foregroundColor(.white)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
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
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .font(.title2)
            
            Text("Payment Error")
                .font(.headline)
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
            switch paymentType {
            case .deposit:
                return booking.service.calculatedDepositAmount
            case .full:
                return booking.totalPrice
            case .remainingBalance:
                return booking.service.remainingBalance
            }
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
            paymentManager.processDepositPayment(for: booking) { [weak self] (success: Bool, error: String?) in
                self?.handlePaymentResult(success: success, error: error)
            }
        case .full:
            paymentManager.processFullPayment(for: booking) { [weak self] (success: Bool, error: String?) in
                self?.handlePaymentResult(success: success, error: error)
            }
        case .remainingBalance:
            paymentManager.processRemainingBalancePayment(for: booking) { [weak self] (success: Bool, error: String?) in
                self?.handlePaymentResult(success: success, error: error)
            }
        }
    }
    
    private func processProductPayment(_ items: [CartItem]) {
        paymentManager.processProductPayment(for: items, shipping: shippingOption) { [weak self] (success: Bool, error: String?) in
            self?.handlePaymentResult(success: success, error: error)
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