//
//  StripeConfig.swift
//  ServU
//
//  Created by Amber Still on 8/4/25.
//


//
//  StripeConfig.swift
//  ServU
//
//  Created by Quian Bowden on 8/3/25.
//  Stripe configuration and setup for ServU
//

import Foundation
import UIKit
import Stripe
import StripePaymentSheet

// MARK: - Stripe Configuration
class StripeConfig {
    
    // MARK: - Keys (Replace with your actual keys)
    struct Keys {
        // Test Keys - Replace with your actual Stripe keys
        static let publishableKey = "pk_test_51234567890abcdef" // Your test publishable key
        static let secretKey = "sk_test_51234567890abcdef"     // Your test secret key (server-side only)
        
        // Production Keys (when ready for production)
        static let publishableKeyProd = "pk_live_your_production_key"
        static let secretKeyProd = "sk_live_your_production_key"
    }
    
    // MARK: - Environment Configuration
    #if DEBUG
    static let isTestMode = true
    static let currentPublishableKey = Keys.publishableKey
    #else
    static let isTestMode = false
    static let currentPublishableKey = Keys.publishableKeyProd
    #endif
    
    // MARK: - Backend Configuration
    struct Backend {
        // Replace with your actual backend URL
        static let baseURL = "https://your-backend.herokuapp.com" // or your server URL
        static let createPaymentIntentEndpoint = "/create-payment-intent"
        static let confirmPaymentEndpoint = "/confirm-payment"
        static let webhookEndpoint = "/webhook"
    }
    
    // MARK: - Setup Methods
    
    /// Initialize Stripe with the appropriate publishable key
    static func configure() {
        StripeAPI.defaultPublishableKey = currentPublishableKey
        
        // Configure additional Stripe settings
        StripeAPI.advancedFraudSignalsEnabled = true
        
        print("🔧 Stripe configured with key: \(currentPublishableKey.prefix(20))...")
        print("🔧 Test mode: \(isTestMode)")
    }
    
    /// Get the current environment info for debugging
    static func getEnvironmentInfo() -> String {
        return """
        Stripe Environment:
        - Test Mode: \(isTestMode)
        - Key: \(currentPublishableKey.prefix(20))...
        - Backend: \(Backend.baseURL)
        """
    }
}

// MARK: - Stripe Payment Configuration
extension StripeConfig {
    
    /// Default PaymentSheet configuration for ServU
    static func paymentSheetConfiguration() -> PaymentSheet.Configuration {
        var configuration = PaymentSheet.Configuration()
        
        // Merchant configuration
        configuration.merchantDisplayName = "ServU"
        configuration.returnURL = "servu://payment-return"
        
        // Customer configuration
        configuration.customer = nil // Will be set per payment
        
        // Payment method configuration
        configuration.allowsDelayedPaymentMethods = false
        configuration.allowsPaymentMethodsRequiringShippingAddress = false
        
        // Apple Pay configuration
        configuration.applePay = .init(
            merchantId: "merchant.com.servu.app", // Replace with your Apple Pay merchant ID
            merchantCountryCode: "US"
        )
        
        // Appearance customization
        configureAppearance(&configuration)
        
        return configuration
    }
    
    /// Configure Stripe UI appearance to match ServU branding
    private static func configureAppearance(_ configuration: inout PaymentSheet.Configuration) {
        var appearance = PaymentSheet.Appearance()
        
        // Primary colors (ServU Red)
        appearance.colors.primary = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0) // ServU Red
        appearance.colors.background = UIColor.systemBackground
        appearance.colors.componentBackground = UIColor.secondarySystemBackground
        
        // Typography
        appearance.font.base = UIFont.systemFont(ofSize: 16)
        appearance.font.sizeScaleFactor = 1.0
        
        // Border radius
        appearance.cornerRadius = 12.0
        appearance.borderWidth = 1.0
        
        // Shadow
        appearance.shadow = PaymentSheet.Appearance.Shadow(
            color: UIColor.black,
            opacity: 0.1,
            offset: CGSize(width: 0, height: 2),
            radius: 4
        )
        
        configuration.appearance = appearance
    }
}

// MARK: - Payment Amount Utilities
extension StripeConfig {
    
    /// Convert dollar amount to cents for Stripe
    static func dollarsToCents(_ dollars: Double) -> Int {
        return Int(round(dollars * 100))
    }
    
    /// Convert cents to dollars for display
    static func centsToDollars(_ cents: Int) -> Double {
        return Double(cents) / 100.0
    }
    
    /// Format amount for display
    static func formatAmount(_ dollars: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: dollars)) ?? "$\(dollars)"
    }
}

// MARK: - Validation Utilities
extension StripeConfig {
    
    /// Validate that Stripe is properly configured
    static func validateConfiguration() -> Bool {
        guard !currentPublishableKey.isEmpty else {
            print("❌ Stripe Error: Publishable key is empty")
            return false
        }
        
        guard currentPublishableKey.hasPrefix("pk_") else {
            print("❌ Stripe Error: Invalid publishable key format")
            return false
        }
        
        guard !Backend.baseURL.isEmpty else {
            print("❌ Stripe Error: Backend URL is empty")
            return false
        }
        
        print("✅ Stripe configuration is valid")
        return true
    }
}