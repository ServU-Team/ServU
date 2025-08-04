//
//  PaymentIntentResponse.swift
//  ServU
//
//  Created by Amber Still on 8/4/25.
//


//
//  StripePaymentService.swift
//  ServU
//
//  Created by Quian Bowden on 8/3/25.
//  Real Stripe payment integration for ServU
//

import Foundation
import SwiftUI
import Stripe
import StripePaymentSheet

// MARK: - Payment Intent Response Model
struct PaymentIntentResponse: Codable {
    let clientSecret: String
    let customerId: String?
    let ephemeralKey: String?
    let paymentIntentId: String
    let amount: Int
    let currency: String
}

// MARK: - Stripe Payment Service
@MainActor
class StripePaymentService: ObservableObject {
    
    // MARK: - Properties
    @Published var isProcessingPayment = false
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    
    private let networkManager = NetworkManager()
    
    // MARK: - Initialization
    init() {
        // Ensure Stripe is configured
        StripeConfig.configure()
    }
    
    // MARK: - Payment Methods
    
    /// Create a payment intent for a booking deposit
    func createDepositPaymentIntent(
        for booking: Booking,
        completion: @escaping (Result<PaymentIntentResponse, StripePaymentError>) -> Void
    ) async {
        let amount = booking.service.calculatedDepositAmount
        let description = "Deposit for \(booking.service.name)"
        let metadata: [String: String] = [
            "booking_id": booking.id.uuidString,
            "payment_type": "deposit",
            "business_id": booking.business.id.uuidString,
            "customer_email": booking.customerEmail
        ]
        
        await createPaymentIntent(
            amount: amount,
            description: description,
            metadata: metadata,
            completion: completion
        )
    }
    
    /// Create a payment intent for a full booking payment
    func createFullPaymentIntent(
        for booking: Booking,
        completion: @escaping (Result<PaymentIntentResponse, StripePaymentError>) -> Void
    ) async {
        let amount = booking.totalPrice
        let description = "Full payment for \(booking.service.name)"
        let metadata: [String: String] = [
            "booking_id": booking.id.uuidString,
            "payment_type": "full",
            "business_id": booking.business.id.uuidString,
            "customer_email": booking.customerEmail
        ]
        
        await createPaymentIntent(
            amount: amount,
            description: description,
            metadata: metadata,
            completion: completion
        )
    }
    
    /// Create a payment intent for remaining balance
    func createRemainingBalancePaymentIntent(
        for booking: Booking,
        completion: @escaping (Result<PaymentIntentResponse, StripePaymentError>) -> Void
    ) async {
        let amount = booking.service.remainingBalance
        let description = "Remaining balance for \(booking.service.name)"
        let metadata: [String: String] = [
            "booking_id": booking.id.uuidString,
            "payment_type": "remaining_balance",
            "business_id": booking.business.id.uuidString,
            "customer_email": booking.customerEmail
        ]
        
        await createPaymentIntent(
            amount: amount,
            description: description,
            metadata: metadata,
            completion: completion
        )
    }
    
    /// Create a payment intent for product purchases
    func createProductPaymentIntent(
        for cartItems: [CartItem],
        shipping: ShippingOption?,
        customerEmail: String,
        completion: @escaping (Result<PaymentIntentResponse, StripePaymentError>) -> Void
    ) async {
        let subtotal = cartItems.reduce(0) { $0 + $1.totalPrice }
        let shippingCost = shipping?.price ?? 0.0
        let totalAmount = subtotal + shippingCost
        
        let productNames = cartItems.map { "\($0.quantity)x \($0.displayName)" }.joined(separator: ", ")
        let description = "Purchase: \(productNames)"
        
        let metadata: [String: String] = [
            "payment_type": "product_purchase",
            "item_count": "\(cartItems.count)",
            "subtotal": String(format: "%.2f", subtotal),
            "shipping_cost": String(format: "%.2f", shippingCost),
            "customer_email": customerEmail
        ]
        
        await createPaymentIntent(
            amount: totalAmount,
            description: description,
            metadata: metadata,
            completion: completion
        )
    }
    
    // MARK: - Core Payment Intent Creation
    
    func createPaymentIntent(
        amount: Double,
        description: String,
        metadata: [String: String],
        completion: @escaping (Result<PaymentIntentResponse, StripePaymentError>) -> Void
    ) async {
        isProcessingPayment = true
        
        let amountInCents = StripeConfig.dollarsToCents(amount)
        
        let requestBody: [String: Any] = [
            "amount": amountInCents,
            "currency": "usd",
            "description": description,
            "metadata": metadata,
            "automatic_payment_methods": ["enabled": true]
        ]
        
        networkManager.createPaymentIntent(
            requestBody: requestBody
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessingPayment = false
                completion(result)
            }
        }
    }
    
    // MARK: - PaymentSheet Methods
    
    /// Prepare and present PaymentSheet
    func presentPaymentSheet(
        with paymentIntentResponse: PaymentIntentResponse,
        from viewController: UIViewController,
        completion: @escaping (PaymentSheetResult) -> Void
    ) {
        var configuration = StripeConfig.paymentSheetConfiguration()
        
        // Set customer if available
        if let customerId = paymentIntentResponse.customerId,
           let ephemeralKey = paymentIntentResponse.ephemeralKey {
            configuration.customer = .init(id: customerId, ephemeralKeySecret: ephemeralKey)
        }
        
        // Create PaymentSheet
        let paymentSheet = PaymentSheet(
            paymentIntentClientSecret: paymentIntentResponse.clientSecret,
            configuration: configuration
        )
        
        self.paymentSheet = paymentSheet
        
        // Present PaymentSheet
        paymentSheet.present(from: viewController) { [weak self] result in
            DispatchQueue.main.async {
                self?.paymentResult = result
                completion(result)
            }
        }
    }
    
    // MARK: - Convenience Methods
    
    /// Process complete payment flow for booking deposit
    func processDepositPayment(
        for booking: Booking,
        from viewController: UIViewController,
        completion: @escaping (Bool, String?) -> Void
    ) async {
        await createDepositPaymentIntent(for: booking) { [weak self] result in
            switch result {
            case .success(let paymentIntentResponse):
                self?.presentPaymentSheet(
                    with: paymentIntentResponse,
                    from: viewController
                ) { paymentResult in
                    self?.handlePaymentSheetResult(paymentResult, completion: completion)
                }
                
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }
    
    /// Process complete payment flow for full booking payment
    func processFullPayment(
        for booking: Booking,
        from viewController: UIViewController,
        completion: @escaping (Bool, String?) -> Void
    ) async {
        await createFullPaymentIntent(for: booking) { [weak self] result in
            switch result {
            case .success(let paymentIntentResponse):
                self?.presentPaymentSheet(
                    with: paymentIntentResponse,
                    from: viewController
                ) { paymentResult in
                    self?.handlePaymentSheetResult(paymentResult, completion: completion)
                }
                
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }
    
    /// Process complete payment flow for remaining balance
    func processRemainingBalancePayment(
        for booking: Booking,
        from viewController: UIViewController,
        completion: @escaping (Bool, String?) -> Void
    ) async {
        await createRemainingBalancePaymentIntent(for: booking) { [weak self] result in
            switch result {
            case .success(let paymentIntentResponse):
                self?.presentPaymentSheet(
                    with: paymentIntentResponse,
                    from: viewController
                ) { paymentResult in
                    self?.handlePaymentSheetResult(paymentResult, completion: completion)
                }
                
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }
    
    /// Process complete payment flow for product purchases
    func processProductPayment(
        for cartItems: [CartItem],
        shipping: ShippingOption?,
        customerEmail: String,
        from viewController: UIViewController,
        completion: @escaping (Bool, String?) -> Void
    ) async {
        await createProductPaymentIntent(
            for: cartItems,
            shipping: shipping,
            customerEmail: customerEmail
        ) { [weak self] result in
            switch result {
            case .success(let paymentIntentResponse):
                self?.presentPaymentSheet(
                    with: paymentIntentResponse,
                    from: viewController
                ) { paymentResult in
                    self?.handlePaymentSheetResult(paymentResult, completion: completion)
                }
                
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }
    
    // MARK: - Result Handling
    
    private func handlePaymentSheetResult(
        _ result: PaymentSheetResult,
        completion: @escaping (Bool, String?) -> Void
    ) {
        switch result {
        case .completed:
            print("✅ Payment completed successfully")
            completion(true, nil)
            
        case .canceled:
            print("⚠️ Payment was canceled by user")
            completion(false, "Payment was canceled")
            
        case .failed(let error):
            print("❌ Payment failed: \(error.localizedDescription)")
            completion(false, error.localizedDescription)
        }
    }
}

// MARK: - Stripe Payment Error
enum StripePaymentError: Error, LocalizedError {
    case networkError(String)
    case invalidResponse
    case serverError(String)
    case configurationError(String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let message):
            return "Server error: \(message)"
        case .configurationError(let message):
            return "Configuration error: \(message)"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Network Manager
class NetworkManager {
    
    func createPaymentIntent(
        requestBody: [String: Any],
        completion: @escaping (Result<PaymentIntentResponse, StripePaymentError>) -> Void
    ) {
        guard let url = URL(string: StripeConfig.Backend.baseURL + StripeConfig.Backend.createPaymentIntentEndpoint) else {
            completion(.failure(.configurationError("Invalid backend URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(.networkError("Failed to serialize request body")))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            // For development/testing, return a mock response if backend isn't ready
            if StripeConfig.isTestMode && StripeConfig.Backend.baseURL.contains("your-backend") {
                self.returnMockPaymentIntentResponse(completion: completion)
                return
            }
            
            do {
                let paymentIntentResponse = try JSONDecoder().decode(PaymentIntentResponse.self, from: data)
                completion(.success(paymentIntentResponse))
            } catch {
                completion(.failure(.invalidResponse))
            }
        }.resume()
    }
    
    // MARK: - Mock Response (for development)
    private func returnMockPaymentIntentResponse(
        completion: @escaping (Result<PaymentIntentResponse, StripePaymentError>) -> Void
    ) {
        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            let mockResponse = PaymentIntentResponse(
                clientSecret: "pi_mock_client_secret",
                customerId: nil,
                ephemeralKey: nil,
                paymentIntentId: "pi_mock_\(UUID().uuidString.prefix(10))",
                amount: 5000, // $50.00
                currency: "usd"
            )
            completion(.success(mockResponse))
        }
    }
}