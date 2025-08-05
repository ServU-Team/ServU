//
//  Service.swift
//  ServU
//
//  Created by Amber Still on 8/5/25.
//


//
//  Service.swift
//  ServU
//
//  Created by Quian Bowden on 8/4/25.
//

import Foundation
import SwiftUI

// MARK: - Service Model (Primary Service Model)
struct Service: Codable, Identifiable {
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
    
    enum CodingKeys: String, CodingKey {
        case name, description, price, duration, isAvailable, category
        case images, requirements, cancellationPolicy
        case requiresDeposit, depositAmount, depositType, depositPolicy
        case createdDate, lastModified
    }
    
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
    
    enum CodingKeys: String, CodingKey {
        case startTime, endTime, isAvailable, isBooked
        case businessId, serviceId, bookingId
    }
    
    init(startTime: Date, endTime: Date, isAvailable: Bool = true, isBooked: Bool = false, businessId: String? = nil, serviceId: String? = nil, bookingId: String? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.isAvailable = isAvailable
        self.isBooked = isBooked
        self.businessId = businessId
        self.serviceId = serviceId
        self.bookingId = bookingId
    }
    
    // MARK: - Computed Properties
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: startTime)
    }
    
    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
    
    var durationString: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
    
    var canBook: Bool {
        return isAvailable && !isBooked && startTime > Date()
    }
}

// MARK: - Service Booking
struct Booking: Identifiable, Codable {
    let id = UUID()
    var service: Service
    var businessId: String
    var businessName: String
    var clientName: String
    var clientEmail: String
    var clientPhone: String?
    var timeSlot: TimeSlot
    var status: BookingStatus
    var paymentStatus: PaymentStatus
    var totalCost: Double
    var depositPaid: Double
    var remainingBalance: Double
    var specialRequests: String?
    var cancellationReason: String?
    var createdDate: Date
    var lastModified: Date
    
    enum CodingKeys: String, CodingKey {
        case service, businessId, businessName, clientName, clientEmail, clientPhone
        case timeSlot, status, paymentStatus, totalCost, depositPaid, remainingBalance
        case specialRequests, cancellationReason, createdDate, lastModified
    }
    
    init(service: Service, businessId: String, businessName: String, clientName: String, clientEmail: String, clientPhone: String? = nil, timeSlot: TimeSlot, specialRequests: String? = nil) {
        self.service = service
        self.businessId = businessId
        self.businessName = businessName
        self.clientName = clientName
        self.clientEmail = clientEmail
        self.clientPhone = clientPhone
        self.timeSlot = timeSlot
        self.status = .pending
        self.paymentStatus = service.requiresDeposit ? .pending : .notRequired
        self.totalCost = service.price
        self.depositPaid = 0.0
        self.remainingBalance = service.price
        self.specialRequests = specialRequests
        self.createdDate = Date()
        self.lastModified = Date()
    }
    
    // MARK: - Computed Properties
    var formattedTotalCost: String {
        return String(format: "$%.2f", totalCost)
    }
    
    var formattedDepositPaid: String {
        return String(format: "$%.2f", depositPaid)
    }
    
    var formattedRemainingBalance: String {
        return String(format: "$%.2f", remainingBalance)
    }
    
    var canCancel: Bool {
        return status == .pending || status == .confirmed
    }
    
    var canReschedule: Bool {
        return status == .pending || status == .confirmed
    }
    
    var isUpcoming: Bool {
        return timeSlot.startTime > Date() && (status == .confirmed || status == .pending)
    }
    
    var isPast: Bool {
        return timeSlot.endTime < Date()
    }
}

// MARK: - Legacy Support Alias
typealias ServUService = Service