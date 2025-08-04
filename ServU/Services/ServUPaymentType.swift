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
//  Created by Quian Bowden on 8/3/25.
//  Payment type definitions for ServU
//

import Foundation

// MARK: - Payment Types
enum ServUPaymentType: String, CaseIterable {
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
}

// MARK: - Legacy Payment Option Support
enum PaymentOption: String, CaseIterable {
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
    
    // Convert to PaymentOption for legacy compatibility
    var toPaymentOption: PaymentOption {
        switch self {
        case .deposit:
            return .deposit
        case .full:
            return .full
        case .remainingBalance:
            return .remaining
        }
    }
}