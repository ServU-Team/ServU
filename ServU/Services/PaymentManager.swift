//
//  PaymentManager.swift
//  ServU
//
//  Created by Amber Still on 8/9/25.
//


//
//  PaymentManager.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  Stripe payment processing with deposit and full payment flows
//

import Foundation
import Stripe
import StripePaymentSheet
import StripeApplePay

class PaymentManager: ObservableObject {
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Configuration
    private let serverURL = "https://your-server.com" // Replace with your server URL
    
    // MARK: - Payment Intent Creation
    
    /// Create payment intent for service booking deposit
    func createDepositPaymentIntent(for booking: Booking, completion: @escaping (Result<String, Error>) -> Void) {
        guard booking.depositRequired else {
            completion(.failure(PaymentError.noDepositRequired))
            return
        }
        
        isLoading = true
        
        let amount = Int(booking.depositAmount * 100) // Convert to cents
        
        createPaymentIntent(
            amount: amount,
            currency: "usd",
            description: "Deposit for \(booking.serviceName)",
            metadata: [
                "booking_id": booking.id.uuidString,
                "payment_type": "deposit",
                "business_id": booking.businessId.uuidString
            ]
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                completion(result)
            }
        }
    }
    
    /// Create payment intent for full service payment
    func createFullPaymentIntent(for booking: Booking, completion: @escaping (Result<String, Error>) -> Void) {
        isLoading = true
        
        let amount = Int(booking.totalPrice * 100) // Convert to cents
        
        createPaymentIntent(
            amount: amount,
            currency: "usd",
            description: "Payment for \(booking.serviceName)",
            metadata: [
                "booking_id": booking.id.uuidString,
                "payment_type": "full",
                "business_id": booking.businessId.uuidString
            ]
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                completion(result)
            }
        }
    }
    
    /// Create payment intent for product purchases
    func createProductPaymentIntent(for items: [CartItem], total: Double, completion: @escaping (Result<String, Error>) -> Void) {
        isLoading = true
        
        let amount = Int(total * 100) // Convert to cents
        let itemDescriptions = items.map { "\($0.quantity)x \($0.product.name)" }.joined(separator: ", ")
        
        createPaymentIntent(
            amount: amount,
            currency: "usd",
            description: "Products: \(itemDescriptions)",
            metadata: [
                "payment_type": "products",
                "item_count": "\(items.count)",
                "total_quantity": "\(items.reduce(0) { $0 + $1.quantity })"
            ]
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                completion(result)
            }
        }
    }
    
    // MARK: - Payment Sheet Configuration
    
    /// Configure and present payment sheet
    func configurePaymentSheet(clientSecret: String, customerId: String? = nil, ephemeralKey: String? = nil) {
        var configuration = PaymentSheet.Configuration()
        
        // Basic configuration
        configuration.merchantDisplayName = "ServU"
        configuration.allowsDelayedPaymentMethods = false
        
        // Customer configuration (for saved payment methods)
        if let customerId = customerId, let ephemeralKey = ephemeralKey {
            configuration.customer = .init(id: customerId, ephemeralKeySecret: ephemeralKey)
        }
        
        // Apple Pay configuration
        if StripeAPI.deviceSupportsApplePay() {
            configuration.applePay = .init(
                merchantId: "merchant.serv.ServU", // Replace with your merchant ID
                merchantCountryCode: "US"
            )
        }
        
        // Appearance customization
        var appearance = PaymentSheet.Appearance()
        appearance.primaryButton.backgroundColor = UIColor(red: 0.85, green: 0.25, blue: 0.25, alpha: 1.0) // ServU Red
        appearance.colors.primary = UIColor(red: 0.85, green: 0.25, blue: 0.25, alpha: 1.0)
        configuration.appearance = appearance
        
        // Create payment sheet
        paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
    }
    
    /// Present payment sheet
    func presentPaymentSheet() {
        guard let paymentSheet = paymentSheet else {
            errorMessage = "Payment sheet not configured"
            return
        }
        
        // Find the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            errorMessage = "Cannot find root view controller"
            return
        }
        
        paymentSheet.present(from: rootViewController) { [weak self] result in
            DispatchQueue.main.async {
                self?.paymentResult = result
                self?.handlePaymentResult(result)
            }
        }
    }
    
    // MARK: - Payment Processing
    
    private func createPaymentIntent(
        amount: Int,
        currency: String,
        description: String,
        metadata: [String: String],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let url = URL(string: "\(serverURL)/create-payment-intent") else {
            completion(.failure(PaymentError.invalidServerURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "amount": amount,
            "currency": currency,
            "description": description,
            "metadata": metadata
        ] as [String: Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(PaymentError.noData))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let clientSecret = json["client_secret"] as? String {
                    completion(.success(clientSecret))
                } else {
                    completion(.failure(PaymentError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func handlePaymentResult(_ result: PaymentSheetResult) {
        switch result {
        case .completed:
            print("✅ Payment completed successfully")
            HapticFeedback.success()
            
        case .canceled:
            print("⚠️ Payment canceled by user")
            HapticFeedback.light()
            
        case .failed(let error):
            print("❌ Payment failed: \(error.localizedDescription)")
            errorMessage = "Payment failed: \(error.localizedDescription)"
            HapticFeedback.error()
        }
    }
    
    // MARK: - Customer Management
    
    /// Create Stripe customer for user
    func createCustomer(email: String, name: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(serverURL)/create-customer") else {
            completion(.failure(PaymentError.invalidServerURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "email": email,
            "name": name
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(PaymentError.noData))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let customerId = json["customer_id"] as? String {
                    completion(.success(customerId))
                } else {
                    completion(.failure(PaymentError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Refund Processing
    
    /// Process refund for payment
    func processRefund(paymentIntentId: String, amount: Int? = nil, reason: String? = nil, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(serverURL)/create-refund") else {
            completion(.failure(PaymentError.invalidServerURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = ["payment_intent_id": paymentIntentId]
        if let amount = amount {
            body["amount"] = amount
        }
        if let reason = reason {
            body["reason"] = reason
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(PaymentError.noData))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let success = json["success"] as? Bool {
                    completion(.success(success))
                } else {
                    completion(.failure(PaymentError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Utility Methods
    
    /// Reset payment manager state
    func reset() {
        paymentSheet = nil
        paymentResult = nil
        isLoading = false
        errorMessage = nil
    }
    
    /// Check if Apple Pay is available
    func isApplePayAvailable() -> Bool {
        return StripeAPI.deviceSupportsApplePay()
    }
}

// MARK: - Payment Errors
enum PaymentError: LocalizedError {
    case noDepositRequired
    case invalidServerURL
    case noData
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .noDepositRequired:
            return "No deposit required for this booking"
        case .invalidServerURL:
            return "Invalid server URL configuration"
        case .noData:
            return "No data received from server"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}

// MARK: - Stripe Configuration
struct StripeConfig {
    // Development keys (test mode)
    static let developmentPublishableKey = "pk_test_your_development_key_here"
    private static let developmentSecretKey = "sk_test_your_development_secret_here"
    
    // Production keys (live mode)
    static let productionPublishableKey: String? = nil // Set when ready for production
    private static let productionSecretKey: String? = nil // Set when ready for production
    
    static func getEnvironmentInfo() -> String {
        #if DEBUG
        return """
        Environment: DEVELOPMENT
        Publishable Key: \(developmentPublishableKey ?? "Not Set")
        Secret Key: \(developmentSecretKey.isEmpty ? "Not Set" : "Set")
        Apple Pay: \(StripeAPI.deviceSupportsApplePay() ? "Supported" : "Not Supported")
        """
        #else
        return """
        Environment: PRODUCTION
        Publishable Key: \(productionPublishableKey ?? "Not Set")
        Secret Key: \(productionSecretKey?.isEmpty == false ? "Set" : "Not Set")
        Apple Pay: \(StripeAPI.deviceSupportsApplePay() ? "Supported" : "Not Supported")
        """
        #endif
    }
}