//
//  ProfileView.swift
//  ServU
//
//  Created by Amber Still on 7/31/25.
//


//
//  ProfileView.swift
//  ServU
//
//  Created by Quian Bowden on 7/29/25.
//  Updated by Assistant on 7/31/25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var userProfile: UserProfile
    @ObservedObject var msalManager: MSALManager
    @StateObject private var bookingManager = BookingManager()
    
    @State private var isEditingProfile = false
    @State private var showingImagePicker = false
    @State private var selectedSection: ProfileSection = .overview
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background with college colors
                backgroundGradient
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Header
                        profileHeaderView
                        
                        // Section Selector
                        sectionSelectorView
                        
                        // Content based on selected section
                        selectedSectionContent
                        
                        Spacer(minLength: 100) // Space for tab bar
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        isEditingProfile = true
                    }
                    .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                }
            }
            .sheet(isPresented: $isEditingProfile) {
                EditProfileView(userProfile: userProfile)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(imageData: $userProfile.profileImageData)
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeaderView: some View {
        VStack(spacing: 16) {
            // Profile Image
            Button(action: { showingImagePicker = true }) {
                Group {
                    if let image = userProfile.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(userProfile.college?.primaryColor ?? .blue, lineWidth: 3)
                )
                .overlay(
                    // Edit icon
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(userProfile.college?.primaryColor ?? .blue)
                        .clipShape(Circle())
                        .offset(x: 40, y: 40)
                )
            }
            
            // Name and Basic Info
            VStack(spacing: 8) {
                Text(userProfile.fullName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if let college = userProfile.college {
                    Text(college.name)
                        .font(.subheadline)
                        .foregroundColor(college.primaryColor)
                        .fontWeight(.medium)
                }
                
                HStack(spacing: 16) {
                    Label(userProfile.classificationLevel.displayName, systemImage: "graduationcap.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !userProfile.major.isEmpty {
                        Label(userProfile.major, systemImage: "book.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Bio
            if !userProfile.bio.isEmpty {
                Text(userProfile.bio)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .servUCardShadow()
    }
    
    // MARK: - Section Selector
    private var sectionSelectorView: some View {
        HStack(spacing: 0) {
            ForEach(ProfileSection.allCases, id: \.self) { section in
                Button(action: { selectedSection = section }) {
                    VStack(spacing: 4) {
                        Image(systemName: section.icon)
                            .font(.system(size: 18))
                        
                        Text(section.title)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedSection == section ? 
                        userProfile.college?.primaryColor ?? .blue : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .servUCardShadow()
    }
    
    // MARK: - Section Content
    @ViewBuilder
    private var selectedSectionContent: some View {
        switch selectedSection {
        case .overview:
            overviewSectionView
        case .wallet:
            walletSectionView
        case .calendar:
            calendarSectionView
        case .business:
            businessSectionView
        }
    }
    
    // MARK: - Overview Section
    private var overviewSectionView: some View {
        VStack(spacing: 16) {
            // Contact Information
            ProfileInfoCard(title: "Contact Information", userProfile: userProfile) {
                VStack(alignment: .leading, spacing: 12) {
                    ProfileInfoRow(label: "Email", value: userProfile.email, icon: "envelope.fill")
                    ProfileInfoRow(label: "Phone", value: userProfile.phoneNumber.isEmpty ? "Not provided" : userProfile.phoneNumber, icon: "phone.fill")
                }
            }
            
            // Academic Information
            ProfileInfoCard(title: "Academic Information", userProfile: userProfile) {
                VStack(alignment: .leading, spacing: 12) {
                    ProfileInfoRow(label: "Classification", value: userProfile.classificationLevel.displayName, icon: "graduationcap.fill")
                    ProfileInfoRow(label: "Major", value: userProfile.major.isEmpty ? "Not specified" : userProfile.major, icon: "book.fill")
                    if let jobTitle = userProfile.jobTitle, !jobTitle.isEmpty {
                        ProfileInfoRow(label: "Position", value: jobTitle, icon: "briefcase.fill")
                    }
                }
            }
            
            // Sign Out Button
            Button(action: { msalManager.signOut() }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .servUCardShadow()
            }
        }
    }
    
    // MARK: - Wallet Section
    private var walletSectionView: some View {
        VStack(spacing: 16) {
            ProfileInfoCard(title: "ServU Wallet", userProfile: userProfile) {
                VStack(spacing: 20) {
                    // Balance Display
                    VStack(spacing: 8) {
                        Text("Current Balance")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "$%.2f", userProfile.walletBalance))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                    }
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        Button("Add Funds") {
                            // TODO: Implement add funds
                        }
                        .buttonStyle(ServUPrimaryButtonStyle(backgroundColor: userProfile.college?.primaryColor ?? .blue))
                        
                        Button("Withdraw") {
                            // TODO: Implement withdraw
                        }
                        .buttonStyle(ServUSecondaryButtonStyle(borderColor: userProfile.college?.primaryColor ?? .blue))
                    }
                }
            }
            
            // Recent Transactions (placeholder)
            ProfileInfoCard(title: "Recent Transactions", userProfile: userProfile) {
                VStack {
                    Image(systemName: "creditcard")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("No transactions yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
            }
        }
    }
    
    // MARK: - Calendar Section
    private var calendarSectionView: some View {
        VStack(spacing: 16) {
            let upcomingBookings = bookingManager.getUpcomingBookings()
            
            if upcomingBookings.isEmpty {
                ProfileInfoCard(title: "Upcoming Appointments", userProfile: userProfile) {
                    VStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No upcoming appointments")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                }
            } else {
                ProfileInfoCard(title: "Upcoming Appointments", userProfile: userProfile) {
                    VStack(spacing: 12) {
                        ForEach(upcomingBookings.prefix(3), id: \.id) { booking in
                            BookingRowView(booking: booking, userProfile: userProfile)
                        }
                        
                        if upcomingBookings.count > 3 {
                            Button("View All Appointments") {
                                // TODO: Navigate to full appointments view
                            }
                            .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                            .fontWeight(.semibold)
                        }
                    }
                }
            }
            
            ProfileInfoCard(title: "Quick Actions", userProfile: userProfile) {
                VStack(spacing: 12) {
                    Button("Book a Service") {
                        // TODO: Navigate to services
                    }
                    .buttonStyle(ServUPrimaryButtonStyle(backgroundColor: userProfile.college?.primaryColor ?? .blue))
                    
                    Button("View All Bookings") {
                        // TODO: Show all bookings
                    }
                    .buttonStyle(ServUSecondaryButtonStyle(borderColor: userProfile.college?.primaryColor ?? .blue))
                }
            }
        }
    }
    
    // MARK: - Business Section
    private var businessSectionView: some View {
        VStack(spacing: 16) {
            if userProfile.isBusinessOwner && !userProfile.businesses.isEmpty {
                // Show existing businesses
                ForEach(userProfile.businesses) { business in
                    BusinessCard(business: business, userProfile: userProfile)
                }
            } else {
                // Show business registration option
                ProfileInfoCard(title: "Start Your Business", userProfile: userProfile) {
                    VStack(spacing: 16) {
                        Image(systemName: "storefront")
                            .font(.system(size: 40))
                            .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        
                        Text("Ready to start earning?")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Register your business and start offering services to students at \(userProfile.college?.name ?? "your college")!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Register Business") {
                            // TODO: Navigate to business registration
                        }
                        .buttonStyle(ServUPrimaryButtonStyle(backgroundColor: userProfile.college?.primaryColor ?? .blue))
                    }
                    .padding(.vertical, 20)
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
}

// MARK: - Profile Sections
enum ProfileSection: CaseIterable {
    case overview, wallet, calendar, business
    
    var title: String {
        switch self {
        case .overview: return "Overview"
        case .wallet: return "Wallet"
        case .calendar: return "Calendar"
        case .business: return "Business"
        }
    }
    
    var icon: String {
        switch self {
        case .overview: return "person.circle.fill"
        case .wallet: return "creditcard.fill"
        case .calendar: return "calendar"
        case .business: return "storefront.fill"
        }
    }
}

// MARK: - Supporting Views
struct ProfileInfoCard<Content: View>: View {
    let title: String
    @ObservedObject var userProfile: UserProfile
    let content: Content
    
    init(title: String, userProfile: UserProfile, @ViewBuilder content: () -> Content) {
        self.title = title
        self.userProfile = userProfile
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(userProfile.college?.primaryColor ?? .blue)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .servUCardShadow()
    }
}

struct ProfileInfoRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

struct BusinessCard: View {
    let business: Business
    @ObservedObject var userProfile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(business.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                
                Spacer()
                
                Text(business.isActive ? "Active" : "Inactive")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(business.isActive ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .foregroundColor(business.isActive ? .green : .gray)
                    .cornerRadius(8)
            }
            
            Text(business.category.rawValue)
                .font(.subheadline)
                .foregroundColor(userProfile.college?.primaryColor ?? .blue)
            
            Text(business.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", business.rating))
                        .font(.subheadline)
                }
                
                Spacer()
                
                Text(business.priceRange.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .servUCardShadow()
    }
}

struct BookingRowView: View {
    let booking: Booking
    @ObservedObject var userProfile: UserProfile
    
    var body: some View {
        HStack(spacing: 12) {
            // Business Category Icon
            Circle()
                .fill(userProfile.college?.primaryColor ?? .blue)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: booking.business.category.icon)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                )
            
            // Booking Info
            VStack(alignment: .leading, spacing: 4) {
                Text(booking.service.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(booking.business.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Label(booking.displayDate, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(booking.displayTime, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Status Badge
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: booking.status.icon)
                        .font(.caption2)
                        .foregroundColor(booking.status.color)
                    
                    Text(booking.status.rawValue)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(booking.status.color)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(booking.status.color.opacity(0.1))
                .cornerRadius(6)
                
                // Payment Status
                if booking.service.requiresDeposit {
                    HStack(spacing: 2) {
                        Image(systemName: booking.paymentStatus.icon)
                            .font(.caption2)
                            .foregroundColor(booking.paymentStatus.color)
                        
                        Text(booking.paymentStatus.rawValue)
                            .font(.caption2)
                            .foregroundColor(booking.paymentStatus.color)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ProfileView(userProfile: UserProfile(), msalManager: MSALManager())
}