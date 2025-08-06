//
//  ServUService.swift
//  ServU
//
//  Created by Amber Still on 8/6/25.
//


//
//  ServUService.swift
//  ServU
//
//  Created by Quian Bowden on 8/5/25.
//  Legacy service model for compatibility with existing booking system
//

import Foundation
import SwiftUI

// MARK: - ServU Service Model (Legacy Compatibility)
struct ServUService: Codable, Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var price: Double
    var duration: String
    var isAvailable: Bool
    var category: ServiceCategory?
    var images: [String]
    var requirements: [String]
    var cancellationPolicy: String
    
    // Deposit Properties
    var requiresDeposit: Bool
    var depositAmount: Double
    var depositType: DepositType
    var depositPolicy: String
    
    var createdDate: Date
    var lastModified: Date
    
    init(name: String, description: String, price: Double, duration: String, isAvailable: Bool = true, category: ServiceCategory? = nil, images: [String] = [], requirements: [String] = [], cancellationPolicy: String = "24 hours notice required", requiresDeposit: Bool = false, depositAmount: Double = 0.0, depositType: DepositType = .fixed, depositPolicy: String = "") {
        self.name = name
        self.description = description
        self.price = price
        self.duration = duration
        self.isAvailable = isAvailable
        self.category = category
        self.images = images
        self.requirements = requirements
        self.cancellationPolicy = cancellationPolicy
        self.requiresDeposit = requiresDeposit
        self.depositAmount = depositAmount
        self.depositType = depositType
        self.depositPolicy = depositPolicy
        self.createdDate = Date()
        self.lastModified = Date()
    }
    
    // MARK: - Computed Properties
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
    
    var displayDepositAmount: String {
        switch depositType {
        case .fixed:
            return String(format: "$%.2f", depositAmount)
        case .percentage:
            let amount = price * (depositAmount / 100.0)
            return String(format: "$%.2f (%.0f%%)", amount, depositAmount)
        }
    }
    
    var calculatedDepositAmount: Double {
        switch depositType {
        case .fixed:
            return depositAmount
        case .percentage:
            return price * (depositAmount / 100.0)
        }
    }
    
    var remainingBalance: Double {
        return price - calculatedDepositAmount
    }
    
    var primaryImage: String? {
        return images.first
    }
}

// MARK: - Time Slot
struct TimeSlot: Identifiable, Codable {
    let id = UUID()
    var startTime: Date
    var endTime: Date
    var isAvailable: Bool
    var isBooked: Bool
    var businessId: String?
    var serviceId: String?
    var bookingId: String?
    
    init(startTime: Date, endTime: Date, isAvailable: Bool = true, isBooked: Bool = false, businessId: String? = nil, serviceId: String? = nil, bookingId: String? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.isAvailable = isAvailable
        self.isBooked = isBooked
        self.businessId = businessId
        self.serviceId = serviceId
        self.bookingId = bookingId
    }
    
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
    
    var durationInMinutes: Int {
        return Int(duration / 60)
    }
}