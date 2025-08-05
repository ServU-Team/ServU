//
//  ShippingOption.swift
//  ServU
//
//  Created by Amber Still on 8/5/25.
//


//
//  ShippingModels.swift
//  ServU
//
//  Created by Quian Bowden on 8/5/25.
//

import Foundation
import SwiftUI

// MARK: - Shipping Option
enum ShippingOption: String, CaseIterable, Identifiable, Codable {
    case campusPickup = "CAMPUS_PICKUP"
    case dormDelivery = "DORM_DELIVERY"
    case localDelivery = "LOCAL_DELIVERY"
    case standardShipping = "STANDARD_SHIPPING"
    case expressShipping = "EXPRESS_SHIPPING"
    case freeShipping = "FREE_SHIPPING"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .campusPickup: return "Campus Pickup"
        case .dormDelivery: return "Dorm Delivery"
        case .localDelivery: return "Local Delivery"
        case .standardShipping: return "Standard Shipping"
        case .expressShipping: return "Express Shipping"
        case .freeShipping: return "Free Shipping"
        }
    }
    
    var icon: String {
        switch self {
        case .campusPickup: return "location.fill"
        case .dormDelivery: return "building.2.fill"
        case .localDelivery: return "car.fill"
        case .standardShipping: return "shippingbox.fill"
        case .expressShipping: return "airplane"
        case .freeShipping: return "gift.fill"
        }
    }
    
    var cost: Double {
        switch self {
        case .campusPickup: return 0.0
        case .dormDelivery: return 3.0
        case .localDelivery: return 5.0
        case .standardShipping: return 7.99
        case .expressShipping: return 12.99
        case .freeShipping: return 0.0
        }
    }
    
    var estimatedDelivery: String {
        switch self {
        case .campusPickup: return "Same day"
        case .dormDelivery: return "Same day"
        case .localDelivery: return "1-2 days"
        case .standardShipping: return "3-5 days"
        case .expressShipping: return "1-2 days"
        case .freeShipping: return "5-7 days"
        }
    }
    
    var description: String {
        return "Delivery via \(displayName.lowercased())"
    }
}