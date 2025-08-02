//
//  StripePaymentService.swift
//  ServU
//
//  Created by Amber Still on 8/2/25.
//


//
//  StripePaymentService.swift
//  ServU
//
//  Created by Quian Bowden on 8/1/25.
//  Real Stripe payment integration for ServU platform
//

import Foundation
import SwiftUI

// MARK: - Stripe Payment Service
class StripePaymentService: ObservableObject {
    
    // MARK: - Properties
    @Published var isProcessingPayment = false
    @Published var paymentError: String?
    @Published var lastPaymentIntent: PaymentIntent?
    
    // Stripe Configuration
    private let stripePublishableKey = "pk_test_YOUR_PUBLISHABLE_KEY" // Replace with your key
    private let baseURL = "YOUR_BACKEND_URL" // Replace with your backend URL
    
    // MARK: - Payment Intent Creation
    
    /// Creates a payment intent for deposit payment
    func createDepositPaymentIntent(for booking: Booking, completion: @escaping (Result<PaymentIntent, PaymentError>) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        
        let depositAmount = booking.service.calculatedDepositAmount
        let amountInCents = Int(depositAmount * 100) // Stripe uses cents
        
        let paymentData: [String: Any] = [
            "amount": amountInCents,
            "currency": "usd",
            "payment_method_types": ["card"],
            "metadata": [
                "booking_id": booking.id.uuidString,
                "customer_email": booking.customerEmail,
                "service_name": booking.service.name,
                "business_name": booking.business.name,
                "payment_type": "deposit"
            ]
        ]
        
        createPaymentIntent(with: paymentData) { result in
            DispatchQueue.main.async {
                self.isProcessingPayment = false
                completion(result)
            }
        }
    }
    
    /// Creates a payment intent for full payment
    func createFullPaymentIntent(for booking: Booking, completion: @escaping (Result<PaymentIntent, PaymentError>) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        
        let totalAmount = booking.totalPrice
        let amountInCents = Int(totalAmount * 100)
        
        let paymentData: [String: Any] = [
            "amount": amountInCents,
            "currency": "usd",
            "payment_method_types": ["card"],
            "metadata": [
                "booking_id": booking.id.uuidString,
                "customer_email": booking.customerEmail,
                "service_name": booking.service.name,
                "business_name": booking.business.name,
                "payment_type": "full_payment"
            ]
        ]
        
        createPaymentIntent(with: paymentData) { result in
            DispatchQueue.main.async {
                self.isProcessingPayment = false
                completion(result)
            }
        }
    }
    
    /// Creates a payment intent for remaining balance
    func createRemainingBalancePaymentIntent(for booking: Booking, completion: @escaping (Result<PaymentIntent, PaymentError>) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        
        let remainingAmount = booking.service.remainingBalance
        let amountInCents = Int(remainingAmount * 100)
        
        let paymentData: [String: Any] = [
            "amount": amountInCents,
            "currency": "usd",
            "payment_method_types": ["card"],
            "metadata": [
                "booking_id": booking.id.uuidString,
                "customer_email": booking.customerEmail,
                "service_name": booking.service.name,
                "business_name": booking.business.name,
                "payment_type": "remaining_balance"
            ]
        ]
        
        createPaymentIntent(with: paymentData) { result in
            DispatchQueue.main.async {
                self.isProcessingPayment = false
                completion(result)
            }
        }
    }
    
    // MARK: - Product Payment Intent
    
    /// Creates a payment intent for product purchases
    func createProductPaymentIntent(for cartItems: [CartItem], shipping: ShippingOption?, completion: @escaping (Result<PaymentIntent, PaymentError>) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        
        let subtotal = cartItems.reduce(0) { $0 + $1.totalPrice }
        let shippingCost = shipping?.price ?? 0.0
        let totalAmount = subtotal + shippingCost
        let amountInCents = Int(totalAmount * 100)
        
        let itemsMetadata = cartItems.map { item in
            return [
                "product_name": item.product.name,
                "variant": item.selectedVariant?.displayName ?? "Default",
                "quantity": item.quantity,
                "unit_price": item.unitPrice
            ]
        }
        
        let paymentData: [String: Any] = [
            "amount": amountInCents,
            "currency": "usd",
            "payment_method_types": ["card"],
            "metadata": [
                "payment_type": "product_purchase",
                "item_count": cartItems.count,
                "subtotal": subtotal,
                "shipping_cost": shippingCost,
                "shipping_method": shipping?.name ?? "None"
            ]
        ]
        
        createPaymentIntent(with: paymentData) { result in
            DispatchQueue.main.async {
                self.isProcessingPayment = false
                completion(result)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func createPaymentIntent(with data: [String: Any], completion: @escaping (Result<PaymentIntent, PaymentError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/create-payment-intent") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data)
        } catch {
            completion(.failure(.invalidRequest))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let paymentIntent = try JSONDecoder().decode(PaymentIntent.self, from: data)
                completion(.success(paymentIntent))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    // MARK: - Payment Confirmation
    
    /// Confirms a payment intent after user provides payment method
    func confirmPayment(intentId: String, paymentMethodId: String, completion: @escaping (Result<PaymentConfirmation, PaymentError>) -> Void) {
        isProcessingPayment = true
        
        guard let url = URL(string: "\(baseURL)/confirm-payment") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let confirmData: [String: Any] = [
            "payment_intent_id": intentId,
            "payment_method_id": paymentMethodId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: confirmData)
        } catch {
            completion(.failure(.invalidRequest))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isProcessingPayment = false
                
                if let error = error {
                    completion(.failure(.networkError(error.localizedDescription)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let confirmation = try JSONDecoder().decode(PaymentConfirmation.self, from: data)
                    completion(.success(confirmation))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    // MARK: - Refunds
    
    /// Creates a refund for a payment
    func createRefund(paymentIntentId: String, amount: Double? = nil, reason: RefundReason = .requestedByCustomer, completion: @escaping (Result<RefundResponse, PaymentError>) -> Void) {
        isProcessingPayment = true
        
        guard let url = URL(string: "\(baseURL)/create-refund") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var refundData: [String: Any] = [
            "payment_intent": paymentIntentId,
            "reason": reason.rawValue
        ]
        
        if let amount = amount {
            refundData["amount"] = Int(amount * 100) // Convert to cents
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: refundData)
        } catch {
            completion(.failure(.invalidRequest))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isProcessingPayment = false
                
                if let error = error {
                    completion(.failure(.networkError(error.localizedDescription)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let refund = try JSONDecoder().decode(RefundResponse.self, from: data)
                    completion(.success(refund))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
}

// MARK: - Payment Models

struct PaymentIntent: Codable {
    let id: String
    let clientSecret: String
    let amount: Int
    let currency: String
    let status: String
    let created: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case id
        case clientSecret = "client_secret"
        case amount
        case currency
        case status
        case created
    }
}

struct PaymentConfirmation: Codable {
    let id: String
    let status: String
    let amount: Int
    let currency: String
    let paymentMethod: PaymentMethodDetails?
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case amount
        case currency
        case paymentMethod = "payment_method"
    }
}

struct PaymentMethodDetails: Codable {
    let id: String
    let type: String
    let card: CardDetails?
}

struct CardDetails: Codable {
    let brand: String
    let last4: String
    let expMonth: Int
    let expYear: Int
    
    enum CodingKeys: String, CodingKey {
        case brand
        case last4
        case expMonth = "exp_month"
        case expYear = "exp_year"
    }
}

struct RefundResponse: Codable {
    let id: String
    let amount: Int
    let currency: String
    let status: String
    let reason: String?
    let created: TimeInterval
}

enum RefundReason: String, CaseIterable {
    case duplicate = "duplicate"
    case fraudulent = "fraudulent"
    case requestedByCustomer = "requested_by_customer"
    
    var displayName: String {
        switch self {
        case .duplicate: return "Duplicate Payment"
        case .fraudulent: return "Fraudulent"
        case .requestedByCustomer: return "Customer Request"
        }
    }
}

enum PaymentError: Error, LocalizedError {
    case invalidURL
    case invalidRequest
    case networkError(String)
    case noData
    case decodingError
    case paymentFailed(String)
    case insufficientFunds
    case cardDeclined
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid payment URL"
        case .invalidRequest:
            return "Invalid payment request"
        case .networkError(let message):
            return "Network error: \(message)"
        case .noData:
            return "No payment data received"
        case .decodingError:
            return "Error processing payment response"
        case .paymentFailed(let reason):
            return "Payment failed: \(reason)"
        case .insufficientFunds:
            return "Insufficient funds"
        case .cardDeclined:
            return "Card was declined"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}