//
//  BookingManager.swift
//  ServU
//
//  Created by Amber Still on 8/9/25.
//


//
//  BookingManager.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  Booking logic and state management
//

import SwiftUI
import Foundation

class BookingManager: ObservableObject {
    @Published var userBookings: [Booking] = []
    @Published var currentBooking: Booking?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Booking Creation
    func createBooking(for service: Service, business: Business, selectedDate: Date, selectedTime: String, customerNotes: String = "") -> Booking {
        let booking = Booking(
            id: UUID(),
            serviceId: service.id,
            businessId: business.id,
            serviceName: service.name,
            businessName: business.name,
            customerName: "", // Will be filled from user profile
            customerEmail: "", // Will be filled from user profile
            date: selectedDate,
            time: selectedTime,
            duration: service.duration,
            totalPrice: service.price,
            depositRequired: service.requiresDeposit,
            depositAmount: service.depositAmount,
            customerNotes: customerNotes,
            status: .pending,
            createdAt: Date()
        )
        
        currentBooking = booking
        return booking
    }
    
    // MARK: - Booking Confirmation
    func confirmBooking() {
        guard let booking = currentBooking else { return }
        
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.userBookings.append(booking)
            self.currentBooking = nil
            self.isLoading = false
            
            // Schedule notification
            NotificationManager.shared.scheduleBookingReminder(for: booking)
        }
    }
    
    // MARK: - Booking Management
    func cancelBooking(_ booking: Booking) {
        if let index = userBookings.firstIndex(where: { $0.id == booking.id }) {
            userBookings[index].status = .cancelled
            
            // Cancel notification
            NotificationManager.shared.cancelBookingReminder(for: booking)
        }
    }
    
    func updateBookingStatus(_ booking: Booking, to status: BookingStatus) {
        if let index = userBookings.firstIndex(where: { $0.id == booking.id }) {
            userBookings[index].status = status
        }
    }
    
    // MARK: - Helper Methods
    func getUpcomingBookings() -> [Booking] {
        return userBookings.filter { 
            $0.status == .confirmed && $0.date >= Date() 
        }.sorted { $0.date < $1.date }
    }
    
    func getPastBookings() -> [Booking] {
        return userBookings.filter { 
            $0.date < Date() || $0.status == .completed
        }.sorted { $0.date > $1.date }
    }
}

// MARK: - Booking Model
struct Booking: Identifiable, Codable {
    let id: UUID
    let serviceId: UUID
    let businessId: UUID
    let serviceName: String
    let businessName: String
    let customerName: String
    let customerEmail: String
    let date: Date
    let time: String
    let duration: String
    let totalPrice: Double
    let depositRequired: Bool
    let depositAmount: Double
    let customerNotes: String
    var status: BookingStatus
    let createdAt: Date
    
    var paymentStatus: PaymentStatus = .pending
    var businessNotes: String?
    var reminderSent: Bool = false
}

// MARK: - Booking Status
enum BookingStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case inProgress = "In Progress"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case noShow = "No Show"
    
    var displayName: String {
        return self.rawValue
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
    
    var systemIcon: String {
        switch self {
        case .pending: return "clock.badge.questionmark"
        case .confirmed: return "checkmark.circle"
        case .inProgress: return "play.circle"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle"
        case .noShow: return "exclamationmark.triangle"
        }
    }
}

// MARK: - Payment Status
enum PaymentStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case depositPaid = "Deposit Paid"
    case fullPaid = "Fully Paid"
    case refunded = "Refunded"
    case failed = "Failed"
    
    var displayName: String {
        return self.rawValue
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .depositPaid: return .blue
        case .fullPaid: return .green
        case .refunded: return .gray
        case .failed: return .red
        }
    }
}