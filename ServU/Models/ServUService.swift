//
//  ServUService.swift
//  ServU
//
//  Created by Amber Still on 8/4/25.
//


//
//  ServiceModels.swift
//  ServU
//
//  Created by Quian Bowden on 8/4/25.
//

import Foundation
import SwiftUI

// MARK: - ServU Service
struct ServUService: Codable, Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var price: Double
    var duration: String
    var isAvailable: Bool
    var requiresDeposit: Bool
    var depositAmount: Double?
    var depositType: DepositType?
    var depositPolicy: String?
    var category: ServiceCategory?
    var images: [String]
    var requirements: [String]
    var cancellationPolicy: String
    var createdDate: Date
    var lastModified: Date
    
    init(name: String, description: String, price: Double, duration: String, isAvailable: Bool = true, requiresDeposit: Bool = false, depositAmount: Double? = nil, depositType: DepositType? = nil, depositPolicy: String? = nil, category: ServiceCategory? = nil, images: [String] = [], requirements: [String] = [], cancellationPolicy: String = "24 hours notice required") {
        self.name = name
        self.description = description
        self.price = price
        self.duration = duration
        self.isAvailable = isAvailable
        self.requiresDeposit = requiresDeposit
        self.depositAmount = depositAmount
        self.depositType = depositType
        self.depositPolicy = depositPolicy
        self.category = category
        self.images = images
        self.requirements = requirements
        self.cancellationPolicy = cancellationPolicy
        self.createdDate = Date()
        self.lastModified = Date()
    }
    
    // MARK: - Computed Properties
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
    
    var formattedDeposit: String {
        guard let amount = depositAmount else { return "" }
        return String(format: "$%.2f", amount)
    }
    
    var totalCostWithDeposit: Double {
        return price + (depositAmount ?? 0.0)
    }
    
    var primaryImage: String? {
        return images.first
    }
}

// MARK: - Deposit Type
enum DepositType: String, CaseIterable, Codable {
    case percentage = "PERCENTAGE"
    case fixedAmount = "FIXED_AMOUNT"
    case fullPayment = "FULL_PAYMENT"
    
    var displayName: String {
        switch self {
        case .percentage: return "Percentage"
        case .fixedAmount: return "Fixed Amount"
        case .fullPayment: return "Full Payment"
        }
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

// MARK: - Booking Status
enum BookingStatus: String, CaseIterable, Codable {
    case pending = "PENDING"
    case confirmed = "CONFIRMED"
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
    case noShow = "NO_SHOW"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .noShow: return "No Show"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .confirmed: return "checkmark.circle.fill"
        case .inProgress: return "play.circle.fill"
        case .completed: return "checkmark.seal.fill"
        case .cancelled: return "xmark.circle.fill"
        case .noShow: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .confirmed: return .blue
        case .inProgress: return .purple
        case .completed: return .green
        case .cancelled: return .red
        case .noShow: return .gray
        }
    }
}

// MARK: - Service Booking
struct ServiceBooking: Identifiable, Codable {
    let id = UUID()
    var service: ServUService
    var business: String // Business name or ID
    var clientName: String
    var clientEmail: String
    var clientPhone: String?
    var timeSlot: TimeSlot
    var status: BookingStatus
    var totalCost: Double
    var depositPaid: Double
    var remainingBalance: Double
    var specialRequests: String?
    var cancellationReason: String?
    var createdDate: Date
    var lastModified: Date
    
    init(service: ServUService, business: String, clientName: String, clientEmail: String, clientPhone: String? = nil, timeSlot: TimeSlot, specialRequests: String? = nil) {
        self.service = service
        self.business = business
        self.clientName = clientName
        self.clientEmail = clientEmail
        self.clientPhone = clientPhone
        self.timeSlot = timeSlot
        self.status = .pending
        self.totalCost = service.price
        self.depositPaid = service.depositAmount ?? 0.0
        self.remainingBalance = service.price - (service.depositAmount ?? 0.0)
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

// MARK: - Payment Status (Disambiguation)
enum ServUPaymentStatus: String, CaseIterable, Codable {
    case pending = "PENDING"
    case processing = "PROCESSING"
    case completed = "COMPLETED"
    case failed = "FAILED"
    case refunded = "REFUNDED"
    case partialRefund = "PARTIAL_REFUND"
    case cancelled = "CANCELLED"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .refunded: return "Refunded"
        case .partialRefund: return "Partial Refund"
        case .cancelled: return "Cancelled"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .processing: return "arrow.triangle.2.circlepath"
        case .completed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .refunded: return "arrow.counterclockwise.circle.fill"
        case .partialRefund: return "arrow.counterclockwise.circle"
        case .cancelled: return "minus.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .processing: return .blue
        case .completed: return .green
        case .failed: return .red
        case .refunded: return .purple
        case .partialRefund: return .purple
        case .cancelled: return .gray
        }
    }
}