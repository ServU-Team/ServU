//
//  PaymentManagerProtocol.swift
//  ServU
//
//  Created by Amber Still on 8/4/25.
//


//
//  PaymentManager.swift
//  ServU
//
//  Created by Quian Bowden on 8/3/25.
//  Complete payment management system for ServU
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
class PaymentManager: PaymentManagerProtocol, ObservableObject {
    @Published var isProcessingPayment = false
    @Published var paymentError: String?
    @Published var paymentSuccess = false
    
    private let stripeService = StripePaymentService()
    
    // MARK: - Service Payment Methods
    
    func processDepositPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        updatePaymentState(processing: true, error: nil, success: false)
        
        let amount = booking.service.calculatedDepositAmount
        
        stripeService.createPaymentIntent(
            amount: amount,
            currency: "usd",
            description: "Deposit for \(booking.service.name)"
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.updatePaymentState(processing: false, error: nil, success: true)
                    completion(true, nil)
                case .failure(let error):
                    self?.updatePaymentState(processing: false, error: error.localizedDescription, success: false)
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    func processFullPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        updatePaymentState(processing: true, error: nil, success: false)
        
        let amount = booking.totalPrice
        
        stripeService.createPaymentIntent(
            amount: amount,
            currency: "usd",
            description: "Full payment for \(booking.service.name)"
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.updatePaymentState(processing: false, error: nil, success: true)
                    completion(true, nil)
                case .failure(let error):
                    self?.updatePaymentState(processing: false, error: error.localizedDescription, success: false)
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    func processRemainingBalancePayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        updatePaymentState(processing: true, error: nil, success: false)
        
        let amount = booking.service.remainingBalance
        
        stripeService.createPaymentIntent(
            amount: amount,
            currency: "usd",
            description: "Remaining balance for \(booking.service.name)"
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.updatePaymentState(processing: false, error: nil, success: true)
                    completion(true, nil)
                case .failure(let error):
                    self?.updatePaymentState(processing: false, error: error.localizedDescription, success: false)
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Product Payment Methods
    
    func processProductPayment(for items: [CartItem], shipping: ShippingOption?, completion: @escaping (Bool, String?) -> Void) {
        updatePaymentState(processing: true, error: nil, success: false)
        
        let subtotal = items.reduce(0) { $0 + $1.totalPrice }
        let totalAmount = subtotal + (shipping?.price ?? 0.0)
        
        let productNames = items.map { "\($0.quantity)x \($0.displayName)" }.joined(separator: ", ")
        let description = "Purchase: \(productNames)"
        
        stripeService.createPaymentIntent(
            amount: totalAmount,
            currency: "usd",
            description: description
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.updatePaymentState(processing: false, error: nil, success: true)
                    completion(true, nil)
                case .failure(let error):
                    self?.updatePaymentState(processing: false, error: error.localizedDescription, success: false)
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - State Management
    
    func resetPaymentState() {
        updatePaymentState(processing: false, error: nil, success: false)
    }
    
    private func updatePaymentState(processing: Bool, error: String?, success: Bool) {
        isProcessingPayment = processing
        paymentError = error
        paymentSuccess = success
    }
}

// MARK: - Stripe Payment Service
class StripePaymentService {
    enum PaymentError: Error {
        case invalidAmount
        case paymentFailed(String)
        case networkError
        
        var localizedDescription: String {
            switch self {
            case .invalidAmount:
                return "Invalid payment amount"
            case .paymentFailed(let message):
                return message
            case .networkError:
                return "Network connection error"
            }
        }
    }
    
    func createPaymentIntent(
        amount: Double,
        currency: String,
        description: String,
        completion: @escaping (Result<String, PaymentError>) -> Void
    ) {
        // Simulate payment processing for now
        // Replace this with actual Stripe integration when ready
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            // For demo purposes, randomly succeed or fail
            let success = Double.random(in: 0...1) > 0.1 // 90% success rate
            
            if success {
                let paymentIntentId = "pi_\(UUID().uuidString.prefix(24))"
                completion(.success(paymentIntentId))
            } else {
                completion(.failure(.paymentFailed("Payment was declined")))
            }
        }
    }
}

// MARK: - Payment Types
enum ServUPaymentType: String, CaseIterable {
    case deposit = "deposit"
    case full = "full"
    case remainingBalance = "remaining_balance"
    
    var displayName: String {
        switch self {
        case .deposit:
            return "Deposit"
        case .full:
            return "Full Payment"
        case .remainingBalance:
            return "Remaining Balance"
        }
    }
    
    var description: String {
        switch self {
        case .deposit:
            return "Pay a deposit to secure your booking"
        case .full:
            return "Pay the full amount upfront"
        case .remainingBalance:
            return "Pay the remaining balance due"
        }
    }
}