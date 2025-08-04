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
//  Real Stripe payment management system for ServU
//

import Foundation
import SwiftUI
import UIKit
import StripePaymentSheet

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
    private let userProfile = UserProfile() // You might want to inject this
    
    // MARK: - Service Payment Methods
    
    @MainActor
    func processDepositPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        guard let viewController = getCurrentViewController() else {
            completion(false, "Unable to present payment interface")
            return
        }
        
        updatePaymentState(processing: true, error: nil, success: false)
        
        Task {
            await stripeService.processDepositPayment(
                for: booking,
                from: viewController
            ) { [weak self] success, error in
                DispatchQueue.main.async {
                    self?.updatePaymentState(processing: false, error: error, success: success)
                    completion(success, error)
                }
            }
        }
    }
    
    @MainActor
    func processFullPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        guard let viewController = getCurrentViewController() else {
            completion(false, "Unable to present payment interface")
            return
        }
        
        updatePaymentState(processing: true, error: nil, success: false)
        
        Task {
            await stripeService.processFullPayment(
                for: booking,
                from: viewController
            ) { [weak self] success, error in
                DispatchQueue.main.async {
                    self?.updatePaymentState(processing: false, error: error, success: success)
                    completion(success, error)
                }
            }
        }
    }
    
    @MainActor
    func processRemainingBalancePayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        guard let viewController = getCurrentViewController() else {
            completion(false, "Unable to present payment interface")
            return
        }
        
        updatePaymentState(processing: true, error: nil, success: false)
        
        Task {
            await stripeService.processRemainingBalancePayment(
                for: booking,
                from: viewController
            ) { [weak self] success, error in
                DispatchQueue.main.async {
                    self?.updatePaymentState(processing: false, error: error, success: success)
                    completion(success, error)
                }
            }
        }
    }
    
    // MARK: - Product Payment Methods
    
    @MainActor
    func processProductPayment(for items: [CartItem], shipping: ShippingOption?, completion: @escaping (Bool, String?) -> Void) {
        guard let viewController = getCurrentViewController() else {
            completion(false, "Unable to present payment interface")
            return
        }
        
        updatePaymentState(processing: true, error: nil, success: false)
        
        // Use the user's email for product purchases
        let customerEmail = userProfile.email.isEmpty ? "customer@example.com" : userProfile.email
        
        Task {
            await stripeService.processProductPayment(
                for: items,
                shipping: shipping,
                customerEmail: customerEmail,
                from: viewController
            ) { [weak self] success, error in
                DispatchQueue.main.async {
                    self?.updatePaymentState(processing: false, error: error, success: success)
                    completion(success, error)
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
    
    // MARK: - Helper Methods
    
    private func getCurrentViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        
        return window.rootViewController?.topMostViewController()
    }
}

// MARK: - UIViewController Extension
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController() ?? self
        }
        
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostViewController() ?? self
        }
        
        return self
    }
}

// MARK: - Alternative PaymentManager for Testing
/// Use this if you want to test without real Stripe integration
class MockPaymentManager: PaymentManagerProtocol, ObservableObject {
    @Published var isProcessingPayment = false
    @Published var paymentError: String?
    @Published var paymentSuccess = false
    
    func processDepositPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        simulatePayment(amount: booking.service.calculatedDepositAmount, completion: completion)
    }
    
    func processFullPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        simulatePayment(amount: booking.totalPrice, completion: completion)
    }
    
    func processRemainingBalancePayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        simulatePayment(amount: booking.service.remainingBalance, completion: completion)
    }
    
    func processProductPayment(for items: [CartItem], shipping: ShippingOption?, completion: @escaping (Bool, String?) -> Void) {
        let total = items.reduce(0) { $0 + $1.totalPrice } + (shipping?.price ?? 0.0)
        simulatePayment(amount: total, completion: completion)
    }
    
    func resetPaymentState() {
        isProcessingPayment = false
        paymentError = nil
        paymentSuccess = false
    }
    
    private func simulatePayment(amount: Double, completion: @escaping (Bool, String?) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        paymentSuccess = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let success = Double.random(in: 0...1) > 0.1 // 90% success rate
            
            self.isProcessingPayment = false
            if success {
                self.paymentSuccess = true
                print("✅ Mock payment successful for $\(String(format: "%.2f", amount))")
                completion(true, nil)
            } else {
                self.paymentError = "Mock payment failed"
                print("❌ Mock payment failed for $\(String(format: "%.2f", amount))")
                completion(false, "Mock payment failed")
            }
        }
    }
}

// MARK: - Payment Manager Factory
struct PaymentManagerFactory {
    /// Create the appropriate payment manager based on configuration
    static func createPaymentManager() -> any PaymentManagerProtocol {
        #if DEBUG
        // Use real Stripe in debug mode if properly configured
        if StripeConfig.validateConfiguration() {
            return PaymentManager()
        } else {
            print("⚠️ Stripe not properly configured, using mock payment manager")
            return MockPaymentManager()
        }
        #else
        // Always use real Stripe in production
        return PaymentManager()
        #endif
    }
}