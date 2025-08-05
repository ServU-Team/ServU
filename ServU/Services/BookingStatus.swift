//
//  BookingStatus.swift
//  ServU
//
//  Created by Amber Still on 8/4/25.
//


//
//  BookingManager.swift
//  ServU
//
//  Created by Quian Bowden on 8/4/25.
//  Manages booking operations and payment status
//

import Foundation
import SwiftUI

// MARK: - Booking Status
enum BookingStatus: String, CaseIterable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case noShow = "No Show"
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .confirmed: return .blue
        case .completed: return .green
        case .cancelled: return .red
        case .noShow: return .gray
        }
    }
}

// MARK: - Booking Model
struct Booking: Identifiable {
    let id: UUID
    var service: Service
    var business: Business
    var customerName: String
    var customerEmail: String
    var customerPhone: String
    var appointmentDate: Date
    var startTime: Date
    var endTime: Date
    var status: BookingStatus
    var notes: String
    var totalPrice: Double
    var paymentStatus: PaymentStatus // This now references the unified PaymentStatus
    var createdAt: Date
    
    // MARK: - Initializer
    init(id: UUID = UUID(), service: Service, business: Business, customerName: String, customerEmail: String, customerPhone: String, appointmentDate: Date, startTime: Date, endTime: Date, status: BookingStatus = .pending, notes: String = "", totalPrice: Double, paymentStatus: PaymentStatus = .pending) {
        self.id = id
        self.service = service
        self.business = business
        self.customerName = customerName
        self.customerEmail = customerEmail
        self.customerPhone = customerPhone
        self.appointmentDate = appointmentDate
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
        self.notes = notes
        self.totalPrice = totalPrice
        self.paymentStatus = paymentStatus
        self.createdAt = Date()
    }
    
    // MARK: - Computed Properties
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: appointmentDate)
    }
    
    var displayTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
    
    var isUpcoming: Bool {
        return appointmentDate >= Date() && (status == .confirmed || status == .pending)
    }
    
    var canCancel: Bool {
        return isUpcoming && status != .cancelled
    }
    
    var canReschedule: Bool {
        return isUpcoming && status == .confirmed
    }
    
    var requiresDeposit: Bool {
        return service.requiresDeposit
    }
    
    var depositAmount: Double {
        return service.calculatedDepositAmount
    }
    
    var remainingBalance: Double {
        return service.remainingBalance
    }
    
    var formattedDepositAmount: String {
        if requiresDeposit {
            return String(format: "$%.2f", depositAmount)
        }
        return "$0.00"
    }
    
    var formattedRemainingBalance: String {
        return String(format: "$%.2f", remainingBalance)
    }
    
    var formattedTotalPrice: String {
        return String(format: "$%.2f", totalPrice)
    }
    
    var requiresPaymentAction: Bool {
        switch paymentStatus {
        case .pending:
            return true
        case .depositPaid:
            return !service.requiresDeposit
        case .fullyPaid, .refunded, .failed, .notRequired:
            return false
        }
    }
    
    var nextPaymentAction: String {
        switch paymentStatus {
        case .pending:
            return service.requiresDeposit ? "Pay Deposit" : "Pay Full Amount"
        case .depositPaid:
            return "Pay Remaining Balance"
        case .fullyPaid:
            return "Payment Complete"
        case .failed:
            return "Retry Payment"
        case .refunded:
            return "Refunded"
        case .notRequired:
            return "No Payment Required"
        }
    }
}

// MARK: - Booking Manager
class BookingManager: ObservableObject {
    @Published var userBookings: [Booking] = []
    @Published var businessBookings: [Booking] = []
    
    init() {
        loadSampleData()
    }
    
    // MARK: - Sample Data
    private func loadSampleData() {
        let sampleService = Service(
            name: "Hair Cut & Style",
            description: "Professional hair cutting and styling service",
            price: 45.00,
            duration: "1 hour",
            isAvailable: true,
            requiresDeposit: true,
            depositAmount: 15.00,
            depositType: .fixed
        )
        
        let sampleBusiness = Business(
            id: UUID(),
            name: "Campus Cuts",
            category: .hairStylist,
            description: "Your campus hair salon",
            rating: 4.8,
            priceRange: .moderate,
            imageURL: nil,
            isActive: true,
            location: "Student Union Building",
            contactInfo: ContactInfo(email: "cuts@campus.edu", phone: "(555) 123-4567"),
            services: [sampleService],
            availability: BusinessHours(
                monday: DayHours(openTime: Date(), closeTime: Date()),
                tuesday: DayHours(openTime: Date(), closeTime: Date()),
                wednesday: DayHours(openTime: Date(), closeTime: Date()),
                thursday: DayHours(openTime: Date(), closeTime: Date()),
                friday: DayHours(openTime: Date(), closeTime: Date()),
                saturday: nil,
                sunday: nil
            )
        )
        
        let sampleBooking = Booking(
            service: sampleService,
            business: sampleBusiness,
            customerName: "John Doe",
            customerEmail: "john@university.edu",
            customerPhone: "(555) 987-6543",
            appointmentDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            startTime: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
            endTime: Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date(),
            status: .confirmed,
            notes: "Please bring ID",
            totalPrice: sampleService.price,
            paymentStatus: .pending
        )
        
        userBookings = [sampleBooking]
    }
}