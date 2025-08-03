//
//  ServiceBookingView.swift
//  ServU
//
//  Created by Amber Still on 8/3/25.
//


//
//  ServiceBookingView.swift
//  ServU
//
//  Created by Quian Bowden on 7/29/25.
//  Updated by Quian Bowden on 8/2/25.
//  Fixed PaymentManager import and types
//

import SwiftUI
import Foundation

struct ServiceBookingView: View {
    let business: Business
    let service: ServUService
    @ObservedObject var userProfile: UserProfile
    @ObservedObject var bookingManager: BookingManager
    @StateObject private var paymentManager = PaymentManager() // Fixed: Use correct PaymentManager
    
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot: TimeSlot?
    @State private var additionalNotes = ""
    @State private var currentStep: BookingStep = .selectDateTime
    @State private var isLoading = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Progress Indicator
                        progressIndicatorView
                        
                        // Service Summary
                        serviceSummaryView
                        
                        // Step Content
                        stepContentView
                        
                        // Action Buttons
                        actionButtonsView
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Loading Overlay
                if isLoading {
                    ServULoadingView(message: "Booking your appointment...")
                }
            }
            .navigationTitle("Book Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemGroupedBackground),
                Color(.systemBackground)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Progress Indicator
    private var progressIndicatorView: some View {
        HStack(spacing: 0) {
            ForEach(BookingStep.allCases.indices, id: \.self) { index in
                let step = BookingStep.allCases[index]
                let isActive = step.rawValue <= currentStep.rawValue
                let isCurrent = step == currentStep
                
                HStack(spacing: 0) {
                    // Step Circle
                    Circle()
                        .fill(isActive ? (userProfile.college?.primaryColor ?? .blue) : Color.gray.opacity(0.3))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(isActive ? .white : .gray)
                        )
                        .scaleEffect(isCurrent ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: currentStep)
                    
                    // Connecting Line (except for last step)
                    if index < BookingStep.allCases.count - 1 {
                        Rectangle()
                            .fill(isActive ? (userProfile.college?.primaryColor ?? .blue) : Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Service Summary
    private var serviceSummaryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(service.name)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(service.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label("\(service.duration) minutes", systemImage: "clock")
                Spacer()
                Text("$\(String(format: "%.2f", service.price))")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.servURed)
            }
            .font(.subheadline)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Step Content
    @ViewBuilder
    private var stepContentView: some View {
        switch currentStep {
        case .selectDateTime:
            dateTimeSelectionView
        case .confirmDetails:
            confirmationDetailsView
        case .paymentInfo:
            paymentInfoView
        case .addNotes:
            notesView
        }
    }
    
    // MARK: - Date & Time Selection
    private var dateTimeSelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Date & Time")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Date Picker
            DatePicker(
                "Appointment Date",
                selection: $selectedDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            
            // Time Slots
            if !availableTimeSlots.isEmpty {
                Text("Available Times")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.top)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(availableTimeSlots) { slot in
                        TimeSlotButton(
                            timeSlot: slot,
                            isSelected: selectedTimeSlot?.id == slot.id,
                            userProfile: userProfile
                        ) {
                            selectedTimeSlot = slot
                        }
                    }
                }
            } else {
                Text("No available time slots for this date")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Confirmation Details
    private var confirmationDetailsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Confirm Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            BookingConfirmationCard(title: "Appointment Details") {
                VStack(alignment: .leading, spacing: 8) {
                    BookingInfoRow(label: "Service", value: service.name)
                    BookingInfoRow(label: "Date", value: DateFormatter.bookingDate.string(from: selectedDate))
                    BookingInfoRow(label: "Time", value: selectedTimeSlot?.displayTime ?? "Not selected")
                    BookingInfoRow(label: "Duration", value: "\(service.duration) minutes")
                    BookingInfoRow(label: "Price", value: "$\(String(format: "%.2f", service.price))")
                }
            }
        }
    }
    
    // MARK: - Payment Info
    private var paymentInfoView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            if service.requiresDeposit {
                BookingConfirmationCard(title: "Payment Options") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This service requires a deposit")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Deposit Amount:")
                                Spacer()
                                Text("$\(String(format: "%.2f", service.calculatedDepositAmount))")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.servURed)
                            }
                            
                            HStack {
                                Text("Remaining Balance:")
                                Spacer()
                                Text("$\(String(format: "%.2f", service.remainingBalance))")
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("The remaining balance will be due at your appointment")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                    }
                }
            } else {
                BookingConfirmationCard(title: "Payment") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Total Amount:")
                            Spacer()
                            Text("$\(String(format: "%.2f", service.price))")
                                .fontWeight(.semibold)
                                .foregroundColor(.servURed)
                        }
                        
                        Text("Payment will be processed upon booking confirmation")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Notes
    private var notesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Additional Notes")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextEditor(text: $additionalNotes)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text("Optional: Add any special requests or information")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Action Buttons
    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            // Primary Action Button
            Button(action: primaryAction) {
                Text(primaryButtonTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceed ? (userProfile.college?.primaryColor ?? .blue) : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!canProceed || isLoading)
            
            // Back Button (except on first step)
            if currentStep != .selectDateTime {
                Button(action: previousStep) {
                    Text("Back")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(userProfile.college?.primaryColor ?? .blue, lineWidth: 1)
                        )
                        .cornerRadius(8)
                }
                .disabled(isLoading)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var availableTimeSlots: [TimeSlot] {
        // Generate sample time slots for demo
        let calendar = Calendar.current
        let startHour = 9
        let endHour = 17
        var slots: [TimeSlot] = []
        
        for hour in startHour..<endHour {
            let startTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: selectedDate) ?? selectedDate
            let endTime = calendar.date(bySettingHour: hour + 1, minute: 0, second: 0, of: selectedDate) ?? selectedDate
            
            slots.append(TimeSlot(
                id: UUID(),
                startTime: startTime,
                endTime: endTime,
                isAvailable: true
            ))
        }
        
        return slots
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case .selectDateTime:
            return selectedTimeSlot != nil
        case .confirmDetails, .paymentInfo, .addNotes:
            return true
        }
    }
    
    private var primaryButtonTitle: String {
        switch currentStep {
        case .selectDateTime:
            return "Continue"
        case .confirmDetails:
            return "Continue"
        case .paymentInfo:
            return "Continue"
        case .addNotes:
            return service.requiresDeposit ? "Pay Deposit & Book" : "Book Appointment"
        }
    }
    
    // MARK: - Actions
    private func primaryAction() {
        switch currentStep {
        case .selectDateTime:
            currentStep = .confirmDetails
        case .confirmDetails:
            currentStep = .paymentInfo
        case .paymentInfo:
            currentStep = .addNotes
        case .addNotes:
            bookAppointment()
        }
    }
    
    private func previousStep() {
        switch currentStep {
        case .selectDateTime:
            break
        case .confirmDetails:
            currentStep = .selectDateTime
        case .paymentInfo:
            currentStep = .confirmDetails
        case .addNotes:
            currentStep = .paymentInfo
        }
    }
    
    private func bookAppointment() {
        guard let timeSlot = selectedTimeSlot else { return }
        
        isLoading = true
        
        // Create booking
        let booking = Booking(
            id: UUID(),
            service: service,
            business: business,
            customerName: userProfile.fullName,
            customerEmail: userProfile.email,
            customerPhone: userProfile.phoneNumber,
            appointmentDate: selectedDate,
            startTime: timeSlot.startTime,
            endTime: timeSlot.endTime,
            status: .confirmed,
            notes: additionalNotes,
            totalPrice: service.price
        )
        
        if service.requiresDeposit {
            // Process deposit payment
            paymentManager.processDepositPayment(for: booking) { success, error in
                DispatchQueue.main.async {
                    if success {
                        var updatedBooking = booking
                        updatedBooking.paymentStatus = .depositPaid
                        
                        bookingManager.addBooking(updatedBooking)
                        isLoading = false
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        isLoading = false
                        // Show error - could add alert here
                        print("Payment failed: \(error ?? "Unknown error")")
                    }
                }
            }
        } else {
            // Process full payment
            paymentManager.processFullPayment(for: booking) { success, error in
                DispatchQueue.main.async {
                    if success {
                        var updatedBooking = booking
                        updatedBooking.paymentStatus = .fullyPaid
                        
                        bookingManager.addBooking(updatedBooking)
                        isLoading = false
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        isLoading = false
                        // Show error - could add alert here
                        print("Payment failed: \(error ?? "Unknown error")")
                    }
                }
            }
        }
    }
}

// MARK: - Booking Steps
enum BookingStep: Int, CaseIterable {
    case selectDateTime = 0
    case confirmDetails = 1
    case paymentInfo = 2
    case addNotes = 3
}

// MARK: - Supporting Views

struct TimeSlotButton: View {
    let timeSlot: TimeSlot
    let isSelected: Bool
    @ObservedObject var userProfile: UserProfile
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(timeSlot.displayTime)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : (userProfile.college?.primaryColor ?? .blue))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? (userProfile.college?.primaryColor ?? .blue) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(userProfile.college?.primaryColor ?? .blue, lineWidth: 2)
                )
                .cornerRadius(8)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct BookingConfirmationCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            content
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct BookingInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let bookingDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()
}

// MARK: - Booking Model Extension
extension Booking {
    init(id: UUID, service: ServUService, business: Business, customerName: String, customerEmail: String, customerPhone: String, appointmentDate: Date, startTime: Date, endTime: Date, status: BookingStatus, notes: String, totalPrice: Double, paymentStatus: PaymentStatus = .pending) {
        self.id = id
        self.service = service.toLegacyService() // Convert ServUService to Service for compatibility
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
}