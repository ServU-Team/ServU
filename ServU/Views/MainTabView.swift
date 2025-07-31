//
//  MainTabView.swift
//  ServU
//
//  Created by Amber Still on 7/31/25.
//


//
//  MainTabView.swift
//  ServU
//
//  Created by Quian Bowden on 7/29/25.
//  Updated by Assistant on 7/31/25.
//  Added shared cart manager for product functionality
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var msalManager: MSALManager
    @StateObject private var userProfile = UserProfile()
    @StateObject private var graphService: GraphAPIService
    @StateObject private var sharedCartManager = ShoppingCartManager() // ✅ ADDED: Shared cart manager
    
    @State private var selectedTab: AppTab = .home
    @State private var isLoadingProfile = false
    
    // Initialize with MSALManager
    init(msalManager: MSALManager) {
        self.msalManager = msalManager
        self._graphService = StateObject(wrappedValue: GraphAPIService(msalManager: msalManager))
    }
    
    var body: some View {
        ZStack {
            // Dynamic background based on college colors
            backgroundGradient
                .edgesIgnoringSafeArea(.all)
            
            TabView(selection: $selectedTab) {
                // Events Tab (NEW - replaces Search)
                EventsView(userProfile: userProfile)
                    .tabItem {
                        VStack {
                            Image(systemName: selectedTab == .events ? "calendar.badge.plus" : "calendar")
                                .font(.system(size: 20))
                            Text("EVENTS")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                    }
                    .tag(AppTab.events)
                
                // My Serv Tab
                MyServView(userProfile: userProfile)
                    .tabItem {
                        VStack {
                            Image(systemName: selectedTab == .myServ ? "briefcase.fill" : "briefcase")
                                .font(.system(size: 20))
                            Text("MY SERV")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                    }
                    .tag(AppTab.myServ)
                
                // Home Tab (with integrated search)
                EnhancedHomeView(userProfile: userProfile, cartManager: sharedCartManager) // ✅ ADDED: Pass cart manager
                    .tabItem {
                        VStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 24))
                                .foregroundColor(selectedTab == .home ? Color.red : Color.gray)
                            Text("HOME")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(selectedTab == .home ? Color.red : Color.gray)
                        }
                    }
                    .tag(AppTab.home)
                
                // Cart Tab
                CartView(userProfile: userProfile, cartManager: sharedCartManager) // ✅ ADDED: Pass cart manager
                    .tabItem {
                        VStack {
                            ZStack {
                                Image(systemName: selectedTab == .cart ? "cart.fill" : "cart")
                                    .font(.system(size: 20))
                                
                                // Cart badge
                                if sharedCartManager.itemCount > 0 {
                                    Text("\(sharedCartManager.itemCount)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 8, y: -8)
                                }
                            }
                            Text("CART")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                    }
                    .tag(AppTab.cart)
                
                // Profile Tab
                ProfileView(userProfile: userProfile, msalManager: msalManager)
                    .tabItem {
                        VStack {
                            Image(systemName: selectedTab == .profile ? "person.fill" : "person")
                                .font(.system(size: 20))
                            Text("PROFILE")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                    }
                    .tag(AppTab.profile)
            }
            .accentColor(selectedTab == .home ? Color.red : (userProfile.college?.primaryColor ?? .blue))
            
            // Loading overlay
            if isLoadingProfile {
                ServULoadingView(message: "Loading your profile...")
            }
        }
        .onAppear {
            loadUserProfile()
        }
    }
    
    // MARK: - Computed Properties
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                userProfile.college?.colorScheme.background ?? Color.white,
                Color.white
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Methods
    private func loadUserProfile() {
        isLoadingProfile = true
        
        Task {
            do {
                let profile = try await graphService.fetchUserProfile()
                
                await MainActor.run {
                    // Update the user profile
                    userProfile.id = profile.id
                    userProfile.displayName = profile.displayName
                    userProfile.firstName = profile.firstName
                    userProfile.lastName = profile.lastName
                    userProfile.email = profile.email
                    userProfile.jobTitle = profile.jobTitle
                    userProfile.profileImageData = profile.profileImageData
                    userProfile.college = profile.college
                    
                    isLoadingProfile = false
                    
                    print("✅ DEBUG: Profile loaded successfully for \(userProfile.displayName)")
                }
            } catch {
                await MainActor.run {
                    isLoadingProfile = false
                    print("❌ DEBUG: Failed to load profile: \(error)")
                    // TODO: Show error alert to user
                }
            }
        }
    }
}

// MARK: - Updated Tab Enum
enum AppTab: CaseIterable {
    case events, myServ, home, cart, profile
    
    var title: String {
        switch self {
        case .events: return "Events"
        case .myServ: return "My Serv"
        case .home: return "Home"
        case .cart: return "Cart"
        case .profile: return "Profile"
        }
    }
}

// MARK: - New Events View
struct EventsView: View {
    @ObservedObject var userProfile: UserProfile
    @StateObject private var eventsManager = EventsManager()
    @State private var showingCreateEvent = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Events Header
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Campus Events")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                            
                            Text("Discover and host events at \(userProfile.college?.name ?? "your college")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { showingCreateEvent = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                if eventsManager.events.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No Events Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Be the first to create an event for your college community!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button("Create Event") {
                            showingCreateEvent = true
                        }
                        .buttonStyle(ServUPrimaryButtonStyle(backgroundColor: userProfile.college?.primaryColor ?? .blue))
                        .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(eventsManager.events) { event in
                                EventCard(event: event, userProfile: userProfile)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCreateEvent) {
                CreateEventView(userProfile: userProfile, eventsManager: eventsManager)
            }
        }
    }
}

// MARK: - MyServView (Updated colors)
struct MyServView: View {
    @ObservedObject var userProfile: UserProfile
    @State private var showingBusinessRegistration = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("My Services")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                    .padding(.top, 20)
                
                if userProfile.isBusinessOwner && !userProfile.businesses.isEmpty {
                    // Show user's businesses with dashboard
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(userProfile.businesses) { business in
                                BusinessDashboardCard(business: business, userProfile: userProfile)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "storefront.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Start Your Business")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Register your services and start earning money by helping other students!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button("Register Business") {
                            showingBusinessRegistration = true
                        }
                        .buttonStyle(ServUPrimaryButtonStyle(backgroundColor: userProfile.college?.primaryColor ?? .blue))
                        .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingBusinessRegistration) {
                BusinessRegistrationView(userProfile: userProfile)
            }
        }
    }
}

// MARK: - Updated CartView
struct CartView: View {
    @ObservedObject var userProfile: UserProfile
    @ObservedObject var cartManager: ShoppingCartManager // ✅ ADDED: Accept cart manager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Shopping Cart")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                    .padding(.top, 20)
                
                if cartManager.items.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cart.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Your cart is empty")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Add services to your cart to book appointments or make purchases!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    // Show cart items
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(cartManager.items) { item in
                                CartItemRow(item: item, cartManager: cartManager, userProfile: userProfile)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Cart summary
                    VStack(spacing: 16) {
                        HStack {
                            Text("Subtotal:")
                                .font(.headline)
                            Spacer()
                            Text(cartManager.formattedSubtotal)
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        
                        if cartManager.shippingCost > 0 {
                            HStack {
                                Text("Shipping:")
                                    .font(.subheadline)
                                Spacer()
                                Text(cartManager.formattedShippingCost)
                                    .font(.subheadline)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total:")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Text(cartManager.formattedTotal)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        }
                        
                        Button("Proceed to Checkout") {
                            // TODO: Implement checkout
                        }
                        .buttonStyle(ServUPrimaryButtonStyle(backgroundColor: userProfile.college?.primaryColor ?? .blue))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Cart Item Row
struct CartItemRow: View {
    let item: CartItem
    @ObservedObject var cartManager: ShoppingCartManager
    @ObservedObject var userProfile: UserProfile
    
    var body: some View {
        HStack(spacing: 12) {
            // Product image placeholder
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                .overlay(
                    Image(systemName: item.product.category.icon)
                        .font(.title3)
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(String(format: "$%.2f each", item.unitPrice))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                HStack(spacing: 8) {
                    Button(action: {
                        cartManager.updateQuantity(for: item, quantity: item.quantity - 1)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .disabled(item.quantity <= 1)
                    
                    Text("\(item.quantity)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(minWidth: 20)
                    
                    Button(action: {
                        cartManager.updateQuantity(for: item, quantity: item.quantity + 1)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                    }
                }
                
                Text(String(format: "$%.2f", item.totalPrice))
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .servUCardShadow()
    }
}

// MARK: - Supporting Views
struct BusinessDashboardCard: View {
    let business: Business
    @ObservedObject var userProfile: UserProfile
    @State private var showingManageServices = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(business.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(business.category.displayName)
                        .font(.subheadline)
                        .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", business.rating))
                                .font(.subheadline)
                        }
                        
                        Text(business.isActive ? "Active" : "Inactive")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(business.isActive ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                            .foregroundColor(business.isActive ? .green : .gray)
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                Button("Manage") {
                    showingManageServices = true
                }
                .buttonStyle(ServUSecondaryButtonStyle(borderColor: userProfile.college?.primaryColor ?? .blue))
                .font(.subheadline)
            }
            
            // Quick Stats
            HStack(spacing: 20) {
                VStack {
                    Text("\(business.services.count)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                    Text("Services")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("$\(Int.random(in: 200...1000))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("This Month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(Int.random(in: 5...25))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Bookings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .servUCardShadow()
        .sheet(isPresented: $showingManageServices) {
            ManageServicesView(business: business, userProfile: userProfile)
        }
    }
}

#Preview {
    MainTabView(msalManager: MSALManager())
}