//
//  EnhancedHomeView.swift
//  ServU
//
//  Created by Amber Still on 7/31/25.
//


//
//  EnhancedHomeView.swift
//  ServU
//
//  Created by Quian Bowden on 7/29/25.
//  Updated by Assistant on 7/31/25.
//  Fixed corner radius implementation and UIKit compatibility
//

import SwiftUI
import UIKit

struct EnhancedHomeView: View {
    @ObservedObject var userProfile: UserProfile
    @ObservedObject var cartManager: ShoppingCartManager
    @StateObject private var businessData = EnhancedBusinessDataService()
    
    @State private var selectedCategory: ServiceCategory? = nil
    @State private var currentPopularIndex = 0
    @State private var autoScrollTimer: Timer?
    @State private var showingSearch = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // ServU Header with Logo and Search
                    headerView
                    
                    // Service Category Tabs
                    categoryTabsView
                    
                    // Popular Services (Auto-scrolling)
                    popularServicesView
                    
                    // Services For U Section
                    servicesForYouView
                    
                    Spacer(minLength: 100) // Space for tab bar
                }
            }
            .navigationBarHidden(true)
            .background(backgroundGradient)
            .sheet(isPresented: $showingSearch) {
                SearchView(userProfile: userProfile, cartManager: cartManager)
            }
        }
        .onAppear {
            startAutoScroll()
        }
        .onDisappear {
            stopAutoScroll()
        }
    }
    
    // MARK: - Header View (Updated with Search)
    private var headerView: some View {
        VStack(spacing: 16) {
            // Top bar with search and ServU logo
            HStack {
                // Search button in top left
                Button(action: { showingSearch = true }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(userProfile.college?.primaryColor ?? .red)
                        .frame(width: 40, height: 40)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                
                Spacer()
                
                // ServU Logo (centered)
                HStack {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0)) // Gold
                    
                    Text("Serv")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0)) // Gold
                    + Text("U")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(userProfile.college?.primaryColor ?? Color.red)
                }
                
                Spacer()
                
                // Cart icon in top right
                Button(action: { showingSearch = true }) {
                    ZStack {
                        Image(systemName: "bag")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(userProfile.college?.primaryColor ?? .red)
                            .frame(width: 40, height: 40)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        // Cart badge
                        if cartManager.itemCount > 0 {
                            Text("\(cartManager.itemCount)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 18, height: 18)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 12, y: -12)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Welcome message with college info
            if let college = userProfile.college {
                VStack(spacing: 4) {
                    Text("Welcome to \(college.name)")
                        .font(.headline)
                        .foregroundColor(college.primaryColor)
                        .fontWeight(.semibold)
                    
                    Text("Discover services & products by students, for students")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Category Tabs
    private var categoryTabsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All categories tab
                CategoryTab(
                    category: nil,
                    selectedCategory: selectedCategory,
                    action: { selectedCategory = nil }
                )
                
                // Individual category tabs
                ForEach(ServiceCategory.allCases, id: \.self) { category in
                    CategoryTab(
                        category: category,
                        selectedCategory: selectedCategory,
                        action: { selectedCategory = selectedCategory == category ? nil : category }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Popular Services (Auto-scrolling)
    private var popularServicesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("POPULAR SERVICES & PRODUCTS")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(userProfile.college?.primaryColor ?? Color.red)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Auto-scrolling business cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(filteredPopularBusinesses) { business in
                        PopularBusinessCard(business: business, userProfile: userProfile, cartManager: cartManager)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Services For You
    private var servicesForYouView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("FEATURED FOR U")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0)) // Gold
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Featured service cards
            VStack(spacing: 16) {
                ForEach(filteredFeaturedBusinesses) { business in
                    FeaturedBusinessCard(business: business, userProfile: userProfile, cartManager: cartManager)
                        .padding(.horizontal, 20)
                }
            }
        }
        .padding(.bottom, 32)
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
    
    private var filteredPopularBusinesses: [EnhancedBusiness] {
        let businesses = selectedCategory == nil ? 
            businessData.popularBusinesses : 
            businessData.popularBusinesses.filter { 
                $0.serviceCategories.contains(selectedCategory!) ||
                ($0.businessType == .products && selectedCategory == .other)
            }
        return Array(businesses.prefix(7))
    }
    
    private var filteredFeaturedBusinesses: [EnhancedBusiness] {
        let businesses = selectedCategory == nil ? 
            businessData.featuredBusinesses : 
            businessData.featuredBusinesses.filter { 
                $0.serviceCategories.contains(selectedCategory!) ||
                ($0.businessType == .products && selectedCategory == .other)
            }
        return Array(businesses.prefix(3))
    }
    
    // MARK: - Auto-scroll Methods
    private func startAutoScroll() {
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPopularIndex = (currentPopularIndex + 1) % max(1, filteredPopularBusinesses.count)
            }
        }
    }
    
    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
}

// MARK: - Updated Search View (Full Screen Modal)
struct SearchView: View {
    @ObservedObject var userProfile: UserProfile
    @ObservedObject var cartManager: ShoppingCartManager
    @StateObject private var businessData = EnhancedBusinessDataService()
    @State private var searchText = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Search Header
                VStack(spacing: 16) {
                    HStack {
                        Text("Find Services & Products")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        
                        Spacer()
                    }
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search for services, products, or businesses...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Search Results
                if searchText.isEmpty {
                    VStack {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Search for services & products")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Find photographers, stylists, tutors, clothing, and more!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    List(businessData.searchBusinesses(query: searchText)) { business in
                        BusinessSearchRow(business: business, userProfile: userProfile, cartManager: cartManager)
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                }
            }
        }
    }
}

struct BusinessSearchRow: View {
    let business: EnhancedBusiness
    @ObservedObject var userProfile: UserProfile
    @ObservedObject var cartManager: ShoppingCartManager
    @State private var showingBusinessDetail = false
    @State private var showingProductList = false
    
    var body: some View {
        Button(action: navigateToBusiness) {
            HStack(spacing: 16) {
                // Business icon
                Circle()
                    .fill(userProfile.college?.primaryColor ?? .blue)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(business.name.prefix(2)))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                // Business info
                VStack(alignment: .leading, spacing: 4) {
                    Text(business.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(business.displayCategories)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        
                        Text(String(format: "%.1f", business.rating))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(business.priceRange.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(business.businessType.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(userProfile.college?.primaryColor.opacity(0.1) ?? Color.blue.opacity(0.1))
                            .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                            .cornerRadius(4)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .sheet(isPresented: $showingBusinessDetail) {
            if business.businessType == .services || business.businessType == .both {
                BusinessDetailView(business: convertToOldBusiness(business), userProfile: userProfile)
            }
        }
        .sheet(isPresented: $showingProductList) {
            ProductListView(business: business, userProfile: userProfile, cartManager: cartManager)
        }
    }
    
    private func navigateToBusiness() {
        switch business.businessType {
        case .services:
            showingBusinessDetail = true
        case .products:
            showingProductList = true
        case .both:
            showingProductList = true
        }
    }
    
    private func convertToOldBusiness(_ enhanced: EnhancedBusiness) -> Business {
        return enhanced.toBusiness()
    }
}

// MARK: - Category Tab Component
struct CategoryTab: View {
    let category: ServiceCategory?
    let selectedCategory: ServiceCategory?
    let action: () -> Void
    
    private var isSelected: Bool {
        if category == nil && selectedCategory == nil {
            return true
        }
        return category == selectedCategory
    }
    
    private var displayText: String {
        category?.rawValue ?? "ALL"
    }
    
    private var displayIcon: String {
        category?.icon ?? "star.fill"
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: displayIcon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(displayText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? 
                          LinearGradient(colors: [Color.red, Color.red.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                          LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground)], startPoint: .top, endPoint: .bottom))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color.red.opacity(0.3) : Color.black.opacity(0.1), 
                   radius: isSelected ? 8 : 2, x: 0, y: isSelected ? 4 : 1)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
    }
}

// MARK: - Popular Business Card
struct PopularBusinessCard: View {
    let business: EnhancedBusiness
    @ObservedObject var userProfile: UserProfile
    @ObservedObject var cartManager: ShoppingCartManager
    @State private var showingBusinessDetail = false
    @State private var showingProductList = false
    
    var body: some View {
        Button(action: navigateToBusiness) {
            VStack(alignment: .leading, spacing: 12) {
                // Business Image
                Rectangle()
                    .fill(LinearGradient(colors: [userProfile.college?.primaryColor ?? .red, userProfile.college?.secondaryColor ?? .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 120)
                    .cornerRadius(12)
                    .overlay(
                        VStack {
                            Spacer()
                            Text(businessIcon)
                                .font(.system(size: 40))
                        }
                    )
                
                // Business Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(business.name.uppercased())
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(business.displayCategories)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        
                        Text(String(format: "%.1f★ (%d)", business.rating, business.totalSales))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                    }
                }
                
                // Action Button
                Text(actionButtonText)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            .frame(width: 200)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(userProfile.college?.primaryColor ?? Color.red)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .sheet(isPresented: $showingBusinessDetail) {
            if business.businessType == .services || business.businessType == .both {
                BusinessDetailView(business: business.toBusiness(), userProfile: userProfile)
            }
        }
        .sheet(isPresented: $showingProductList) {
            ProductListView(business: business, userProfile: userProfile, cartManager: cartManager)
        }
    }
    
    private var businessIcon: String {
        switch business.businessType {
        case .services:
            if business.serviceCategories.contains(.photoVideo) { return "📸" }
            if business.serviceCategories.contains(.barber) { return "✂️" }
            if business.serviceCategories.contains(.hairStylist) { return "💄" }
            return "🛠️"
        case .products:
            if business.productCategories.contains(.clothing) { return "👕" }
            if business.productCategories.contains(.electronics) { return "📱" }
            return "🛍️"
        case .both:
            return "🏪"
        }
    }
    
    private var actionButtonText: String {
        switch business.businessType {
        case .services:
            return "BOOK NOW"
        case .products:
            return "SHOP NOW"
        case .both:
            return "VIEW STORE"
        }
    }
    
    private func navigateToBusiness() {
        switch business.businessType {
        case .services:
            showingBusinessDetail = true
        case .products:
            showingProductList = true
        case .both:
            showingProductList = true
        }
    }
}

// MARK: - Featured Business Card
struct FeaturedBusinessCard: View {
    let business: EnhancedBusiness
    @ObservedObject var userProfile: UserProfile
    @ObservedObject var cartManager: ShoppingCartManager
    @State private var showingBusinessDetail = false
    @State private var showingProductList = false
    
    var body: some View {
        Button(action: navigateToBusiness) {
            VStack(alignment: .leading, spacing: 0) {
                // Business Image
                Rectangle()
                    .fill(LinearGradient(colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 200)
                    .clipShape(RoundedCorner.topCorners(radius: 16))
                    .overlay(
                        VStack {
                            Spacer()
                            Text(businessIcon)
                                .font(.system(size: 60))
                        }
                    )
                
                // Business Info Overlay
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(business.name.uppercased())
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(business.displayCategories)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(1)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                
                                Text(String(format: "%.1f★ (%d)", business.rating, business.totalSales))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(16)
                .background(Color(red: 1.0, green: 0.84, blue: 0.0))
                .clipShape(RoundedCorner.bottomCorners(radius: 16))
            }
            .background(Color(red: 1.0, green: 0.84, blue: 0.0))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
        }
        .sheet(isPresented: $showingBusinessDetail) {
            if business.businessType == .services || business.businessType == .both {
                BusinessDetailView(business: business.toBusiness(), userProfile: userProfile)
            }
        }
        .sheet(isPresented: $showingProductList) {
            ProductListView(business: business, userProfile: userProfile, cartManager: cartManager)
        }
    }
    
    private var businessIcon: String {
        switch business.businessType {
        case .services:
            if business.serviceCategories.contains(.photoVideo) { return "📸" }
            if business.serviceCategories.contains(.barber) { return "✂️" }
            if business.serviceCategories.contains(.hairStylist) { return "💄" }
            return "🛠️"
        case .products:
            if business.productCategories.contains(.clothing) { return "👕" }
            if business.productCategories.contains(.electronics) { return "📱" }
            return "🛍️"
        case .both:
            return "🏪"
        }
    }
    
    private func navigateToBusiness() {
        switch business.businessType {
        case .services:
            showingBusinessDetail = true
        case .products:
            showingProductList = true
        case .both:
            showingProductList = true
        }
    }
}

#Preview {
    EnhancedHomeView(userProfile: UserProfile(), cartManager: ShoppingCartManager())
}