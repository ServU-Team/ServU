//
//  ServiceBookingView.swift
//  ServU
//
//  Created by Amber Still on 7/31/25.
//


//
//  ServiceBookingView.swift
//  ServU
//
//  Created by Quian Bowden on 7/29/25.
//  Updated by Assistant on 7/31/25.
//  Fixed imports and removed duplicate ServULoadingView
//

import SwiftUI
import Foundation

struct ServiceBookingView: View {
    let business: Business
    let service: ServUService // Using ServUService model
    @ObservedObject var userProfile: UserProfile
    @ObservedObject var bookingManager: BookingManager
    @StateObject private var paymentManager = PaymentManager()
    
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
                
                // Loading Overlay - Using ServULoadingView from RoundedCorner.swift
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
                        .fill(isActive ? userProfile.college?.primaryColor ?? .blue : Color.gray.opacity(0.3))
                        .frame(width: isCurrent ? 32 : 24, height: isCurrent ? 32 : 24)
                        .overlay(
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(isActive ? .white : .gray)
                        )
                        .animation(.spring(response: 0.3), value: currentStep)
                    
                    // Connector Line
                    if index < BookingStep.allCases.count - 1 {
                        Rectangle()
                            .fill(isActive ? userProfile.college?.primaryColor ?? .blue : Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Service Summary
    private var serviceSummaryView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(business.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(service.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                    
                    HStack(spacing: 16) {
                        Label(service.duration, systemImage: "clock")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "$%.0f", service.price))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                // Service Icon
                Circle()
                    .fill(userProfile.college?.primaryColor ?? .blue)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: business.category.icon)
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    )
            }
            
            Text(service.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
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
            additionalNotesView
        }
    }
    
    // MARK: - Date/Time Selection
    private var dateTimeSelectionView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select Date & Time")
                .font(.title2)
                .fontWeight(.bold)
            
            // Date Picker
            VStack(alignment: .leading, spacing: 12) {
                Text("Choose Date")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .accentColor(userProfile.college?.primaryColor ?? .blue)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Time Slots
            VStack(alignment: .leading, spacing: 12) {
                Text("Available Times")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(availableTimeSlots, id: \.id) { timeSlot in
                        TimeSlotButton(
                            timeSlot: timeSlot,
                            isSelected: selectedTimeSlot?.id == timeSlot.id,
                            userProfile: userProfile
                        ) {
                            selectedTimeSlot = timeSlot
                        }
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Confirmation Details
    private var confirmationDetailsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Confirm Your Booking")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                // Customer Info
                BookingConfirmationCard(title: "Customer Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        BookingInfoRow(label: "Name", value: userProfile.fullName)
                        BookingInfoRow(label: "Email", value: userProfile.email)
                        if !userProfile.phoneNumber.isEmpty {
                            BookingInfoRow(label: "Phone", value: userProfile.phoneNumber)
                        }
                    }
                }
                
                // Appointment Details
                BookingConfirmationCard(title: "Appointment Details") {
                    VStack(alignment: .leading, spacing: 8) {
                        BookingInfoRow(label: "Service", value: service.name)
                        BookingInfoRow(label: "Business", value: business.name)
                        BookingInfoRow(label: "Date", value: DateFormatter.bookingDate.string(from: selectedDate))
                        BookingInfoRow(label: "Time", value: selectedTimeSlot?.displayTime ?? "Not selected")
                        BookingInfoRow(label: "Duration", value: service.duration)
                        BookingInfoRow(label: "Price", value: String(format: "$%.0f", service.price))
                    }
                }
                
                // Location Info
                BookingConfirmationCard(title: "Location") {
                    HStack(spacing: 12) {
                        Image(systemName: "location.fill")
                            .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(business.location)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("Exact address will be provided after booking")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    // MARK: - Payment Information
    private var paymentInfoView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Payment Information")
                .font(.title2)
                .fontWeight(.bold)
            
            if service.requiresDeposit {
                BookingConfirmationCard(title: "Deposit Required") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Deposit Amount")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text(service.displayDepositAmount)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Remaining Balance")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text(String(format: "$%.2f", service.remainingBalance))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Deposit Policy")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text(service.depositPolicy)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineSpacing(2)
                        }
                        
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            
                            Text("The remaining balance will be charged after service completion")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            } else {
                BookingConfirmationCard(title: "Payment") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Total Amount")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text(String(format: "$%.2f", service.price))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.green)
                            
                            Text("Full payment will be processed after service completion")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    // MARK: - Additional Notes
    private var additionalNotesView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Additional Notes")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Special Requests or Notes (Optional)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                TextEditor(text: $additionalNotes)
                    .frame(minHeight: 120)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                
                Text("Let \(business.name) know about any special requirements or preferences.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
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
                    .background(userProfile.college?.primaryColor ?? .blue)
                    .cornerRadius(12)
            }
            .disabled(!canProceed)
            .opacity(canProceed ? 1.0 : 0.6)
            
            // Secondary Action Button
            if currentStep != .selectDateTime {
                Button(action: previousStep) {
                    Text("Back")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(userProfile.college?.primaryColor ?? .blue, lineWidth: 2)
                        )
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                userProfile.college?.colorScheme.background ?? Color(.systemGray6),
                Color(.systemBackground)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var availableTimeSlots: [TimeSlot] {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let isToday = calendar.isDate(selectedDate, inSameDayAs: Date())
        
        var slots: [TimeSlot] = []
        
        for h in 9...17 {
            if isToday && h <= hour + 1 { continue }
            
            let slot = TimeSlot(
                id: UUID(),
                startTime: calendar.date(bySettingHour: h, minute: 0, second: 0, of: selectedDate) ?? Date(),
                endTime: calendar.date(bySettingHour: h + 1, minute: 0, second: 0, of: selectedDate) ?? Date(),
                isAvailable: Bool.random()
            )
            
            if slot.isAvailable {
                slots.append(slot)
            }
        }
        
        return slots
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case .selectDateTime:
            return selectedTimeSlot != nil
        case .confirmDetails:
            return true
        case .paymentInfo:
            return true
        case .addNotes:
            return true
        }
    }
    
    private var primaryButtonTitle: String {
        switch currentStep {
        case .selectDateTime:
            return "Continue"
        case .confirmDetails:
            return "Review Payment"
        case .paymentInfo:
            return "Add Notes"
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
        
        // Convert ServUService to Booking-compatible format
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
            paymentManager.processDepositPayment(for: booking) { success, transactionId in
                if success {
                    var updatedBooking = booking
                    updatedBooking.paymentStatus = .depositPaid
                    updatedBooking.depositTransactionId = transactionId
                    
                    bookingManager.addBooking(updatedBooking)
                    isLoading = false
                    presentationMode.wrappedValue.dismiss()
                } else {
                    isLoading = false
                }
            }
        } else {
            var updatedBooking = booking
            updatedBooking.paymentStatus = .pending
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                bookingManager.addBooking(updatedBooking)
                isLoading = false
                presentationMode.wrappedValue.dismiss()
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