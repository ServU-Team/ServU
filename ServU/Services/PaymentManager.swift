//
//  definition.swift
//  ServU
//
//  Created by Amber Still on 8/4/25.
//


//
//  PaymentManagerProtocol.swift
//  ServU
//
//  Created by Quian Bowden on 8/4/25.
//  Clean protocol definition without duplicates
//

import Foundation
import SwiftUI

// MARK: - Payment Manager Protocol
protocol PaymentManagerProtocol: ObservableObject {
    var isProcessingPayment: Bool { get }
    var paymentError: String? { get }
    var paymentSuccess: Bool { get }
    
    func processDepositPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void)
    func processFullPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void)
    func processRemainingBalancePayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void)
    func processProductPayment(for items: [CartItem], shipping: ShippingOption?, completion: @escaping (Bool, String?) -> Void)
    func resetPaymentState()
}

// MARK: - Payment Manager Implementation
@MainActor
class PaymentManager: PaymentManagerProtocol {
    @Published var isProcessingPayment = false
    @Published var paymentError: String?
    @Published var paymentSuccess = false
    
    private let stripeService = StripePaymentService()
    
    // MARK: - Service Payment Methods
    
    func processDepositPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        paymentSuccess = false
        
        let amount = booking.service.calculatedDepositAmount
        
        stripeService.createPaymentIntent(
            amount: amount,
            currency: "usd",
            description: "Deposit for \(booking.service.name)"
        ) { result in
            DispatchQueue.main.async {
                self.isProcessingPayment = false
                switch result {
                case .success(_):
                    self.paymentSuccess = true
                    completion(true, nil)
                case .failure(let error):
                    self.paymentError = error.localizedDescription
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    func processFullPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        paymentSuccess = false
        
        let amount = booking.totalPrice
        
        stripeService.createPaymentIntent(
            amount: amount,
            currency: "usd",
            description: "Full payment for \(booking.service.name)"
        ) { result in
            DispatchQueue.main.async {
                self.isProcessingPayment = false
                switch result {
                case .success(_):
                    self.paymentSuccess = true
                    completion(true, nil)
                case .failure(let error):
                    self.paymentError = error.localizedDescription
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    func processRemainingBalancePayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        paymentSuccess = false
        
        let amount = booking.service.remainingBalance
        
        stripeService.createPaymentIntent(
            amount: amount,
            currency: "usd",
            description: "Remaining balance for \(booking.service.name)"
        ) { result in
            DispatchQueue.main.async {
                self.isProcessingPayment = false
                switch result {
                case .success(_):
                    self.paymentSuccess = true
                    completion(true, nil)
                case .failure(let error):
                    self.paymentError = error.localizedDescription
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    func processProductPayment(for items: [CartItem], shipping: ShippingOption?, completion: @escaping (Bool, String?) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        paymentSuccess = false
        
        let subtotal = items.reduce(0) { $0 + $1.totalPrice }
        let totalAmount = subtotal + (shipping?.price ?? 0.0)
        
        let description = "Purchase of \(items.count) item(s)"
        
        stripeService.createPaymentIntent(
            amount: totalAmount,
            currency: "usd",
            description: description
        ) { result in
            DispatchQueue.main.async {
                self.isProcessingPayment = false
                switch result {
                case .success(_):
                    self.paymentSuccess = true
                    completion(true, nil)
                case .failure(let error):
                    self.paymentError = error.localizedDescription
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - State Management
    func resetPaymentState() {
        isProcessingPayment = false
        paymentError = nil
        paymentSuccess = false
    }
}

// MARK: - Stripe Payment Service
class StripePaymentService: ObservableObject {
    
    @Published var isProcessingPayment = false
    @Published var paymentError: String?
    
    func createPaymentIntent(
        amount: Double,
        currency: String,
        description: String,
        completion: @escaping (Result<String, PaymentError>) -> Void
    ) {
        guard amount > 0 else {
            completion(.failure(.invalidAmount))
            return
        }
        
        isProcessingPayment = true
        paymentError = nil
        
        print("✅ DEBUG: Creating payment intent for amount: $\(amount)")
        
        // Simulate payment processing
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            let success = Double.random(in: 0...1) > 0.1 // 90% success rate
            
            DispatchQueue.main.async {
                self.isProcessingPayment = false
                
                if success {
                    let paymentIntentId = "pi_\(UUID().uuidString.prefix(24))"
                    print("✅ DEBUG: Payment intent created successfully: \(paymentIntentId)")
                    completion(.success(paymentIntentId))
                } else {
                    let error = PaymentError.paymentFailed("Payment was declined")
                    self.paymentError = error.localizedDescription
                    print("❌ DEBUG: Payment intent creation failed")
                    completion(.failure(error))
                }
            }
        }
    }
}