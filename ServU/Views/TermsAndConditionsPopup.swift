//
//  TermsAndConditionsPopup.swift
//  ServU
//
//  Created by Amber Still on 7/31/25.
//


//
//  TermsAndConditionsPopup.swift
//  ServU
//
//  Created by Quian Bowden on 7/31/25.
//

import SwiftUI

struct TermsAndConditionsPopup: View {
    @ObservedObject var userProfile: UserProfile
    @Binding var isPresented: Bool
    @Binding var hasAccepted: Bool
    
    @State private var hasReadTerms = false
    @State private var acceptedBusinessTerms = false
    @State private var acceptedStripeTerms = false
    @State private var acceptedFeeStructure = false
    @State private var acceptedDataPolicy = false
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    // Prevent dismissing by tapping outside
                }
            
            // Popup content
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .font(.title2)
                            .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        
                        Text("Business Terms & Policies")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                        
                        Spacer()
                    }
                    
                    Text("Please review and accept the following terms to register your business on ServU")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // Scrollable content
                ScrollView {
                    VStack(spacing: 20) {
                        // Platform Fees Section
                        TermsSection(
                            title: "Platform Fees & Revenue",
                            icon: "dollarsign.circle.fill",
                            color: .green,
                            userProfile: userProfile
                        ) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Fee Structure:")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 6, height: 6)
                                        Text("Platform Fee: \(PlatformFeeConfig.serviceFeePercentage, specifier: "%.1f")% per transaction")
                                            .font(.subheadline)
                                    }
                                    
                                    HStack {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 6, height: 6)
                                        Text("Payment Processing: \(PlatformFeeConfig.stripeFeePercentage, specifier: "%.1f")% + $\(PlatformFeeConfig.stripeFeeFixed, specifier: "%.2f") per transaction")
                                            .font(.subheadline)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Example Calculation:")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    let exampleAmount = 100.0
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Service Price: $\(exampleAmount, specifier: "%.2f")")
                                        Text("Platform Fee: -$\(PlatformFeeConfig.calculatePlatformFee(for: exampleAmount), specifier: "%.2f")")
                                            .foregroundColor(.red)
                                        Text("Processing Fee: -$\(PlatformFeeConfig.calculateStripeFee(for: exampleAmount), specifier: "%.2f")")
                                            .foregroundColor(.red)
                                        Divider()
                                        Text("You Receive: $\(PlatformFeeConfig.calculateBusinessPayout(for: exampleAmount), specifier: "%.2f")")
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                    }
                                    .font(.caption)
                                }
                                .padding()
                                .background(Color(.systemGray6).opacity(0.5))
                                .cornerRadius(8)
                                
                                Toggle("I understand and accept the fee structure", isOn: $acceptedFeeStructure)
                                    .toggleStyle(CheckboxToggleStyle(userProfile: userProfile))
                            }
                        }
                        
                        // Stripe Terms Section
                        TermsSection(
                            title: "Payment Processing",
                            icon: "creditcard.fill",
                            color: .purple,
                            userProfile: userProfile
                        ) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("ServU uses Stripe for secure payment processing. By registering, you agree to:")
                                    .font(.subheadline)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .top) {
                                        Circle()
                                            .fill(Color.purple)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 6)
                                        Text("Stripe's Terms of Service and compliance requirements")
                                            .font(.subheadline)
                                    }
                                    
                                    HStack(alignment: .top) {
                                        Circle()
                                            .fill(Color.purple)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 6)
                                        Text("Verification of your identity and business information")
                                            .font(.subheadline)
                                    }
                                    
                                    HStack(alignment: .top) {
                                        Circle()
                                            .fill(Color.purple)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 6)
                                        Text("Payment processing times of 1-2 business days")
                                            .font(.subheadline)
                                    }
                                }
                                
                                Button(action: {
                                    // Open Stripe terms in browser
                                    if let url = URL(string: "https://stripe.com/legal") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Text("Read Stripe Terms of Service")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .underline()
                                }
                                
                                Toggle("I accept Stripe's payment processing terms", isOn: $acceptedStripeTerms)
                                    .toggleStyle(CheckboxToggleStyle(userProfile: userProfile))
                            }
                        }
                        
                        // Business Policies Section
                        TermsSection(
                            title: "Business Policies",
                            icon: "building.2.fill",
                            color: .orange,
                            userProfile: userProfile
                        ) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("As a ServU business owner, you agree to:")
                                    .font(.subheadline)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .top) {
                                        Circle()
                                            .fill(Color.orange)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 6)
                                        Text("Provide accurate service/product descriptions and pricing")
                                            .font(.subheadline)
                                    }
                                    
                                    HStack(alignment: .top) {
                                        Circle()
                                            .fill(Color.orange)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 6)
                                        Text("Honor all confirmed bookings and maintain professional standards")
                                            .font(.subheadline)
                                    }
                                    
                                    HStack(alignment: .top) {
                                        Circle()
                                            .fill(Color.orange)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 6)
                                        Text("Comply with all local, state, and federal regulations")
                                            .font(.subheadline)
                                    }
                                    
                                    HStack(alignment: .top) {
                                        Circle()
                                            .fill(Color.orange)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 6)
                                        Text("Handle customer disputes professionally and fairly")
                                            .font(.subheadline)
                                    }
                                    
                                    HStack(alignment: .top) {
                                        Circle()
                                            .fill(Color.orange)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 6)
                                        Text("Maintain appropriate licenses and insurance for your services")
                                            .font(.subheadline)
                                    }
                                }
                                
                                Toggle("I agree to maintain professional business standards", isOn: $acceptedBusinessTerms)
                                    .toggleStyle(CheckboxToggleStyle(userProfile: userProfile))
                            }
                        }
                        
                        // Data & Privacy Section
                        TermsSection(
                            title: "Data & Privacy",
                            icon: "lock.shield.fill",
                            color: .blue,
                            userProfile: userProfile
                        ) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("We protect your data and privacy:")
                                    .font(.subheadline)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .top) {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 6)
                                        Text("Customer contact information is kept secure and private")
                                            .font(.subheadline)
                                    }
                                    
                                    HStack(alignment: .top) {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 6)
                                        Text("Business analytics help improve platform performance")
                                            .font(.subheadline)
                                    }
                                    
                                    HStack(alignment: .top) {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 6)
                                        Text("You can request data deletion at any time")
                                            .font(.subheadline)
                                    }
                                }
                                
                                Toggle("I accept the data and privacy policy", isOn: $acceptedDataPolicy)
                                    .toggleStyle(CheckboxToggleStyle(userProfile: userProfile))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: acceptTerms) {
                        Text("Accept All Terms & Continue")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(allTermsAccepted ? (userProfile.college?.primaryColor ?? .blue) : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!allTermsAccepted)
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: 600)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 20)
        }
    }
    
    private var allTermsAccepted: Bool {
        return acceptedFeeStructure && acceptedStripeTerms && acceptedBusinessTerms && acceptedDataPolicy
    }
    
    private func acceptTerms() {
        if allTermsAccepted {
            hasAccepted = true
            isPresented = false
            HapticFeedback.success()
        }
    }
}

// MARK: - Terms Section Component
struct TermsSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ObservedObject var userProfile: UserProfile
    let content: Content
    
    init(title: String, icon: String, color: Color, userProfile: UserProfile, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.userProfile = userProfile
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            content
        }
        .padding(20)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Custom Checkbox Toggle Style
struct CheckboxToggleStyle: ToggleStyle {
    @ObservedObject var userProfile: UserProfile
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 12) {
            Button(action: {
                configuration.isOn.toggle()
                HapticFeedback.light()
            }) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundColor(configuration.isOn ? (userProfile.college?.primaryColor ?? .blue) : .gray)
            }
            
            configuration.label
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            configuration.isOn.toggle()
            HapticFeedback.light()
        }
    }
}

#Preview {
    TermsAndConditionsPopup(
        userProfile: UserProfile(),
        isPresented: .constant(true),
        hasAccepted: .constant(false)
    )
}