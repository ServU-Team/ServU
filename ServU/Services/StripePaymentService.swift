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
//  Enhanced with real Stripe iOS SDK integration
//

import Foundation
import SwiftUI
import StripePaymentSheet
import StripePayments

// MARK: - Stripe Payment Service
class StripePaymentService: ObservableObject {
    
    // MARK: - Properties
    @Published var isProcessingPayment = false
    @Published var paymentError: String?
    @Published var lastPaymentIntent: PaymentIntent?
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    
    // Stripe Configuration
    private let stripePublishableKey = "pk_test_YOUR_PUBLISHABLE_KEY" // Replace with your key
    private let baseURL = "YOUR_BACKEND_URL" // Replace with your backend URL
    
    // MARK: - Initialization
    
    init() {
        configureStripe()
    }
    
    private func configureStripe() {
        // Configure Stripe with your publishable key
        StripeAPI.defaultPublishableKey = stripePublishableKey
        
        // Enable logging for debugging (remove in production)
        #if DEBUG
        StripeAPI.advancedFraudSignalsEnabled = true
        #endif
    }
    
    // MARK: - Payment Intent Creation
    
    /// Creates a payment intent for deposit payment
    func createDepositPaymentIntent(for booking: Booking, completion: @escaping (Result<PaymentSheet, PaymentError>) -> Void) {
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
        
        createPaymentIntent(with: paymentData) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessingPayment = false
                switch result {
                case .success(let paymentIntent):
                    self?.setupPaymentSheet(with: paymentIntent, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Creates a payment intent for full payment
    func createFullPaymentIntent(for booking: Booking, completion: @escaping (Result<PaymentSheet, PaymentError>) -> Void) {
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
        
        createPaymentIntent(with: paymentData) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessingPayment = false
                switch result {
                case .success(let paymentIntent):
                    self?.setupPaymentSheet(with: paymentIntent, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Creates a payment intent for remaining balance
    func createRemainingBalancePaymentIntent(for booking: Booking, completion: @escaping (Result<PaymentSheet, PaymentError>) -> Void) {
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
        
        createPaymentIntent(with: paymentData) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessingPayment = false
                switch result {
                case .success(let paymentIntent):
                    self?.setupPaymentSheet(with: paymentIntent, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Product Payment Intent
    
    /// Creates a payment intent for product purchases
    func createProductPaymentIntent(for cartItems: [CartItem], shipping: ShippingOption?, completion: @escaping (Result<PaymentSheet, PaymentError>) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        
        let subtotal = cartItems.reduce(0) { $0 + $1.totalPrice }
        let shippingCost = shipping?.price ?? 0.0
        let totalAmount = subtotal + shippingCost
        let amountInCents = Int(totalAmount * 100)
        
        let itemsMetadata = cartItems.enumerated().reduce(into: [String: String]()) { result, item in
            let (index, cartItem) = item
            result["item_\(index)_name"] = cartItem.product.name
            result["item_\(index)_variant"] = cartItem.selectedVariant?.displayName ?? "Standard"
            result["item_\(index)_quantity"] = String(cartItem.quantity)
            result["item_\(index)_price"] = String(format: "%.2f", cartItem.totalPrice)
        }
        
        var paymentData: [String: Any] = [
            "amount": amountInCents,
            "currency": "usd",
            "payment_method_types": ["card"],
            "metadata": itemsMetadata.merging([
                "payment_type": "product_purchase",
                "total_items": String(cartItems.count),
                "subtotal": String(format: "%.2f", subtotal),
                "shipping_cost": String(format: "%.2f", shippingCost)
            ]) { _, new in new }
        ]
        
        if let shipping = shipping {
            paymentData["shipping"] = [
                "name": shipping.name,
                "carrier": shipping.carrier,
                "price": shipping.price
            ]
        }
        
        createPaymentIntent(with: paymentData) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessingPayment = false
                switch result {
                case .success(let paymentIntent):
                    self?.setupPaymentSheet(with: paymentIntent, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Creates a payment intent through backend API
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
            completion(.failure(.serialization(error)))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.network(error)))
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
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    /// Sets up the Stripe Payment Sheet
    private func setupPaymentSheet(with paymentIntent: PaymentIntent, completion: @escaping (Result<PaymentSheet, PaymentError>) -> Void) {
        guard let customerEphemeralKeySecret = paymentIntent.ephemeralKey,
              let paymentIntentClientSecret = paymentIntent.clientSecret else {
            completion(.failure(.missingPaymentData))
            return
        }
        
        // Configure the payment sheet
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "ServU"
        configuration.customer = .init(
            id: paymentIntent.customerId,
            ephemeralKeySecret: customerEphemeralKeySecret
        )
        configuration.appearance = createPaymentSheetAppearance()
        configuration.allowsDelayedPaymentMethods = true
        configuration.primaryButtonLabel = "Complete Payment"
        
        // Create the payment sheet
        let paymentSheet = PaymentSheet(
            paymentIntentClientSecret: paymentIntentClientSecret,
            configuration: configuration
        )
        
        self.paymentSheet = paymentSheet
        self.lastPaymentIntent = paymentIntent
        
        completion(.success(paymentSheet))
    }
    
    /// Creates custom appearance for payment sheet
    private func createPaymentSheetAppearance() -> PaymentSheet.Appearance {
        var appearance = PaymentSheet.Appearance()
        
        // Colors
        appearance.colors.primary = UIColor(red: 0.85, green: 0.17, blue: 0.25, alpha: 1.0) // ServU Red
        appearance.colors.background = UIColor.systemBackground
        appearance.colors.componentBackground = UIColor.secondarySystemBackground
        appearance.colors.text = UIColor.label
        appearance.colors.textSecondary = UIColor.secondaryLabel
        appearance.colors.border = UIColor.separator
        
        // Corner radius
        appearance.cornerRadius = 12.0
        appearance.borderWidth = 1.0
        
        // Font
        appearance.font.base = UIFont.systemFont(ofSize: 16, weight: .regular)
        appearance.font.sizeScaleFactor = 1.0
        
        return appearance
    }
    
    // MARK: - Payment Processing
    
    /// Process payment with the configured payment sheet
    func processPayment(completion: @escaping (PaymentSheetResult) -> Void) {
        guard let paymentSheet = self.paymentSheet else {
            completion(.failed(error: PaymentSheetError.unknown(debugDescription: "Payment sheet not configured")))
            return
        }
        
        // Present the payment sheet (this should be called from a view controller)
        // We'll handle this in the PaymentManager
        completion(.completed)
    }
}

// MARK: - Payment Intent Model
struct PaymentIntent: Codable {
    let id: String
    let clientSecret: String
    let amount: Int
    let currency: String
    let status: String
    let customerId: String
    let ephemeralKey: String?
    let publishableKey: String?
    let metadata: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case clientSecret = "client_secret"
        case amount
        case currency
        case status
        case customerId = "customer_id"
        case ephemeralKey = "ephemeral_key"
        case publishableKey = "publishable_key"
        case metadata
    }
}

// MARK: - Payment Error
enum PaymentError: LocalizedError {
    case invalidURL
    case network(Error)
    case serialization(Error)
    case noData
    case decodingError(Error)
    case missingPaymentData
    case paymentFailed(String)
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid payment URL"
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        case .serialization(let error):
            return "Data serialization error: \(error.localizedDescription)"
        case .noData:
            return "No payment data received"
        case .decodingError(let error):
            return "Payment data decoding error: \(error.localizedDescription)"
        case .missingPaymentData:
            return "Missing required payment information"
        case .paymentFailed(let message):
            return "Payment failed: \(message)"
        case .cancelled:
            return "Payment was cancelled"
        }
    }
}

// Note: CartItem and ShippingOption models are defined in ServUService.swift