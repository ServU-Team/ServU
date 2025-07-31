//
//  BusinessDetailView.swift
//  ServU
//
//  Created by Amber Still on 7/31/25.
//


//
//  BusinessDetailView.swift
//  ServU
//
//  Created by Quian Bowden on 6/27/25.
//  Updated by Assistant on 7/31/25.
//  Fixed Service/ServUService conversion issues
//

import SwiftUI

struct BusinessDetailView: View {
    let business: Business
    @ObservedObject var userProfile: UserProfile
    @StateObject private var bookingManager = BookingManager()
    
    @State private var selectedService: Service?
    @State private var showingBookingFlow = false
    @State private var selectedTab: DetailTab = .overview
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Business Header
                    businessHeaderView
                    
                    // Tab Selector
                    tabSelectorView
                    
                    // Tab Content
                    tabContentView
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationBarHidden(true)
            .background(backgroundGradient)
            .sheet(isPresented: $showingBookingFlow) {
                // ✅ FIXED: Convert Service to ServUService for compatibility
                if let selectedService = selectedService {
                    ServiceBookingView(
                        business: business,
                        service: selectedService.toServUService(), // Convert to ServUService
                        userProfile: userProfile,
                        bookingManager: bookingManager
                    )
                }
            }
        }
    }
    
    // MARK: - Business Header
    private var businessHeaderView: some View {
        VStack(spacing: 0) {
            // Back Button and Actions
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: { /* TODO: Add to favorites */ }) {
                        Image(systemName: "heart")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Button(action: { /* TODO: Share business */ }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
            .zIndex(1)
            
            // Business Image
            ZStack {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [userProfile.college?.primaryColor ?? .red, userProfile.college?.secondaryColor ?? .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 280)
                
                // Placeholder business icon
                VStack {
                    Image(systemName: business.category.icon)
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(business.category.rawValue)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            
            // Business Info Overlay
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(business.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(business.category.displayName)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        HStack(spacing: 16) {
                            // Rating
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", business.rating))
                                    .fontWeight(.semibold)
                                Text("(\(Int.random(in: 15...50)) reviews)")
                                    .opacity(0.8)
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            
                            // Price Range
                            Text(business.priceRange.rawValue)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        // Location
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.white.opacity(0.8))
                            Text(business.location)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Color.clear, userProfile.college?.primaryColor.opacity(0.9) ?? Color.red.opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .clipped()
    }
    
    // MARK: - Tab Selector
    private var tabSelectorView: some View {
        HStack(spacing: 0) {
            ForEach(DetailTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 8) {
                        Text(tab.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedTab == tab ? userProfile.college?.primaryColor ?? .red : .secondary)
                        
                        Rectangle()
                            .fill(selectedTab == tab ? userProfile.college?.primaryColor ?? .red : Color.clear)
                            .frame(height: 3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
            }
        }
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Tab Content
    @ViewBuilder
    private var tabContentView: some View {
        switch selectedTab {
        case .overview:
            overviewTabView
        case .services:
            servicesTabView
        case .reviews:
            reviewsTabView
        case .contact:
            contactTabView
        }
    }
    
    // MARK: - Overview Tab
    private var overviewTabView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Business Description
            BusinessInfoCard(title: "About") {
                Text(business.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(4)
            }
            
            // Quick Services Preview
            BusinessInfoCard(title: "Popular Services") {
                VStack(spacing: 12) {
                    ForEach(Array(business.services.prefix(3))) { service in
                        ServicePreviewRow(service: service, userProfile: userProfile) {
                            selectedService = service
                            showingBookingFlow = true
                        }
                    }
                    
                    if business.services.count > 3 {
                        Button("View All Services") {
                            selectedTab = .services
                        }
                        .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        .fontWeight(.semibold)
                    }
                }
            }
            
            // Business Hours
            BusinessInfoCard(title: "Hours") {
                VStack(alignment: .leading, spacing: 8) {
                    HourRow(day: "Monday", schedule: business.availability.monday)
                    HourRow(day: "Tuesday", schedule: business.availability.tuesday)
                    HourRow(day: "Wednesday", schedule: business.availability.wednesday)
                    HourRow(day: "Thursday", schedule: business.availability.thursday)
                    HourRow(day: "Friday", schedule: business.availability.friday)
                    HourRow(day: "Saturday", schedule: business.availability.saturday)
                    HourRow(day: "Sunday", schedule: business.availability.sunday)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Services Tab
    private var servicesTabView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Services")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            
            LazyVStack(spacing: 16) {
                ForEach(business.services) { service in
                    ServiceCard(service: service, userProfile: userProfile) {
                        selectedService = service
                        showingBookingFlow = true
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // MARK: - Reviews Tab
    private var reviewsTabView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Reviews Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reviews")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(business.rating) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.subheadline)
                            }
                        }
                        Text("\(business.rating, specifier: "%.1f") out of 5")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button("Write Review") {
                    // TODO: Add review functionality
                }
                .buttonStyle(ServUSecondaryButtonStyle())
                .font(.subheadline)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Sample Reviews
            VStack(spacing: 16) {
                ForEach(sampleReviews, id: \.id) { review in
                    ReviewCard(review: review)
                        .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // MARK: - Contact Tab
    private var contactTabView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Contact Information")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            
            VStack(spacing: 16) {
                ContactInfoRow(
                    icon: "envelope.fill",
                    title: "Email",
                    value: business.contactInfo.email,
                    action: "mailto:\(business.contactInfo.email)"
                )
                
                ContactInfoRow(
                    icon: "phone.fill",
                    title: "Phone", 
                    value: business.contactInfo.phone,
                    action: "tel:\(business.contactInfo.phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())"
                )
                
                if let instagram = business.contactInfo.instagram {
                    ContactInfoRow(
                        icon: "camera.fill",
                        title: "Instagram",
                        value: instagram,
                        action: "https://instagram.com/\(instagram.replacingOccurrences(of: "@", with: ""))"
                    )
                }
                
                if let website = business.contactInfo.website {
                    ContactInfoRow(
                        icon: "globe",
                        title: "Website",
                        value: website,
                        action: "https://\(website)"
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Computed Properties
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemBackground),
                userProfile.college?.colorScheme.background ?? Color(.systemGray6)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var sampleReviews: [BusinessReview] {
        [
            BusinessReview(
                id: UUID(),
                userName: "Sarah M.",
                rating: 5,
                comment: "Amazing service! \(business.name) exceeded my expectations. Highly recommend!",
                date: Date().addingTimeInterval(-86400 * 3)
            ),
            BusinessReview(
                id: UUID(),
                userName: "Marcus J.",
                rating: 4,
                comment: "Great quality work and very professional. Will definitely book again.",
                date: Date().addingTimeInterval(-86400 * 7)
            ),
            BusinessReview(
                id: UUID(),
                userName: "Ashley K.",
                rating: 5,
                comment: "Perfect! Exactly what I was looking for. The attention to detail was incredible.",
                date: Date().addingTimeInterval(-86400 * 14)
            )
        ]
    }
}

// MARK: - Detail Tabs
enum DetailTab: CaseIterable {
    case overview, services, reviews, contact
    
    var title: String {
        switch self {
        case .overview: return "Overview"
        case .services: return "Services"
        case .reviews: return "Reviews"
        case .contact: return "Contact"
        }
    }
}

// MARK: - Supporting Components

struct ServicePreviewRow: View {
    let service: Service
    @ObservedObject var userProfile: UserProfile
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(service.duration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(String(format: "$%.0f", service.price))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
}

struct ServiceCard: View {
    let service: Service
    @ObservedObject var userProfile: UserProfile
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(service.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(service.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 16) {
                        Label(service.duration, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "$%.0f", service.price))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                    }
                }
                
                Spacer()
            }
            
            Button(action: action) {
                Text("Book Now")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(userProfile.college?.primaryColor ?? .blue)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct HourRow: View {
    let day: String
    let schedule: DaySchedule
    
    var body: some View {
        HStack {
            Text(day)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)
            
            Text(schedule.isOpen ? "\(schedule.openTime) - \(schedule.closeTime)" : "Closed")
                .font(.subheadline)
                .foregroundColor(schedule.isOpen ? .primary : .secondary)
            
            Spacer()
        }
    }
}

struct ReviewCard: View {
    let review: BusinessReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(review.userName.prefix(1)))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.userName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < review.rating ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
                
                Text(review.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(review.comment)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct ContactInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let action: String
    
    var body: some View {
        Button(action: {
            if let url = URL(string: action) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.blue)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(value)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Business Review Model
struct BusinessReview: Identifiable {
    let id: UUID
    let userName: String
    let rating: Int
    let comment: String
    let date: Date
}

// MARK: - Business Info Card Component
struct BusinessInfoCard<Content: View>: View {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    BusinessDetailView(
        business: Business(
            name: "Sample Business",
            category: .photoVideo,
            description: "Sample description",
            rating: 4.8,
            priceRange: .moderate,
            location: "Sample Location",
            contactInfo: ContactInfo(email: "test@test.com", phone: "555-0123"),
            availability: BusinessHours.defaultHours
        ),
        userProfile: UserProfile()
    )
}