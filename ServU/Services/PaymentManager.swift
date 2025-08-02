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
//  Created by Quian Bowden on 8/2/25.
//  Conflict-free payment management for ServU
//

import Foundation
import SwiftUI

// MARK: - Payment Manager (Conflict-Free)
@MainActor
class PaymentManager: ObservableObject {
    @Published var isProcessingPayment = false
    @Published var paymentError: String?
    @Published var showingPaymentSheet = false
    @Published var currentPaymentIntent: StripePaymentIntent?
    @Published var paymentSuccess = false
    
    private let stripeService = StripePaymentService()
    
    // MARK: - Service Payment Methods
    
    func processDepositPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        paymentSuccess = false
        
        print("✅ DEBUG: Starting deposit payment for \(booking.service.name)")
        
        stripeService.createDepositPaymentIntent(for: booking) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paymentIntent):
                    self?.currentPaymentIntent = paymentIntent
                    self?.showingPaymentSheet = true
                    self?.isProcessingPayment = false
                    
                    // For now, simulate success (will be replaced with real Stripe integration)
                    self?.simulatePaymentSuccess(completion: completion)
                    
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
        paymentSuccess = false
        
        print("✅ DEBUG: Starting full payment for \(booking.service.name)")
        
        stripeService.createFullPaymentIntent(for: booking) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paymentIntent):
                    self?.currentPaymentIntent = paymentIntent
                    self?.showingPaymentSheet = true
                    self?.isProcessingPayment = false
                    
                    // For now, simulate success (will be replaced with real Stripe integration)
                    self?.simulatePaymentSuccess(completion: completion)
                    
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
        paymentSuccess = false
        
        print("✅ DEBUG: Starting remaining balance payment for \(booking.service.name)")
        
        stripeService.createRemainingBalancePaymentIntent(for: booking) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paymentIntent):
                    self?.currentPaymentIntent = paymentIntent
                    self?.showingPaymentSheet = true
                    self?.isProcessingPayment = false
                    
                    // For now, simulate success (will be replaced with real Stripe integration)
                    self?.simulatePaymentSuccess(completion: completion)
                    
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
        paymentSuccess = false
        
        let productNames = cartItems.map { $0.product.name }.joined(separator: ", ")
        print("✅ DEBUG: Starting product payment for: \(productNames)")
        
        stripeService.createProductPaymentIntent(for: cartItems, shipping: shipping) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paymentIntent):
                    self?.currentPaymentIntent = paymentIntent
                    self?.showingPaymentSheet = true
                    self?.isProcessingPayment = false
                    
                    // For now, simulate success (will be replaced with real Stripe integration)
                    self?.simulatePaymentSuccess(completion: completion)
                    
                case .failure(let error):
                    self?.paymentError = error.localizedDescription
                    self?.isProcessingPayment = false
                    print("❌ DEBUG: Product payment failed: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func simulatePaymentSuccess(completion: @escaping (Bool, String?) -> Void) {
        // Simulate payment processing time
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.paymentSuccess = true
            self.showingPaymentSheet = false
            print("✅ DEBUG: Payment simulation completed successfully")
            completion(true, nil)
        }
    }
    
    // MARK: - Utility Methods
    
    func resetPaymentState() {
        isProcessingPayment = false
        paymentError = nil
        showingPaymentSheet = false
        currentPaymentIntent = nil
        paymentSuccess = false
    }
    
    func getPaymentStatusMessage() -> String {
        if isProcessingPayment {
            return "Processing payment..."
        } else if let error = paymentError {
            return "Payment error: \(error)"
        } else if paymentSuccess {
            return "Payment completed successfully!"
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

// MARK: - Service Payment Type Enum
enum ServUPaymentType {
    case deposit
    case full
    case remainingBalance
}