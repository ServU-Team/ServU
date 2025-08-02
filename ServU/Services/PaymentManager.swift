//
//  PaymentManager.swift
//  ServU
//
//  Created by Amber Still on 8/2/25.
//


//
//  PaymentManager.swift
//  ServU
//
//  Created by Quian Bowden on 7/31/25.
//  Enhanced with real Stripe Payment Sheet integration
//

import Foundation
import SwiftUI
import StripePaymentSheet

// MARK: - Payment Manager (Enhanced with Real Stripe Integration)
@MainActor
class PaymentManager: ObservableObject {
    @Published var isProcessingPayment = false
    @Published var paymentError: String?
    @Published var showingPaymentSheet = false
    @Published var currentPaymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    
    private let stripeService = StripePaymentService()
    
    // MARK: - Service Payment Methods
    
    func processDepositPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        
        print("✅ DEBUG: Starting deposit payment for \(booking.service.name)")
        
        stripeService.createDepositPaymentIntent(for: booking) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paymentSheet):
                    self?.currentPaymentSheet = paymentSheet
                    self?.showingPaymentSheet = true
                    self?.isProcessingPayment = false
                    
                    // The payment sheet will be presented by the view
                    // Completion will be handled in onPaymentCompletion
                    
                case .failure(let error):
                    self?.paymentError = error.localizedDescription
                    self?.isProcessingPayment = false
                    print("❌ DEBUG: Deposit payment failed: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    func processFullPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        
        print("✅ DEBUG: Starting full payment for \(booking.service.name)")
        
        stripeService.createFullPaymentIntent(for: booking) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paymentSheet):
                    self?.currentPaymentSheet = paymentSheet
                    self?.showingPaymentSheet = true
                    self?.isProcessingPayment = false
                    
                case .failure(let error):
                    self?.paymentError = error.localizedDescription
                    self?.isProcessingPayment = false
                    print("❌ DEBUG: Full payment failed: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    func processRemainingBalancePayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        
        print("✅ DEBUG: Starting remaining balance payment for \(booking.service.name)")
        
        stripeService.createRemainingBalancePaymentIntent(for: booking) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paymentSheet):
                    self?.currentPaymentSheet = paymentSheet
                    self?.showingPaymentSheet = true
                    self?.isProcessingPayment = false
                    
                case .failure(let error):
                    self?.paymentError = error.localizedDescription
                    self?.isProcessingPayment = false
                    print("❌ DEBUG: Remaining balance payment failed: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Product Payment Methods
    
    func processProductPayment(for cartItems: [CartItem], shipping: ShippingOption?, completion: @escaping (Bool, String?) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        
        let productNames = cartItems.map { $0.product.name }.joined(separator: ", ")
        print("✅ DEBUG: Starting product payment for: \(productNames)")
        
        stripeService.createProductPaymentIntent(for: cartItems, shipping: shipping) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paymentSheet):
                    self?.currentPaymentSheet = paymentSheet
                    self?.showingPaymentSheet = true
                    self?.isProcessingPayment = false
                    
                case .failure(let error):
                    self?.paymentError = error.localizedDescription
                    self?.isProcessingPayment = false
                    print("❌ DEBUG: Product payment failed: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Payment Sheet Handling
    
    func onPaymentCompletion(result: PaymentSheetResult) {
        paymentResult = result
        showingPaymentSheet = false
        
        switch result {
        case .completed:
            print("✅ Payment completed successfully")
            // Handle successful payment
            handlePaymentSuccess()
            
        case .canceled:
            print("⚠️ Payment was canceled")
            paymentError = "Payment was canceled"
            
        case .failed(let error):
            print("❌ Payment failed: \(error)")
            paymentError = error.localizedDescription
        }
    }
    
    private func handlePaymentSuccess() {
        // Update local state, sync with backend, etc.
        // This will be expanded when we implement webhooks
        paymentError = nil
        
        // You can add additional success handling here
        // For example, updating booking status, sending confirmations, etc.
    }
    
    // MARK: - Utility Methods
    
    func resetPaymentState() {
        isProcessingPayment = false
        paymentError = nil
        showingPaymentSheet = false
        currentPaymentSheet = nil
        paymentResult = nil
    }
    
    func getPaymentStatusMessage() -> String {
        if isProcessingPayment {
            return "Processing payment..."
        } else if let error = paymentError {
            return "Payment error: \(error)"
        } else if let result = paymentResult {
            switch result {
            case .completed:
                return "Payment completed successfully!"
            case .canceled:
                return "Payment was canceled"
            case .failed(let error):
                return "Payment failed: \(error.localizedDescription)"
            }
        } else {
            return "Ready to process payment"
        }
    }
    
    // MARK: - Fee Calculations
    
    func calculateTotalWithFees(for amount: Double) -> (subtotal: Double, platformFee: Double, stripeFee: Double, total: Double) {
        let platformFee = PlatformFeeConfig.calculatePlatformFee(for: amount)
        let stripeFee = PlatformFeeConfig.calculateStripeFee(for: amount)
        let total = amount + platformFee + stripeFee
        
        return (subtotal: amount, platformFee: platformFee, stripeFee: stripeFee, total: total)
    }
    
    func calculateBusinessPayout(for amount: Double) -> Double {
        return PlatformFeeConfig.calculateBusinessPayout(for: amount)
    }
}

// MARK: - Payment Sheet Wrapper View
struct PaymentSheetWrapper: UIViewControllerRepresentable {
    @Binding var paymentSheet: PaymentSheet?
    @Binding var showingPaymentSheet: Bool
    let onCompletion: (PaymentSheetResult) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if showingPaymentSheet, let paymentSheet = paymentSheet {
            paymentSheet.present(from: uiViewController) { [weak uiViewController] result in
                DispatchQueue.main.async {
                    self.onCompletion(result)
                }
            }
        }
    }
}

// MARK: - SwiftUI Integration Extension
extension View {
    func paymentSheet(
        isPresented: Binding<Bool>,
        paymentSheet: Binding<PaymentSheet?>,
        onCompletion: @escaping (PaymentSheetResult) -> Void
    ) -> some View {
        self.background(
            PaymentSheetWrapper(
                paymentSheet: paymentSheet,
                showingPaymentSheet: isPresented,
                onCompletion: onCompletion
            )
        )
    }
}