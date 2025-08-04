//
//  ServUPaymentType.swift
//  ServU
//
//  Created by Amber Still on 8/4/25.
//


//
//  PaymentTypes.swift
//  ServU
//
//  Created by Quian Bowden on 8/4/25.
//  Consolidated payment types for ServU platform
//

import Foundation
import SwiftUI

// MARK: - ServU Payment Type (Primary)
enum ServUPaymentType: String, CaseIterable, Codable {
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
}

// MARK: - Payment Option (Legacy Support)
enum PaymentOption: String, CaseIterable, Codable {
    case deposit = "deposit"
    case full = "full" 
    case remaining = "remaining"
    
    var displayName: String {
        switch self {
        case .deposit:
            return "Deposit"
        case .full:
            return "Full Payment"
        case .remaining:
            return "Remaining Balance"
        }
    }
    
    var description: String {
        switch self {
        case .deposit:
            return "Pay a deposit to secure your booking"
        case .full:
            return "Pay the full amount upfront"
        case .remaining:
            return "Pay the remaining balance due"
        }
    }
    
    // Convert to ServUPaymentType for compatibility
    var toServUPaymentType: ServUPaymentType {
        switch self {
        case .deposit:
            return .deposit
        case .full:
            return .full
        case .remaining:
            return .remainingBalance
        }
    }
}

// MARK: - ServUPaymentType Extension
extension ServUPaymentType {
    // Convert from PaymentOption for legacy compatibility
    init(from paymentOption: PaymentOption) {
        self = paymentOption.toServUPaymentType
    }
}

// MARK: - Payment Status
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