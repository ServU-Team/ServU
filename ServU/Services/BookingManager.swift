//
//  BookingManager.swift
//  ServU
//
//  Created by Amber Still on 7/31/25.
//


//
//  BookingManager.swift
//  ServU
//
//  Created by Quian Bowden on 7/29/25.
//  Updated by Assistant on 7/31/25.
//  Fixed PaymentStatus naming conflict
//

import Foundation
import SwiftUI

// MARK: - Booking Manager
class BookingManager: ObservableObject {
    @Published var userBookings: [Booking] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadSampleBookings()
    }
    
    // MARK: - Public Methods
    
    func addBooking(_ booking: Booking) {
        userBookings.append(booking)
        userBookings.sort { $0.appointmentDate < $1.appointmentDate }
        
        // TODO: Save to backend
        print("✅ DEBUG: Booking added for \(booking.service.name) on \(booking.appointmentDate)")
    }
    
    func cancelBooking(_ booking: Booking) {
        if let index = userBookings.firstIndex(where: { $0.id == booking.id }) {
            userBookings[index].status = .cancelled
            
            // TODO: Call backend API to cancel
            print("❌ DEBUG: Booking cancelled for \(booking.service.name)")
        }
    }
    
    func rescheduleBooking(_ booking: Booking, newDate: Date, newTimeSlot: TimeSlot) {
        if let index = userBookings.firstIndex(where: { $0.id == booking.id }) {
            userBookings[index].appointmentDate = newDate
            userBookings[index].startTime = newTimeSlot.startTime
            userBookings[index].endTime = newTimeSlot.endTime
            userBookings[index].status = .confirmed
            
            // TODO: Call backend API to reschedule
            print("🔄 DEBUG: Booking rescheduled for \(booking.service.name)")
        }
    }
    
    func getUpcomingBookings() -> [Booking] {
        return userBookings.filter { 
            $0.appointmentDate >= Date() && 
            ($0.status == .confirmed || $0.status == .pending)
        }
    }
    
    func getPastBookings() -> [Booking] {
        return userBookings.filter { 
            $0.appointmentDate < Date() || 
            $0.status == .completed || 
            $0.status == .cancelled
        }
    }
    
    // MARK: - Private Methods
    
    private func loadSampleBookings() {
        // Create some sample bookings for testing
        let sampleBookings: [Booking] = [
            Booking(
                id: UUID(),
                service: Service(
                    name: "Portrait Session", 
                    description: "Professional headshots", 
                    price: 75.0, 
                    duration: "1 hour", 
                    requiresDeposit: true,
                    depositAmount: 25.0
                ),
                business: Business(
                    name: "Leek Editz",
                    category: .photoVideo,
                    description: "Professional photography services",
                    rating: 5.0,
                    priceRange: .moderate,
                    location: "Tuskegee University Campus",
                    contactInfo: ContactInfo(email: "leek@example.com", phone: "(334) 555-0123"),
                    availability: BusinessHours.defaultHours
                ),
                customerName: "Your Name",
                customerEmail: "you@example.com",
                customerPhone: "(555) 123-4567",
                appointmentDate: Date().addingTimeInterval(86400 * 3), // 3 days from now
                startTime: Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date().addingTimeInterval(86400 * 3)) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date().addingTimeInterval(86400 * 3)) ?? Date(),
                status: .confirmed,
                notes: "Please bring casual and formal outfits",
                totalPrice: 75.0,
                paymentStatus: .depositPaid
            ),
            
            Booking(
                id: UUID(),
                service: Service(
                    name: "Haircut & Style", 
                    description: "Complete haircut and styling", 
                    price: 35.0, 
                    duration: "1 hour",
                    requiresDeposit: false
                ),
                business: Business(
                    name: "Golden Tiger Cuts",
                    category: .barber,
                    description: "Professional barbering services",
                    rating: 4.8,
                    priceRange: .budget,
                    location: "Near Tuskegee Campus",
                    contactInfo: ContactInfo(email: "tiger@example.com", phone: "(334) 555-0456"),
                    availability: BusinessHours.defaultHours
                ),
                customerName: "Your Name",
                customerEmail: "you@example.com",
                customerPhone: "(555) 123-4567",
                appointmentDate: Date().addingTimeInterval(86400 * 7), // 1 week from now
                startTime: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date().addingTimeInterval(86400 * 7)) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date().addingTimeInterval(86400 * 7)) ?? Date(),
                status: .confirmed,
                notes: "",
                totalPrice: 35.0,
                paymentStatus: .notRequired
            )
        ]
        
        userBookings = sampleBookings
    }
}

// MARK: - Booking Model
struct Booking: Identifiable {
    let id: UUID
    let service: Service
    let business: Business
    var customerName: String
    var customerEmail: String
    var customerPhone: String
    var appointmentDate: Date
    var startTime: Date
    var endTime: Date
    var status: BookingStatus
    var notes: String
    var totalPrice: Double
    var paymentStatus: PaymentStatus  // Using the unified PaymentStatus from ServUService.swift
    var createdAt: Date
    var depositTransactionId: String?
    
    // Legacy support for old payment status values
    static let notRequired = PaymentStatus.fullyPaid // Map old "not required" to fully paid
    
    init(id: UUID, service: Service, business: Business, customerName: String, customerEmail: String, customerPhone: String, appointmentDate: Date, startTime: Date, endTime: Date, status: BookingStatus, notes: String, totalPrice: Double, paymentStatus: PaymentStatus = .pending) {
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
            return !service.requiresDeposit // If no deposit required, need full payment
        case .fullyPaid, .refunded, .failed:
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
            return "Paid in Full"
        case .refunded:
            return "Refunded"
        case .failed:
            return "Payment Failed - Retry"
        }
    }
}

// MARK: - Booking Status
enum BookingStatus: String, CaseIterable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case noShow = "No Show"
    
    var color: Color {
        switch self {
        case .pending:
            return .orange
        case .confirmed:
            return .green
        case .completed:
            return .blue
        case .cancelled:
            return .red
        case .noShow:
            return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .pending:
            return "clock"
        case .confirmed:
            return "checkmark.circle"
        case .completed:
            return "checkmark.circle.fill"
        case .cancelled:
            return "xmark.circle"
        case .noShow:
            return "exclamationmark.circle"
        }
    }
}

// MARK: - Time Slot Model
struct TimeSlot: Identifiable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let isAvailable: Bool
    
    var displayTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
    
    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
}

// MARK: - Booking Notification Helper
class BookingNotificationManager {
    static func scheduleBookingReminder(for booking: Booking) {
        // TODO: Implement local notifications
        print("📅 DEBUG: Reminder scheduled for \(booking.service.name) on \(booking.displayDate)")
    }
    
    static func cancelBookingReminder(for booking: Booking) {
        // TODO: Cancel local notification
        print("🔕 DEBUG: Reminder cancelled for \(booking.service.name)")
    }
}

// MARK: - Calendar Integration Helper
class CalendarIntegrationHelper {
    static func addBookingToCalendar(_ booking: Booking) {
        // TODO: Implement EventKit integration to add to system calendar
        print("📅 DEBUG: Adding booking to calendar: \(booking.service.name)")
    }
    
    static func removeBookingFromCalendar(_ booking: Booking) {
        // TODO: Remove from system calendar
        print("📅 DEBUG: Removing booking from calendar: \(booking.service.name)")
    }
}