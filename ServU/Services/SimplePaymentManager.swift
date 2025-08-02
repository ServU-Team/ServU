//
//  SimplePaymentManager.swift
//  ServU
//
//  Created by Amber Still on 8/2/25.
//


//
//  PaymentManager.swift
//  ServU
//
//  Created by Quian Bowden on 8/2/25.
//  Minimal payment management for ServU
//

import Foundation
import SwiftUI

// MARK: - Simple Payment Manager
@MainActor
class SimplePaymentManager: ObservableObject {
    @Published var isProcessingPayment = false
    @Published var paymentError: String?
    @Published var paymentSuccess = false
    
    private let paymentService = SimplePaymentService()
    
    // MARK: - Payment Methods
    
    func processDepositPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        paymentService.processDepositPayment(for: booking) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isProcessingPayment = false
                if success {
                    self?.paymentSuccess = true
                    self?.paymentError = nil
                } else {
                    self?.paymentError = error
                    self?.paymentSuccess = false
                }
                completion(success, error)
            }
        }
    }
    
    func processFullPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        paymentService.processFullPayment(for: booking) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isProcessingPayment = false
                if success {
                    self?.paymentSuccess = true
                    self?.paymentError = nil
                } else {
                    self?.paymentError = error
                    self?.paymentSuccess = false
                }
                completion(success, error)
            }
        }
    }
    
    func processRemainingBalance(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        paymentService.processRemainingBalance(for: booking) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isProcessingPayment = false
                if success {
                    self?.paymentSuccess = true
                    self?.paymentError = nil
                } else {
                    self?.paymentError = error
                    self?.paymentSuccess = false
                }
                completion(success, error)
            }
        }
    }
    
    func resetPaymentState() {
        isProcessingPayment = false
        paymentError = nil
        paymentSuccess = false
    }
}