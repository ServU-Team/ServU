//
//  Service.swift
//  ServU
//
//  Created by Amber Still on 8/6/25.
//


//
//  Service.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  Fixed by Quian Bowden on 8/6/25.
//  Resolved all compilation errors and ambiguous type references
//

import Foundation
import SwiftUI

// MARK: - Service Model (Primary Service Model)
struct Service: Codable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    var price: Double
    var duration: String
    var isAvailable: Bool
    var category: ServiceCategory?
    var images: [ServiceImage]
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
        case id, name, description, price, duration, isAvailable, category
        case images, requirements, cancellationPolicy
        case requiresDeposit, depositAmount, depositType, depositPolicy
        case createdDate, lastModified
    }
    
    init(
        name: String,
        description: String,
        price: Double,
        duration: String,
        isAvailable: Bool = true,
        category: ServiceCategory? = nil,
        images: [ServiceImage] = [],
        requirements: [String] = [],
        cancellationPolicy: String = "24 hours notice required",
        requiresDeposit: Bool = false,
        depositAmount: Double = 0.0,
        depositType: DepositType = .fixed,
        depositPolicy: String = ""
    ) {
        self.id = UUID()
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
    
    // MARK: - Codable Implementation
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.price = try container.decode(Double.self, forKey: .price)
        self.duration = try container.decode(String.self, forKey: .duration)
        self.isAvailable = try container.decodeIfPresent(Bool.self, forKey: .isAvailable) ?? true
        self.category = try container.decodeIfPresent(ServiceCategory.self, forKey: .category)
        self.images = try container.decodeIfPresent([ServiceImage].self, forKey: .images) ?? []
        self.requirements = try container.decodeIfPresent([String].self, forKey: .requirements) ?? []
        self.cancellationPolicy = try container.decodeIfPresent(String.self, forKey: .cancellationPolicy) ?? "24 hours notice required"
        self.requiresDeposit = try container.decodeIfPresent(Bool.self, forKey: .requiresDeposit) ?? false
        self.depositAmount = try container.decodeIfPresent(Double.self, forKey: .depositAmount) ?? 0.0
        self.depositType = try container.decodeIfPresent(DepositType.self, forKey: .depositType) ?? .fixed
        self.depositPolicy = try container.decodeIfPresent(String.self, forKey: .depositPolicy) ?? ""
        self.createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date()
        self.lastModified = try container.decodeIfPresent(Date.self, forKey: .lastModified) ?? Date()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(price, forKey: .price)
        try container.encode(duration, forKey: .duration)
        try container.encode(isAvailable, forKey: .isAvailable)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encode(images, forKey: .images)
        try container.encode(requirements, forKey: .requirements)
        try container.encode(cancellationPolicy, forKey: .cancellationPolicy)
        try container.encode(requiresDeposit, forKey: .requiresDeposit)
        try container.encode(depositAmount, forKey: .depositAmount)
        try container.encode(depositType, forKey: .depositType)
        try container.encode(depositPolicy, forKey: .depositPolicy)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(lastModified, forKey: .lastModified)
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
    
    var primaryImage: ServiceImage? {
        return images.first(where: { $0.isPrimary }) ?? images.first
    }
    
    var formattedDuration: String {
        return duration
    }
    
    var isValidService: Bool {
        return !name.isEmpty && 
               !description.isEmpty && 
               price > 0 && 
               !duration.isEmpty
    }
}

// MARK: - Service Booking
struct Booking: Identifiable, Codable {
    let id: UUID
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
        case id, service, businessId, businessName, clientName, clientEmail, clientPhone
        case timeSlot, status, paymentStatus, totalCost, depositPaid, remainingBalance
        case specialRequests, cancellationReason, createdDate, lastModified
    }
    
    init(
        service: Service,
        businessId: String,
        businessName: String,
        clientName: String,
        clientEmail: String,
        clientPhone: String? = nil,
        timeSlot: TimeSlot,
        specialRequests: String? = nil
    ) {
        self.id = UUID()
        self.service = service
        self.businessId = businessId
        self.businessName = businessName
        self.clientName = clientName
        self.clientEmail = clientEmail
        self.clientPhone = clientPhone
        self.timeSlot = timeSlot
        self.status = BookingStatus.pending
        self.paymentStatus = service.requiresDeposit ? PaymentStatus.pending : PaymentStatus.notRequired
        self.totalCost = service.price
        self.depositPaid = 0.0
        self.remainingBalance = service.price
        self.specialRequests = specialRequests
        self.createdDate = Date()
        self.lastModified = Date()
    }
    
    // MARK: - Codable Implementation
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.service = try container.decode(Service.self, forKey: .service)
        self.businessId = try container.decode(String.self, forKey: .businessId)
        self.businessName = try container.decode(String.self, forKey: .businessName)
        self.clientName = try container.decode(String.self, forKey: .clientName)
        self.clientEmail = try container.decode(String.self, forKey: .clientEmail)
        self.clientPhone = try container.decodeIfPresent(String.self, forKey: .clientPhone)
        self.timeSlot = try container.decode(TimeSlot.self, forKey: .timeSlot)
        self.status = try container.decode(BookingStatus.self, forKey: .status)
        self.paymentStatus = try container.decode(PaymentStatus.self, forKey: .paymentStatus)
        self.totalCost = try container.decode(Double.self, forKey: .totalCost)
        self.depositPaid = try container.decodeIfPresent(Double.self, forKey: .depositPaid) ?? 0.0
        self.remainingBalance = try container.decode(Double.self, forKey: .remainingBalance)
        self.specialRequests = try container.decodeIfPresent(String.self, forKey: .specialRequests)
        self.cancellationReason = try container.decodeIfPresent(String.self, forKey: .cancellationReason)
        self.createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date()
        self.lastModified = try container.decodeIfPresent(Date.self, forKey: .lastModified) ?? Date()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(service, forKey: .service)
        try container.encode(businessId, forKey: .businessId)
        try container.encode(businessName, forKey: .businessName)
        try container.encode(clientName, forKey: .clientName)
        try container.encode(clientEmail, forKey: .clientEmail)
        try container.encodeIfPresent(clientPhone, forKey: .clientPhone)
        try container.encode(timeSlot, forKey: .timeSlot)
        try container.encode(status, forKey: .status)
        try container.encode(paymentStatus, forKey: .paymentStatus)
        try container.encode(totalCost, forKey: .totalCost)
        try container.encode(depositPaid, forKey: .depositPaid)
        try container.encode(remainingBalance, forKey: .remainingBalance)
        try container.encodeIfPresent(specialRequests, forKey: .specialRequests)
        try container.encodeIfPresent(cancellationReason, forKey: .cancellationReason)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(lastModified, forKey: .lastModified)
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
        return status == BookingStatus.pending || status == BookingStatus.confirmed
    }
    
    var canReschedule: Bool {
        return status == BookingStatus.pending || status == BookingStatus.confirmed
    }
    
    var isUpcoming: Bool {
        return timeSlot.startTime > Date() && 
               (status == BookingStatus.confirmed || status == BookingStatus.pending)
    }
    
    var isPast: Bool {
        return timeSlot.endTime < Date()
    }
    
    var requiresPayment: Bool {
        return paymentStatus == PaymentStatus.pending || 
               (paymentStatus == PaymentStatus.depositPaid && remainingBalance > 0)
    }
    
    var isCompleted: Bool {
        return status == BookingStatus.completed
    }
    
    var isCancelled: Bool {
        return status == BookingStatus.cancelled
    }
    
    var statusDisplayText: String {
        return status.displayName
    }
    
    var paymentStatusDisplayText: String {
        return paymentStatus.rawValue
    }
}

// MARK: - Service Extensions
extension Service {
    /// Creates a sample service for testing
    static var sampleService: Service {
        return Service(
            name: "Hair Cut & Style",
            description: "Professional hair cutting and styling service for all hair types",
            price: 45.00,
            duration: "60 minutes",
            isAvailable: true,
            category: ServiceCategory.hairStylist,
            images: [],
            requirements: ["Please arrive 5 minutes early", "Bring a valid ID"],
            cancellationPolicy: "24 hours notice required for cancellation",
            requiresDeposit: true,
            depositAmount: 15.00,
            depositType: DepositType.fixed,
            depositPolicy: "Deposit is non-refundable if cancelled within 24 hours"
        )
    }
    
    /// Updates the last modified date
    mutating func updateLastModified() {
        self.lastModified = Date()
    }
    
    /// Checks if the service is bookable
    var isBookable: Bool {
        return isAvailable && isValidService
    }
}

// MARK: - Booking Extensions
extension Booking {
    /// Updates the booking status and last modified date
    mutating func updateStatus(to newStatus: BookingStatus) {
        self.status = newStatus
        self.lastModified = Date()
    }
    
    /// Updates the payment status and amounts
    mutating func updatePaymentStatus(to newStatus: PaymentStatus, depositPaid: Double = 0) {
        self.paymentStatus = newStatus
        self.depositPaid = depositPaid
        self.remainingBalance = totalCost - depositPaid
        self.lastModified = Date()
    }
    
    /// Cancels the booking with a reason
    mutating func cancel(reason: String) {
        self.status = BookingStatus.cancelled
        self.cancellationReason = reason
        self.lastModified = Date()
    }
    
    /// Creates a sample booking for testing
    static func sampleBooking() -> Booking {
        let sampleTimeSlot = TimeSlot(
            startTime: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
            endTime: Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date()
        )
        
        return Booking(
            service: Service.sampleService,
            businessId: "sample_business_123",
            businessName: "Campus Cuts",
            clientName: "John Doe",
            clientEmail: "john.doe@university.edu",
            clientPhone: "(555) 123-4567",
            timeSlot: sampleTimeSlot,
            specialRequests: "Please use organic products if available"
        )
    }
}
