//
//  ServUApp.swift
//  ServU
//
//  Created by Amber Still on 8/6/25.
//


//
//  ServUApp.swift
//  ServU
//
//  Created by Quian Bowden on 8/4/25.
//  Fixed by Quian Bowden on 8/5/25.
//  Main app entry point with Stripe integration - removed duplicate ContentView
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
            ContentView() // ✅ Use ContentView from ContentView.swift (authentication flow)
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