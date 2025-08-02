//
//  PaymentOption.swift
//  ServU
//
//  Created by Amber Still on 8/2/25.
//


//
//  PaymentIntegrationView.swift
//  ServU
//
//  Created by Quian Bowden on 8/2/25.
//  Minimal payment integration view for ServU
//

import SwiftUI

// MARK: - Payment Type
enum PaymentOption {
    case deposit
    case full
    case remaining
}

// MARK: - Payment Integration View
struct PaymentIntegrationView: View {
    @StateObject private var paymentManager = SimplePaymentManager()
    @State private var showingResult = false
    @State private var resultMessage = ""
    
    let booking: Booking
    let paymentOption: PaymentOption
    
    init(for booking: Booking, type: PaymentOption) {
        self.booking = booking
        self.paymentOption = type
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Payment Summary
            paymentSummaryCard
            
            // Payment Button
            paymentButton
            
            // Status Messages
            if paymentManager.isProcessingPayment {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Processing payment...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            if let error = paymentManager.paymentError {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
            
            if paymentManager.paymentSuccess {
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
        .alert("Payment Result", isPresented: $showingResult) {
            Button("OK") { 
                paymentManager.resetPaymentState()
            }
        } message: {
            Text(resultMessage)
        }
    }
    
    // MARK: - Subviews
    
    private var paymentSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Service:")
                    Spacer()
                    Text(booking.service.name)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Amount:")
                    Spacer()
                    Text("$\(String(format: "%.2f", paymentAmount))")
                        .fontWeight(.semibold)
                        .foregroundColor(.servURed)
                }
                
                if paymentOption == .deposit {
                    HStack {
                        Text("Remaining:")
                        Spacer()
                        Text("$\(String(format: "%.2f", booking.service.remainingBalance))")
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Total Service:")
                    Spacer()
                    Text("$\(String(format: "%.2f", booking.service.price))")
                        .fontWeight(.semibold)
                }
            }
            .font(.subheadline)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var paymentButton: some View {
        Button(action: processPayment) {
            HStack {
                if paymentManager.isProcessingPayment {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(buttonTitle)
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
    }
    
    // MARK: - Computed Properties
    
    private var paymentAmount: Double {
        switch paymentOption {
        case .deposit:
            return booking.service.calculatedDepositAmount
        case .full:
            return booking.totalPrice
        case .remaining:
            return booking.service.remainingBalance
        }
    }
    
    private var buttonTitle: String {
        switch paymentOption {
        case .deposit:
            return "Pay Deposit ($\(String(format: "%.2f", paymentAmount)))"
        case .full:
            return "Pay Full Amount ($\(String(format: "%.2f", paymentAmount)))"
        case .remaining:
            return "Pay Balance ($\(String(format: "%.2f", paymentAmount)))"
        }
    }
    
    // MARK: - Actions
    
    private func processPayment() {
        switch paymentOption {
        case .deposit:
            paymentManager.processDepositPayment(for: booking) { success, error in
                handlePaymentResult(success: success, error: error)
            }
        case .full:
            paymentManager.processFullPayment(for: booking) { success, error in
                handlePaymentResult(success: success, error: error)
            }
        case .remaining:
            paymentManager.processRemainingBalance(for: booking) { success, error in
                handlePaymentResult(success: success, error: error)
            }
        }
    }
    
    private func handlePaymentResult(success: Bool, error: String?) {
        if success {
            resultMessage = "Payment completed successfully!"
        } else {
            resultMessage = error ?? "Payment failed. Please try again."
        }
        showingResult = true
    }
}

// MARK: - Preview
struct PaymentIntegrationView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentIntegrationView(
            for: sampleBooking,
            type: .deposit
        )
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    static var sampleBooking: Booking {
        let service = Service(
            name: "Photography Session",
            description: "Professional photos",
            price: 150.0,
            duration: "2 hours",
            isAvailable: true,
            requiresDeposit: true,
            depositAmount: 50.0,
            depositType: .fixed,
            depositPolicy: "Required"
        )
        
        let business = Business(
            name: "Photo Studio",
            category: .photoVideo,
            description: "Professional photography",
            rating: 4.8,
            priceRange: .moderate,
            imageURL: "",
            isActive: true,
            location: "Campus",
            contactInfo: ContactInfo(email: "test@test.com", phone: "555-1234"),
            services: [],
            availability: BusinessHours.defaultHours
        )
        
        return Booking(
            id: UUID(),
            service: service,
            business: business,
            customerName: "Test User",
            customerEmail: "test@test.com",
            customerPhone: "555-1234",
            appointmentDate: Date(),
            startTime: Date(),
            endTime: Date().addingTimeInterval(7200),
            status: .confirmed,
            notes: "",
            totalPrice: 150.0,
            paymentStatus: .pending,
            createdAt: Date(),
            depositTransactionId: nil
        )
    }
}