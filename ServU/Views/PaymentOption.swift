//
//  PaymentOption.swift
//  ServU
//
//  Created by Amber Still on 8/3/25.
//


//
//  PaymentOption.swift
//  ServU
//
//  Created by Quian Bowden on 8/2/25.
//  Payment option types for ServU legacy compatibility
//

import SwiftUI

// MARK: - Payment Option (Legacy Support)
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
}