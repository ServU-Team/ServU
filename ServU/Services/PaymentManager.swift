//
//  PaymentManager.swift
//  ServU
//
//  Created by Amber Still on 7/31/25.
//


//
//  PaymentManager.swift
//  ServU
//
//  Created by Quian Bowden on 7/31/25.
//

import Foundation
import SwiftUI

// MARK: - Payment Manager
class PaymentManager: ObservableObject {
    @Published var isProcessingPayment = false
    @Published var paymentError: String?
    
    // MARK: - Public Methods
    
    func processDepositPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // For demo purposes, we'll always succeed
            // In a real app, this would integrate with Stripe, Square, etc.
            let success = true
            let transactionId = success ? "txn_\(UUID().uuidString.prefix(8))" : nil
            
            self.isProcessingPayment = false
            
            if success {
                print("✅ DEBUG: Deposit payment successful - Transaction ID: \(transactionId ?? "unknown")")
                completion(true, transactionId)
            } else {
                self.paymentError = "Payment failed. Please try again."
                print("❌ DEBUG: Deposit payment failed")
                completion(false, nil)
            }
        }
    }
    
    func processFullPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let success = true
            let transactionId = success ? "txn_\(UUID().uuidString.prefix(8))" : nil
            
            self.isProcessingPayment = false
            
            if success {
                print("✅ DEBUG: Full payment successful - Transaction ID: \(transactionId ?? "unknown")")
                completion(true, transactionId)
            } else {
                self.paymentError = "Payment failed. Please try again."
                print("❌ DEBUG: Full payment failed")
                completion(false, nil)
            }
        }
    }
    
    func refundPayment(transactionId: String, amount: Double, completion: @escaping (Bool) -> Void) {
        isProcessingPayment = true
        paymentError = nil
        
        // Simulate refund processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let success = true
            
            self.isProcessingPayment = false
            
            if success {
                print("✅ DEBUG: Refund successful for transaction: \(transactionId), amount: $\(amount)")
                completion(true)
            } else {
                self.paymentError = "Refund failed. Please contact support."
                print("❌ DEBUG: Refund failed for transaction: \(transactionId)")
                completion(false)
            }
        }
    }
}

// MARK: - Transaction Model
struct Transaction: Identifiable {
    let id = UUID()
    let transactionId: String
    let bookingId: UUID
    let amount: Double
    let type: TransactionType
    let status: TransactionStatus
    let createdAt: Date
    let processedAt: Date?
    
    init(transactionId: String, bookingId: UUID, amount: Double, type: TransactionType, status: TransactionStatus = .pending) {
        self.transactionId = transactionId
        self.bookingId = bookingId
        self.amount = amount
        self.type = type
        self.status = status
        self.createdAt = Date()
        self.processedAt = status == .completed ? Date() : nil
    }
}

// MARK: - Transaction Type
enum TransactionType: String, CaseIterable {
    case deposit = "Deposit"
    case fullPayment = "Full Payment"
    case remainingBalance = "Remaining Balance"
    case refund = "Refund"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .deposit: return "creditcard"
        case .fullPayment: return "checkmark.circle.fill"
        case .remainingBalance: return "plus.circle"
        case .refund: return "arrow.counterclockwise"
        }
    }
}

// MARK: - Transaction Status
enum TransactionStatus: String, CaseIterable {
    case pending = "Pending"
    case processing = "Processing"
    case completed = "Completed"
    case failed = "Failed"
    case refunded = "Refunded"
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .processing: return .blue
        case .completed: return .green
        case .failed: return .red
        case .refunded: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .processing: return "arrow.clockwise"
        case .completed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle"
        case .refunded: return "arrow.counterclockwise"
        }
    }
}