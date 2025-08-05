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
//  Created by Quian Bowden on 8/4/25.
//  Stripe API configuration for payment processing
//

import Foundation

struct StripeConfig {
    
    // MARK: - Development Keys (Safe for testing)
    static let developmentPublishableKey = "pk_test_YOUR_DEVELOPMENT_KEY_HERE"
    private static let developmentSecretKey = "sk_test_YOUR_DEVELOPMENT_SECRET_HERE"
    
    // MARK: - Production Keys (Add your live keys here)
    static let productionPublishableKey: String? = nil // Add live key when ready
    private static let productionSecretKey: String? = nil // Add live secret when ready
    
    // MARK: - Current Environment
    static var currentPublishableKey: String? {
        #if DEBUG
        return developmentPublishableKey
        #else
        return productionPublishableKey
        #endif
    }
    
    static var currentSecretKey: String? {
        #if DEBUG
        return developmentSecretKey
        #else
        return productionSecretKey
        #endif
    }
    
    // MARK: - Environment Info
    static func getEnvironmentInfo() -> String {
        #if DEBUG
        return """
        Environment: DEVELOPMENT
        Publishable Key: \(developmentPublishableKey.prefix(12))...
        Status: Test Mode Active
        """
        #else
        return """
        Environment: PRODUCTION
        Publishable Key: \(productionPublishableKey?.prefix(12) ?? "NOT SET")...
        Status: Live Mode
        """
        #endif
    }
    
    // MARK: - Validation
    static func isConfigured() -> Bool {
        return currentPublishableKey != nil && currentSecretKey != nil
    }
}