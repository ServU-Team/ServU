//
//  PaymentSummary.swift
//  ServU
//
//  Created by Amber Still on 8/2/25.
//


//
//  PaymentModels.swift
//  ServU
//
//  Created by Quian Bowden on 8/2/25.
//  Payment-related extensions and utilities for ServU
//

import Foundation
import SwiftUI

// MARK: - Service Extensions for Payment
extension Service {
    var calculatedDepositAmount: Double {
        guard requiresDeposit else { return 0.0 }
        
        switch depositType {
        case .fixed:
            return depositAmount
        case .percentage:
            return price * (depositAmount / 100.0)
        case .none:
            return 0.0
        }
    }
    
    var remainingBalance: Double {
        return price - calculatedDepositAmount
    }
    
    var requiresPayment: Bool {
        return price > 0.0
    }
    
    var depositDisplayText: String {
        guard requiresDeposit else { return "No deposit required" }
        
        switch depositType {
        case .fixed:
            return "$\(depositAmount, specifier: "%.2f") deposit required"
        case .percentage:
            return "\(depositAmount, specifier: "%.0f")% deposit required"
        case .none:
            return "No deposit required"
        }
    }
}

// MARK: - Booking Extensions for Payment
extension Booking {
    var canPayDeposit: Bool {
        return paymentStatus == .pending && service.requiresDeposit
    }
    
    var canPayFullAmount: Bool {
        return paymentStatus == .pending
    }
    
    var canPayRemainingBalance: Bool {
        return paymentStatus == .depositPaid
    }
    
    var nextPaymentAmount: Double {
        switch paymentStatus {
        case .pending:
            return service.requiresDeposit ? service.calculatedDepositAmount : totalPrice
        case .depositPaid:
            return service.remainingBalance
        default:
            return 0.0
        }
    }
    
    var paymentStatusColor: Color {
        switch paymentStatus {
        case .pending:
            return .orange
        case .depositPaid:
            return .blue
        case .fullyPaid:
            return .green
        case .refunded:
            return .purple
        case .failed:
            return .red
        case .notRequired:
            return .gray
        }
    }
}

// MARK: - CartItem Extensions for Payment
extension CartItem {
    var unitPrice: Double {
        return selectedVariant?.price ?? product.basePrice
    }
}

// MARK: - Payment Summary Helper
struct PaymentSummary {
    let subtotal: Double
    let platformFee: Double
    let stripeFee: Double
    let shipping: Double
    let total: Double
    
    init(items: [CartItem], shipping: ShippingOption? = nil) {
        self.subtotal = items.reduce(0) { $0 + $1.totalPrice }
        self.platformFee = PlatformFeeConfig.calculatePlatformFee(for: subtotal)
        self.stripeFee = PlatformFeeConfig.calculateStripeFee(for: subtotal)
        self.shipping = shipping?.price ?? 0.0
        self.total = subtotal + platformFee + stripeFee + self.shipping
    }
    
    init(booking: Booking, paymentType: ServicePaymentType) {
        switch paymentType {
        case .deposit:
            self.subtotal = booking.service.calculatedDepositAmount
        case .full:
            self.subtotal = booking.totalPrice
        case .remainingBalance:
            self.subtotal = booking.service.remainingBalance
        }
        
        self.platformFee = PlatformFeeConfig.calculatePlatformFee(for: subtotal)
        self.stripeFee = PlatformFeeConfig.calculateStripeFee(for: subtotal)
        self.shipping = 0.0
        self.total = subtotal + platformFee + stripeFee
    }
    
    var businessPayout: Double {
        return subtotal - platformFee - stripeFee
    }
}