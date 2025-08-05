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
//  Created by Quian Bowden on 8/4/25.
//  Main app entry point with Stripe integration
//

import SwiftUI
import Stripe

@main
struct ServUApp: App {
    
    init() {
        configureStripe()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    // MARK: - Stripe Configuration
    private func configureStripe() {
        #if DEBUG
        // Development - use test keys
        if let publishableKey = StripeConfig.developmentPublishableKey {
            StripeAPI.defaultPublishableKey = publishableKey
            print("✅ Stripe configured for DEVELOPMENT")
        } else {
            print("⚠️ Missing Stripe development keys - Check StripeConfig.swift")
        }
        #else
        // Production - use live keys
        if let publishableKey = StripeConfig.productionPublishableKey {
            StripeAPI.defaultPublishableKey = publishableKey
            print("✅ Stripe configured for PRODUCTION")
        } else {
            print("❌ Missing Stripe production keys - Check StripeConfig.swift")
        }
        #endif
    }
}

// MARK: - Content View (Main App Entry Point)
struct ContentView: View {
    @StateObject private var userProfile = UserProfile()
    @StateObject private var bookingManager = BookingManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("ServU")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.servURed)
                
                Text("Your Campus Service Marketplace")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                #if DEBUG
                NavigationLink("Payment Test") {
                    PaymentTestView()
                        .environmentObject(userProfile)
                        .environmentObject(bookingManager)
                }
                .foregroundColor(.servURed)
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
                .foregroundColor(.servURed)
                
                NavigationLink("Test Full Payment") {
                    PaymentIntegrationView(for: sampleBooking, type: .full)
                }
                .foregroundColor(.servURed)
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

// MARK: - ServU Brand Colors
extension Color {
    static let servURed = Color(red: 0.8, green: 0.2, blue: 0.2)
    static let servUSecondary = Color(red: 0.2, green: 0.4, blue: 0.8)
}