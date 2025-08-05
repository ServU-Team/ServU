//
//  ServUPaymentType.swift
//  ServU
//
//  Created by Amber Still on 8/4/25.
//


//
//  ServUPaymentType.swift
//  ServU
//
//  Created by Quian Bowden on 8/4/25.
//  Single source of truth for all payment-related types
//

import Foundation
import SwiftUI

// MARK: - ServU Payment Type (Primary)
enum ServUPaymentType: String, CaseIterable, Codable, Hashable {
    case deposit = "deposit"
    case full = "full"
    case remainingBalance = "remaining_balance"
    
    var displayName: String {
        switch self {
        case .deposit:
            return "Deposit"
        case .full:
            return "Full Payment"
        case .remainingBalance:
            return "Remaining Balance"
        }
    }
    
    var description: String {
        switch self {
        case .deposit:
            return "Pay a deposit to secure your booking"
        case .full:
            return "Pay the full amount upfront"
        case .remainingBalance:
            return "Pay the remaining balance due"
        }
    }
    
    var icon: String {
        switch self {
        case .deposit:
            return "creditcard"
        case .full:
            return "creditcard.fill"
        case .remainingBalance:
            return "creditcard.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .deposit:
            return .orange
        case .full:
            return .green
        case .remainingBalance:
            return .blue
        }
    }
}

// MARK: - Payment Status (SINGLE SOURCE OF TRUTH)
enum PaymentStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case depositPaid = "Deposit Paid"
    case fullyPaid = "Fully Paid"
    case refunded = "Refunded"
    case failed = "Failed"
    case notRequired = "No Payment Required"
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .depositPaid: return .blue
        case .fullyPaid: return .green
        case .refunded: return .gray
        case .failed: return .red
        case .notRequired: return .green
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .depositPaid: return "creditcard"
        case .fullyPaid: return "checkmark.circle.fill"
        case .refunded: return "arrow.counterclockwise"
        case .failed: return "xmark.circle"
        case .notRequired: return "checkmark.circle"
        }
    }
}

// MARK: - Deposit Type
enum DepositType: String, CaseIterable, Codable {
    case fixed = "Fixed Amount"
    case percentage = "Percentage"
    
    var displayName: String {
        return self.rawValue
    }
    
    var description: String {
        switch self {
        case .fixed:
            return "Fixed dollar amount"
        case .percentage:
            return "Percentage of service price"
        }
    }
}

// MARK: - Payment Error Types
enum PaymentError: Error, LocalizedError {
    case invalidAmount
    case paymentFailed(String)
    case networkError
    case invalidConfiguration
    case userCancelled
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Invalid payment amount"
        case .paymentFailed(let message):
            return message
        case .networkError:
            return "Network connection error"
        case .invalidConfiguration:
            return "Payment configuration error"
        case .userCancelled:
            return "Payment cancelled by user"
        }
    }
}

// MARK: - Legacy Support
typealias PaymentOption = ServUPaymentType

// MARK: - Extensions for Convenience
extension ServUPaymentType {
    
    /// Determine payment type based on booking and payment status
    static func determinePaymentType(for booking: Booking) -> ServUPaymentType {
        switch booking.paymentStatus {
        case .pending:
            return booking.service.requiresDeposit ? .deposit : .full
        case .depositPaid:
            return .remainingBalance
        case .fullyPaid, .notRequired:
            return .full
        case .failed, .refunded:
            return .full
        }
    }
    
    /// Calculate amount for this payment type
    func calculateAmount(for service: Service) -> Double {
        switch self {
        case .deposit:
            return service.calculatedDepositAmount
        case .full:
            return service.price
        case .remainingBalance:
            return service.remainingBalance
        }
    }
}