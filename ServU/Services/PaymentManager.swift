//
//  PaymentManager.swift
//  ServU
//
//  Created by Amber Still on 8/5/25.
//


//
//  PaymentManager.swift
//  ServU
//
//  Created by Quian Bowden on 8/4/25.
//

import Foundation
import SwiftUI

// MARK: - Payment Manager
class PaymentManager: ObservableObject {
    @Published var isProcessing = false
    @Published var lastPaymentStatus: PaymentStatus = .pending
    
    // MARK: - Service Payment Methods
    func processDepositPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        isProcessing = true
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Simulate successful payment (90% success rate)
            let success = Double.random(in: 0...1) > 0.1
            
            self.isProcessing = false
            self.lastPaymentStatus = success ? .depositPaid : .failed
            
            completion(success, success ? nil : "Payment failed. Please try again.")
        }
    }
    
    func processFullPayment(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        isProcessing = true
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Simulate successful payment (90% success rate)
            let success = Double.random(in: 0...1) > 0.1
            
            self.isProcessing = false
            self.lastPaymentStatus = success ? .fullyPaid : .failed
            
            completion(success, success ? nil : "Payment failed. Please try again.")
        }
    }
    
    func processRemainingBalance(for booking: Booking, completion: @escaping (Bool, String?) -> Void) {
        isProcessing = true
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Simulate successful payment (95% success rate for remaining balance)
            let success = Double.random(in: 0...1) > 0.05
            
            self.isProcessing = false
            self.lastPaymentStatus = success ? .fullyPaid : .failed
            
            completion(success, success ? nil : "Payment failed. Please try again.")
        }
    }
    
    // MARK: - Product Payment Methods
    func processCartPayment(for cart: ShoppingCartManager, completion: @escaping (Bool, String?) -> Void) {
        isProcessing = true
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Simulate successful payment (92% success rate)
            let success = Double.random(in: 0...1) > 0.08
            
            self.isProcessing = false
            self.lastPaymentStatus = success ? .fullyPaid : .failed
            
            if success {
                // Clear cart on successful payment
                cart.clearCart()
            }
            
            completion(success, success ? nil : "Payment failed. Please check your payment information and try again.")
        }
    }
    
    // MARK: - Payment Validation
    func validatePaymentAmount(_ amount: Double) -> Bool {
        return amount > 0 && amount <= 10000 // Max $10,000 per transaction
    }
    
    func formatPaymentAmount(_ amount: Double) -> String {
        return String(format: "$%.2f", amount)
    }
    
    // MARK: - Payment Status Updates
    func updatePaymentStatus(for bookingId: UUID, status: PaymentStatus) {
        // This would update the payment status in a real backend
        lastPaymentStatus = status
        objectWillChange.send()
    }
}

// MARK: - Booking Manager
class BookingManager: ObservableObject {
    @Published var userBookings: [Booking] = []
    @Published var businessBookings: [Booking] = []
    
    init() {
        loadSampleData()
    }
    
    // MARK: - Booking Operations
    func addBooking(_ booking: Booking) {
        userBookings.append(booking)
        objectWillChange.send()
    }
    
    func updateBooking(_ booking: Booking) {
        if let index = userBookings.firstIndex(where: { $0.id == booking.id }) {
            userBookings[index] = booking
            objectWillChange.send()
        }
    }
    
    func cancelBooking(_ booking: Booking, reason: String = "") {
        if let index = userBookings.firstIndex(where: { $0.id == booking.id }) {
            userBookings[index].status = .cancelled
            objectWillChange.send()
        }
    }
    
    func getUpcomingBookings() -> [Booking] {
        return userBookings.filter { $0.isUpcoming }
    }
    
    func getPastBookings() -> [Booking] {
        return userBookings.filter { !$0.isUpcoming }
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
        
        let timeSlot = TimeSlot(
            startTime: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
            endTime: Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date()
        )
        
        let sampleBooking = Booking(
            service: sampleService,
            businessId: "sample_business_123",
            businessName: "Campus Cuts",
            clientName: "John Doe",
            clientEmail: "john@university.edu",
            clientPhone: "(555) 987-6543",
            timeSlot: timeSlot,
            specialRequests: "Please bring ID"
        )
        
        userBookings = [sampleBooking]
    }
}