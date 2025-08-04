//
//  ServUApp.swift
//  ServU
//
//  Created by Amber Still on 8/4/25.
//


//
//  ServUApp.swift
//  ServU
//
//  Created by Quian Bowden on 8/3/25.
//  Main app initialization with Stripe configuration
//

import SwiftUI
import UIKit

@main
struct ServUApp: App {
    
    init() {
        // Initialize Stripe configuration on app startup
        configureStripe()
        
        // Additional app setup
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Validate Stripe configuration on first launch
                    validateStripeSetup()
                }
        }
    }
    
    // MARK: - Configuration Methods
    
    private func configureStripe() {
        // Configure Stripe with app settings
        StripeConfig.configure()
        
        print("🏁 ServU App initialized with Stripe integration")
        
        #if DEBUG
        print("🔧 \(StripeConfig.getEnvironmentInfo())")
        #endif
    }
    
    private func configureAppearance() {
        // Configure global UI appearance for ServU
        
        // Navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Tab bar appearance (if using tab bar)
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    private func validateStripeSetup() {
        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let isValid = StripeConfig.validateConfiguration()
            if !isValid {
                print("⚠️ Stripe configuration needs attention. Check StripeConfig.swift")
            } else {
                print("✅ Stripe is ready for payments")
            }
        }
        #endif
    }
}

// MARK: - Content View (Main App View)
struct ContentView: View {
    @StateObject private var userProfile = UserProfile()
    @StateObject private var bookingManager = BookingManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("ServU")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Payment System Ready!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                #if DEBUG
                NavigationLink("Payment Test") {
                    PaymentTestView()
                        .environmentObject(userProfile)
                        .environmentObject(bookingManager)
                }
                .foregroundColor(.blue)
                #endif
                
                Spacer()
            }
            .padding()
            .navigationTitle("ServU")
        }
        .environmentObject(userProfile)
        .environmentObject(bookingManager)
    }
}

// MARK: - Payment Test View (Debug Only)
#if DEBUG
struct PaymentTestView: View {
    @EnvironmentObject var bookingManager: BookingManager
    @EnvironmentObject var userProfile: UserProfile
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Payment Integration Test")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Stripe Configuration")
                .font(.headline)
            
            Text(StripeConfig.getEnvironmentInfo())
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            if let sampleBooking = bookingManager.userBookings.first {
                NavigationLink("Test Deposit Payment") {
                    PaymentIntegrationView(for: sampleBooking, type: .deposit)
                }
                .foregroundColor(.blue)
                
                NavigationLink("Test Full Payment") {
                    PaymentIntegrationView(for: sampleBooking, type: .full)
                }
                .foregroundColor(.blue)
            } else {
                Text("No sample bookings available")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Payment Test")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#endif

// MARK: - Color Extension
extension Color {
    static let servURed = Color(red: 0.8, green: 0.2, blue: 0.2)
}