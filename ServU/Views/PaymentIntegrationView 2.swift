//
//  PaymentIntegrationView 2.swift
//  ServU
//
//  Created by Amber Still on 8/2/25.
//


//
//  PaymentIntegrationView.swift
//  ServU
//
//  Created by Quian Bowden on 8/2/25.
//  Payment integration view component for Stripe payments
//

import SwiftUI
import StripePaymentSheet

// MARK: - Payment Integration View
struct PaymentIntegrationView: View {
    @StateObject private var paymentManager = PaymentManager()
    @State private var showingPaymentResult = false
    @State private var paymentResultMessage = ""
    
    let booking: Booking?
    let cartItems: [CartItem]?
    let shippingOption: ShippingOption?
    let paymentType: PaymentType
    
    enum PaymentType {
        case deposit(Booking)
        case fullPayment(Booking)
        case remainingBalance(Booking)
        case productPurchase([CartItem], ShippingOption?)
    }
    
    // MARK: - Initializers
    
    init(for booking: Booking, type: ServicePaymentType) {
        self.booking = booking
        self.cartItems = nil
        self.shippingOption = nil
        
        switch type {
        case .deposit:
            self.paymentType = .deposit(booking)
        case .full:
            self.paymentType = .fullPayment(booking)
        case .remainingBalance:
            self.paymentType = .remainingBalance(booking)
        }
    }
    
    init(for cartItems: [CartItem], shipping: ShippingOption? = nil) {
        self.booking = nil
        self.cartItems = cartItems
        self.shippingOption = shipping
        self.paymentType = .productPurchase(cartItems, shipping)
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
        }
        .paymentSheet(
            isPresented: $paymentManager.showingPaymentSheet,
            paymentSheet: $paymentManager.currentPaymentSheet,
            onCompletion: { result in
                paymentManager.onPaymentCompletion(result: result)
                handlePaymentResult(result)
            }
        )
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
            
            switch paymentType {
            case .deposit(let booking):
                DepositSummaryView(booking: booking)
            case .fullPayment(let booking):
                FullPaymentSummaryView(booking: booking)
            case .remainingBalance(let booking):
                RemainingBalanceSummaryView(booking: booking)
            case .productPurchase(let items, let shipping):
                ProductSummaryView(items: items, shipping: shipping)
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
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.servURed, Color.servURed.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .disabled(paymentManager.isProcessingPayment)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(paymentManager.isProcessingPayment ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: paymentManager.isProcessingPayment)
    }
    
    private var paymentButtonTitle: String {
        switch paymentType {
        case .deposit:
            return "Pay Deposit"
        case .fullPayment:
            return "Pay Full Amount"
        case .remainingBalance:
            return "Pay Remaining Balance"
        case .productPurchase:
            return "Complete Purchase"
        }
    }
    
    // MARK: - Payment Actions
    
    private func initiatePayment() {
        switch paymentType {
        case .deposit(let booking):
            paymentManager.processDepositPayment(for: booking) { success, error in
                if !success {
                    handlePaymentError(error)
                }
            }
            
        case .fullPayment(let booking):
            paymentManager.processFullPayment(for: booking) { success, error in
                if !success {
                    handlePaymentError(error)
                }
            }
            
        case .remainingBalance(let booking):
            paymentManager.processRemainingBalancePayment(for: booking) { success, error in
                if !success {
                    handlePaymentError(error)
                }
            }
            
        case .productPurchase(let items, let shipping):
            paymentManager.processProductPayment(for: items, shipping: shipping) { success, error in
                if !success {
                    handlePaymentError(error)
                }
            }
        }
    }
    
    private func handlePaymentResult(_ result: PaymentSheetResult) {
        switch result {
        case .completed:
            paymentResultMessage = "Payment completed successfully!"
            showingPaymentResult = true
            
        case .canceled:
            paymentResultMessage = "Payment was canceled."
            showingPaymentResult = true
            
        case .failed(let error):
            paymentResultMessage = "Payment failed: \(error.localizedDescription)"
            showingPaymentResult = true
        }
    }
    
    private func handlePaymentError(_ error: String?) {
        paymentResultMessage = error ?? "An unknown error occurred"
        showingPaymentResult = true
    }
}

// MARK: - Service Payment Type
enum ServicePaymentType {
    case deposit
    case full
    case remainingBalance
}

// MARK: - Summary Views

struct DepositSummaryView: View {
    let booking: Booking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Service:")
                Spacer()
                Text(booking.service.name)
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Deposit Amount:")
                Spacer()
                Text("$\(booking.service.calculatedDepositAmount, specifier: "%.2f")")
                    .fontWeight(.semibold)
                    .foregroundColor(.servURed)
            }
            
            HStack {
                Text("Remaining Balance:")
                Spacer()
                Text("$\(booking.service.remainingBalance, specifier: "%.2f")")
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            HStack {
                Text("Total Service Cost:")
                Spacer()
                Text("$\(booking.service.price, specifier: "%.2f")")
                    .fontWeight(.semibold)
            }
        }
        .font(.subheadline)
    }
}

struct FullPaymentSummaryView: View {
    let booking: Booking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Service:")
                Spacer()
                Text(booking.service.name)
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Full Payment:")
                Spacer()
                Text("$\(booking.totalPrice, specifier: "%.2f")")
                    .fontWeight(.semibold)
                    .foregroundColor(.servURed)
            }
        }
        .font(.subheadline)
    }
}

struct RemainingBalanceSummaryView: View {
    let booking: Booking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Service:")
                Spacer()
                Text(booking.service.name)
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Deposit Paid:")
                Spacer()
                Text("$\(booking.service.calculatedDepositAmount, specifier: "%.2f")")
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Remaining Balance:")
                Spacer()
                Text("$\(booking.service.remainingBalance, specifier: "%.2f")")
                    .fontWeight(.semibold)
                    .foregroundColor(.servURed)
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
                    Text("$\(item.totalPrice, specifier: "%.2f")")
                        .fontWeight(.medium)
                }
            }
            
            if let shipping = shipping {
                HStack {
                    Text("Shipping (\(shipping.name)):")
                    Spacer()
                    Text("$\(shipping.price, specifier: "%.2f")")
                        .fontWeight(.medium)
                }
            }
            
            Divider()
            
            HStack {
                Text("Total:")
                Spacer()
                Text("$\(total, specifier: "%.2f")")
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

// MARK: - Color Extension (if not already defined)
extension Color {
    static let servURed = Color(red: 0.85, green: 0.17, blue: 0.25)
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
        Booking(
            id: UUID(),
            service: Service(
                name: "Portrait Photography",
                description: "Professional portrait session",
                price: 150.0,
                duration: "2 hours",
                isAvailable: true,
                requiresDeposit: true,
                depositAmount: 50.0,
                depositType: .fixed,
                depositPolicy: "50% deposit required"
            ),
            business: Business.sampleBusiness,
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

extension Business {
    static var sampleBusiness: Business {
        Business(
            id: UUID(),
            name: "Sample Photography",
            description: "Professional photography services",
            category: .photoVideo,
            priceRange: .moderate,
            rating: 4.8,
            reviewCount: 24,
            profileImageURL: "",
            isActive: true,
            location: "Campus Area",
            contactInfo: ContactInfo(email: "info@example.com", phone: "(555) 123-4567"),
            services: [],
            availability: BusinessHours.allDay
        )
    }
}