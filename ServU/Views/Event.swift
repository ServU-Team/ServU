//
//  Event.swift
//  ServU
//
//  Created by Amber Still on 7/31/25.
//


//
//  Events System Models and Views
//  ServU
//
//  Created by Quian Bowden on 7/31/25.
//

import Foundation
import SwiftUI

// MARK: - Event Model
struct Event: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var category: EventCategory
    var eventDate: Date
    var startTime: Date
    var endTime: Date
    var location: String
    var organizer: String
    var organizerEmail: String
    var imageURL: String?
    var isActive: Bool = true
    
    // Ticketing
    var ticketingEnabled: Bool = false
    var ticketPrice: Double = 0.0
    var totalTickets: Int = 0
    var soldTickets: Int = 0
    var requiresApproval: Bool = false
    
    // Event details
    var ageRestriction: AgeRestriction = .none
    var dressCode: String = ""
    var additionalInfo: String = ""
    var tags: [String] = []
    var createdAt: Date = Date()
    
    // Computed properties
    var availableTickets: Int {
        return totalTickets - soldTickets
    }
    
    var isTicketAvailable: Bool {
        return ticketingEnabled && availableTickets > 0
    }
    
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: eventDate)
    }
    
    var displayTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    var formattedTicketPrice: String {
        if ticketPrice == 0 {
            return "FREE"
        }
        return String(format: "$%.2f", ticketPrice)
    }
}

// MARK: - Event Category
enum EventCategory: String, CaseIterable {
    case social = "Social"
    case academic = "Academic"
    case sports = "Sports"
    case cultural = "Cultural"
    case career = "Career"
    case entertainment = "Entertainment"
    case community = "Community Service"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .social: return "person.3.fill"
        case .academic: return "book.fill"
        case .sports: return "sportscourt.fill"
        case .cultural: return "theatermasks.fill"
        case .career: return "briefcase.fill"
        case .entertainment: return "music.note"
        case .community: return "heart.fill"
        case .other: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .social: return .blue
        case .academic: return .green
        case .sports: return .orange
        case .cultural: return .purple
        case .career: return .red
        case .entertainment: return .pink
        case .community: return .yellow
        case .other: return .gray
        }
    }
}

// MARK: - Age Restriction
enum AgeRestriction: String, CaseIterable {
    case none = "All Ages"
    case eighteen = "18+"
    case twentyone = "21+"
    
    var description: String {
        return self.rawValue
    }
}

// MARK: - Event Ticket Model
struct EventTicket: Identifiable {
    let id = UUID()
    let eventId: UUID
    let attendeeName: String
    let attendeeEmail: String
    let ticketType: TicketType
    let purchaseDate: Date
    let ticketCode: String
    let price: Double
    var status: TicketStatus = .active
    
    init(eventId: UUID, attendeeName: String, attendeeEmail: String, ticketType: TicketType, price: Double) {
        self.eventId = eventId
        self.attendeeName = attendeeName
        self.attendeeEmail = attendeeEmail
        self.ticketType = ticketType
        self.price = price
        self.purchaseDate = Date()
        self.ticketCode = "TK\(UUID().uuidString.prefix(8).uppercased())"
    }
}

// MARK: - Ticket Type
enum TicketType: String, CaseIterable {
    case general = "General Admission"
    case vip = "VIP"
    case student = "Student"
    case early = "Early Bird"
    
    var description: String {
        return self.rawValue
    }
}

// MARK: - Ticket Status
enum TicketStatus: String, CaseIterable {
    case active = "Active"
    case used = "Used"
    case cancelled = "Cancelled"
    case refunded = "Refunded"
    
    var color: Color {
        switch self {
        case .active: return .green
        case .used: return .blue
        case .cancelled: return .gray
        case .refunded: return .red
        }
    }
}

// MARK: - Events Manager
class EventsManager: ObservableObject {
    @Published var events: [Event] = []
    @Published var userTickets: [EventTicket] = []
    @Published var isLoading = false
    
    init() {
        loadSampleEvents()
    }
    
    // MARK: - Public Methods
    func addEvent(_ event: Event) {
        events.append(event)
        events.sort { $0.eventDate < $1.eventDate }
    }
    
    func updateEvent(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        }
    }
    
    func deleteEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
    }
    
    func purchaseTicket(for event: Event, attendeeName: String, attendeeEmail: String) -> Bool {
        guard event.isTicketAvailable else { return false }
        
        let ticket = EventTicket(
            eventId: event.id,
            attendeeName: attendeeName,
            attendeeEmail: attendeeEmail,
            ticketType: .general,
            price: event.ticketPrice
        )
        
        userTickets.append(ticket)
        
        // Update event sold tickets
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index].soldTickets += 1
        }
        
        return true
    }
    
    func getUpcomingEvents() -> [Event] {
        return events.filter { $0.eventDate >= Date() && $0.isActive }
    }
    
    func getPastEvents() -> [Event] {
        return events.filter { $0.eventDate < Date() }
    }
    
    func searchEvents(query: String) -> [Event] {
        guard !query.isEmpty else { return events }
        
        return events.filter { event in
            event.title.localizedCaseInsensitiveContains(query) ||
            event.description.localizedCaseInsensitiveContains(query) ||
            event.organizer.localizedCaseInsensitiveContains(query) ||
            event.location.localizedCaseInsensitiveContains(query)
        }
    }
    
    // MARK: - Private Methods
    private func loadSampleEvents() {
        // Add some sample events for demonstration
        let sampleEvents: [Event] = [
            Event(
                title: "Campus Movie Night",
                description: "Join us for a movie night under the stars! We'll be showing popular movies with free popcorn and drinks.",
                category: .entertainment,
                eventDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                startTime: Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date(),
                location: "University Quad",
                organizer: "Student Activities Board",
                organizerEmail: "activities@college.edu",
                ticketingEnabled: false
            ),
            
            Event(
                title: "Spring Formal Dance",
                description: "Get dressed up for our annual spring formal! DJ, dancing, and dinner included.",
                category: .social,
                eventDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date(),
                startTime: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date()) ?? Date(),
                location: "Student Union Ballroom",
                organizer: "Greek Life Council",
                organizerEmail: "greek@college.edu",
                ticketingEnabled: true,
                ticketPrice: 25.0,
                totalTickets: 200,
                soldTickets: 45,
                dressCode: "Semi-formal attire required"
            )
        ]
        
        events = sampleEvents
    }
}

// MARK: - Create Event View
struct CreateEventView: View {
    @ObservedObject var userProfile: UserProfile
    @ObservedObject var eventsManager: EventsManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: EventCategory = .social
    @State private var eventDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var startTime = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var endTime = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var location = ""
    @State private var ticketingEnabled = false
    @State private var ticketPrice: Double = 0
    @State private var totalTickets = 100
    @State private var selectedAgeRestriction: AgeRestriction = .none
    @State private var dressCode = ""
    @State private var additionalInfo = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Event Basic Info
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Event Details")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        
                        EventFormCard(title: "Basic Information") {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Event Title *")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    TextField("Enter event title", text: $title)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Description *")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    TextEditor(text: $description)
                                        .frame(minHeight: 80)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Category *")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Picker("Category", selection: $selectedCategory) {
                                        ForEach(EventCategory.allCases, id: \.self) { category in
                                            HStack {
                                                Image(systemName: category.icon)
                                                    .foregroundColor(category.color)
                                                Text(category.rawValue)
                                            }
                                            .tag(category)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Location *")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    TextField("e.g., Student Union Room 201", text: $location)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                        }
                        
                        EventFormCard(title: "Date & Time") {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Event Date *")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    DatePicker("", selection: $eventDate, in: Date()..., displayedComponents: .date)
                                        .datePickerStyle(CompactDatePickerStyle())
                                        .accentColor(userProfile.college?.primaryColor ?? .blue)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Start Time *")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(CompactDatePickerStyle())
                                        .accentColor(userProfile.college?.primaryColor ?? .blue)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("End Time *")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(CompactDatePickerStyle())
                                        .accentColor(userProfile.college?.primaryColor ?? .blue)
                                }
                            }
                        }
                        
                        EventFormCard(title: "Ticketing") {
                            VStack(alignment: .leading, spacing: 16) {
                                Toggle("Enable Ticketing", isOn: $ticketingEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: userProfile.college?.primaryColor ?? .blue))
                                
                                if ticketingEnabled {
                                    VStack(alignment: .leading, spacing: 16) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Ticket Price")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            HStack {
                                                Text("$")
                                                    .font(.headline)
                                                    .foregroundColor(.secondary)
                                                
                                                TextField("0.00", value: $ticketPrice, format: .number)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                                    .keyboardType(.decimalPad)
                                            }
                                            
                                            Text("Set to 0 for free events")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Total Tickets Available")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            TextField("100", value: $totalTickets, format: .number)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                .keyboardType(.numberPad)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6).opacity(0.5))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        EventFormCard(title: "Additional Details") {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Age Restriction")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Picker("Age Restriction", selection: $selectedAgeRestriction) {
                                        ForEach(AgeRestriction.allCases, id: \.self) { restriction in
                                            Text(restriction.description).tag(restriction)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Dress Code (Optional)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    TextField("e.g., Casual, Business attire, etc.", text: $dressCode)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Additional Information (Optional)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    TextEditor(text: $additionalInfo)
                                        .frame(minHeight: 60)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: createEvent) {
                            Text("Create Event")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(userProfile.college?.primaryColor ?? .blue)
                                .cornerRadius(12)
                        }
                        .disabled(!canCreateEvent)
                        .opacity(canCreateEvent ? 1.0 : 0.6)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        userProfile.college?.colorScheme.background ?? Color(.systemGray6),
                        Color(.systemBackground)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
        }
    }
    
    private var canCreateEvent: Bool {
        return !title.isEmpty && 
               !description.isEmpty && 
               !location.isEmpty &&
               startTime < endTime
    }
    
    private func createEvent() {
        // Combine event date with start/end times
        let calendar = Calendar.current
        let eventStartDateTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: startTime),
            minute: calendar.component(.minute, from: startTime),
            second: 0,
            of: eventDate
        ) ?? startTime
        
        let eventEndDateTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: endTime),
            minute: calendar.component(.minute, from: endTime),
            second: 0,
            of: eventDate
        ) ?? endTime
        
        let newEvent = Event(
            title: title,
            description: description,
            category: selectedCategory,
            eventDate: eventDate,
            startTime: eventStartDateTime,
            endTime: eventEndDateTime,
            location: location,
            organizer: userProfile.fullName,
            organizerEmail: userProfile.email,
            ticketingEnabled: ticketingEnabled,
            ticketPrice: ticketPrice,
            totalTickets: ticketingEnabled ? totalTickets : 0,
            ageRestriction: selectedAgeRestriction,
            dressCode: dressCode,
            additionalInfo: additionalInfo
        )
        
        eventsManager.addEvent(newEvent)
        HapticFeedback.success()
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Event Card Component
struct EventCard: View {
    let event: Event
    @ObservedObject var userProfile: UserProfile
    @State private var showingEventDetail = false
    
    var body: some View {
        Button(action: { showingEventDetail = true }) {
            VStack(alignment: .leading, spacing: 16) {
                // Event Header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 8) {
                            Image(systemName: event.category.icon)
                                .foregroundColor(event.category.color)
                            
                            Text(event.category.rawValue)
                                .font(.subheadline)
                                .foregroundColor(event.category.color)
                                .fontWeight(.medium)
                        }
                    }
                    
                    Spacer()
                    
                    if event.ticketingEnabled {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(event.formattedTicketPrice)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(event.ticketPrice == 0 ? .green : .primary)
                            
                            if event.totalTickets > 0 {
                                Text("\(event.availableTickets) left")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Event Details
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text(event.displayDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text(event.displayTime)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.secondary)
                        Text(event.location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("by \(event.organizer)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
                Text(event.description)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .servUCardShadow()
        }
        .sheet(isPresented: $showingEventDetail) {
            EventDetailView(event: event, userProfile: userProfile)
        }
    }
}

// MARK: - Event Form Card Component
struct EventFormCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            content
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .servUCardShadow()
    }
}

// MARK: - Event Detail View
struct EventDetailView: View {
    let event: Event
    @ObservedObject var userProfile: UserProfile
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Event Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: event.category.icon)
                                .font(.title)
                                .foregroundColor(event.category.color)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text(event.category.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(event.category.color)
                            }
                            
                            Spacer()
                        }
                        
                        Text(event.description)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .servUCardShadow()
                    
                    // Event Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Event Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            EventInfoRow(icon: "calendar", title: "Date", value: event.displayDate)
                            EventInfoRow(icon: "clock", title: "Time", value: event.displayTime)
                            EventInfoRow(icon: "location", title: "Location", value: event.location)
                            EventInfoRow(icon: "person", title: "Organizer", value: event.organizer)
                            
                            if event.ageRestriction != .none {
                                EventInfoRow(icon: "person.badge.shield.checkmark", title: "Age Restriction", value: event.ageRestriction.description)
                            }
                            
                            if !event.dressCode.isEmpty {
                                EventInfoRow(icon: "tshirt", title: "Dress Code", value: event.dressCode)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .servUCardShadow()
                    
                    // Ticketing Info
                    if event.ticketingEnabled {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Tickets")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Price:")
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(event.formattedTicketPrice)
                                        .fontWeight(.bold)
                                        .foregroundColor(event.ticketPrice == 0 ? .green : .primary)
                                }
                                
                                HStack {
                                    Text("Available:")
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text("\(event.availableTickets) of \(event.totalTickets)")
                                        .fontWeight(.medium)
                                        .foregroundColor(event.availableTickets > 0 ? .green : .red)
                                }
                            }
                            
                            if event.isTicketAvailable {
                                Button("Get Ticket") {
                                    // TODO: Implement ticket purchase
                                }
                                .buttonStyle(ServUPrimaryButtonStyle(backgroundColor: userProfile.college?.primaryColor ?? .blue))
                            } else {
                                Text("Sold Out")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .servUCardShadow()
                    }
                    
                    if !event.additionalInfo.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Additional Information")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(event.additionalInfo)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .servUCardShadow()
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        userProfile.college?.colorScheme.background ?? Color(.systemGray6),
                        Color(.systemBackground)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
        }
    }
}

// MARK: - Event Info Row Component
struct EventInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(title)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    EventsView(userProfile: UserProfile())
}