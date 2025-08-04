//
//  StripeConfigurationManager.swift
//  ServU
//
//  Created by Amber Still on 8/4/25.
//


//
//  StripeIntegration.swift
//  ServU
//
//  Created by Quian Bowden on 8/4/25.
//  Real Stripe SDK integration for ServU payment processing
//

import Foundation
import SwiftUI
import Stripe
import StripePaymentSheet

// MARK: - Stripe Configuration Manager
class StripeConfigurationManager: ObservableObject {
    static let shared = StripeConfigurationManager()
    
    private init() {
        configureStripe()
    }
    
    private func configureStripe() {
        // Configure Stripe with your publishable key
        StripeAPI.defaultPublishableKey = "pk_test_YOUR_ACTUAL_PUBLISHABLE_KEY"
        
        // Configure payment sheet appearance
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "ServU"
        configuration.allowsDelayedPaymentMethods = true
        configuration.defaultBillingDetails.name = "ServU User"
        
        PaymentSheet.configure(configuration)
    }
}

// MARK: - Real Stripe Payment Service
class RealStripePaymentService: ObservableObject {
    @Published var isProcessingPayment = false
    @Published var paymentError: String?
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    
    private let backendURL = "YOUR_BACKEND_ENDPOINT"
    
    // MARK: - Payment Intent Creation
    func createPaymentIntent(
        amount: Double,
        currency: String = "usd",
        description: String,
        completion: @escaping (Result<PaymentSheet, PaymentError>) -> Void
    ) {
        guard amount > 0 else {
            completion(.failure(.invalidAmount))
            return
        }
        
        isProcessingPayment = true
        paymentError = nil
        
        // Create payment intent on your backend
        createPaymentIntentOnBackend(
            amount: Int(amount * 100), // Convert to cents
            currency: currency,
            description: description
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessingPayment = false
                
                switch result {
                case .success(let paymentIntentResponse):
                    self?.setupPaymentSheet(
                        paymentIntent: paymentIntentResponse.paymentIntent,
                        ephemeralKey: paymentIntentResponse.ephemeralKey,
                        customer: paymentIntentResponse.customer,
                        completion: completion
                    )
                case .failure(let error):
                    self?.paymentError = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Backend Communication
    private func createPaymentIntentOnBackend(
        amount: Int,
        currency: String,
        description: String,
        completion: @escaping (Result<PaymentIntentResponse, PaymentError>) -> Void
    ) {
        guard let url = URL(string: "\(backendURL)/create-payment-intent") else {
            completion(.failure(.invalidConfiguration))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "amount": amount,
            "currency": currency,
            "description": description
        ] as [String: Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(.networkError))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.networkError))
                return
            }
            
            do {
                let paymentIntentResponse = try JSONDecoder().decode(PaymentIntentResponse.self, from: data)
                completion(.success(paymentIntentResponse))
            } catch {
                completion(.failure(.paymentFailed("Failed to decode response")))
            }
        }.resume()
    }
    
    // MARK: - Payment Sheet Setup
    private func setupPaymentSheet(
        paymentIntent: String,
        ephemeralKey: String,
        customer: String,
        completion: @escaping (Result<PaymentSheet, PaymentError>) -> Void
    ) {
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "ServU"
        configuration.customer = .init(id: customer, ephemeralKeySecret: ephemeralKey)
        configuration.allowsDelayedPaymentMethods = true
        
        // Apple Pay configuration
        configuration.applePay = .init(
            merchantId: "merchant.your.app.identifier",
            merchantCountryCode: "US"
        )
        
        let paymentSheet = PaymentSheet(
            paymentIntentClientSecret: paymentIntent,
            configuration: configuration
        )
        
        self.paymentSheet = paymentSheet
        completion(.success(paymentSheet))
    }
    
    // MARK: - Payment Processing
    func presentPaymentSheet(completion: @escaping (PaymentSheetResult) -> Void) {
        guard let paymentSheet = paymentSheet else {
            completion(.failed(error: PaymentError.invalidConfiguration))
            return
        }
        
        // Present payment sheet (this would typically be called from a view)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            
            paymentSheet.present(from: rootViewController) { [weak self] result in
                self?.paymentResult = result
                completion(result)
            }
        }
    }
}

// MARK: - Payment Intent Response Model
struct PaymentIntentResponse: Codable {
    let paymentIntent: String
    let ephemeralKey: String
    let customer: String
    
    enum CodingKeys: String, CodingKey {
        case paymentIntent = "payment_intent"
        case ephemeralKey = "ephemeral_key"
        case customer
    }
}

// MARK: - SwiftUI Payment View with Real Stripe
struct StripePaymentView: View {
    @StateObject private var stripeService = RealStripePaymentService()
    @State private var showingPaymentSheet = false
    
    let booking: Booking
    let paymentType: ServUPaymentType
    
    var body: some View {
        VStack(spacing: 20) {
            paymentSummaryView
            
            Button("Pay with Stripe") {
                initiatePayment()
            }
            .disabled(stripeService.isProcessingPayment)
            .buttonStyle(.borderedProminent)
            
            if stripeService.isProcessingPayment {
                ProgressView("Setting up payment...")
            }
        }
        .padding()
        .navigationTitle("Payment")
        .onAppear {
            StripeConfigurationManager.shared // Initialize Stripe
        }
    }
    
    private var paymentSummaryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Summary")
                .font(.headline)
            
            HStack {
                Text(paymentType.displayName)
                Spacer()
                Text(formattedAmount)
                    .fontWeight(.semibold)
            }
            
            Text(booking.service.name)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var formattedAmount: String {
        let amount = calculateAmount()
        return String(format: "$%.2f", amount)
    }
    
    private func calculateAmount() -> Double {
        switch paymentType {
        case .deposit:
            return booking.service.calculatedDepositAmount
        case .full:
            return booking.totalPrice
        case .remainingBalance:
            return booking.service.remainingBalance
        }
    }
    
    private func initiatePayment() {
        stripeService.createPaymentIntent(
            amount: calculateAmount(),
            description: "\(paymentType.displayName) for \(booking.service.name)"
        ) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.stripeService.presentPaymentSheet { paymentResult in
                        self.handlePaymentResult(paymentResult)
                    }
                }
            case .failure(let error):
                print("Payment setup failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func handlePaymentResult(_ result: PaymentSheetResult) {
        switch result {
        case .completed:
            // Payment successful - update booking status
            print("Payment completed successfully!")
        case .canceled:
            print("Payment canceled by user")
        case .failed(let error):
            print("Payment failed: \(error.localizedDescription)")
        }
    }
}