//
//  ConditionalView.swift
//  ServU
//
//  Created by Amber Still on 8/4/25.
//


//
//  ViewBuilderExtensions.swift
//  ServU
//
//  Created by Quian Bowden on 8/4/25.
//

import SwiftUI

// MARK: - ViewBuilder Extensions to fix compilation issues
extension View {
    @ViewBuilder
    func conditionalModifier<T: View>(@ViewBuilder content: @escaping (Self) -> T) -> some View {
        content(self)
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func ifLet<V, Content: View>(_ value: V?, transform: (Self, V) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}

// MARK: - Custom ViewBuilder functions
struct ConditionalView<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
    }
}

// MARK: - Color Extensions for better compatibility
extension Color {
    static let primaryBlue = Color.blue
    static let secondaryGray = Color.gray
    static let successGreen = Color.green
    static let warningOrange = Color.orange
    static let errorRed = Color.red
    
    // Custom colors for the app
    static let servUPrimary = Color("ServUPrimary") // Define in Assets.xcassets
    static let servUSecondary = Color("ServUSecondary") // Define in Assets.xcassets
    static let servUAccent = Color("ServUAccent") // Define in Assets.xcassets
}

// MARK: - Font Extensions
extension Font {
    static let servUTitle = Font.largeTitle.weight(.bold)
    static let servUHeadline = Font.headline.weight(.semibold)
    static let servUSubheadline = Font.subheadline.weight(.medium)
    static let servUBody = Font.body
    static let servUCaption = Font.caption
}

// MARK: - View Modifiers
struct CardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    init(cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 4) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: 2)
    }
}

struct PrimaryButtonModifier: ViewModifier {
    let isEnabled: Bool
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isEnabled ? Color.blue : Color.gray)
            .cornerRadius(12)
            .opacity(isEnabled ? 1.0 : 0.6)
    }
}

struct SecondaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 1)
            )
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle(cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 4) -> some View {
        self.modifier(CardModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
    
    func primaryButtonStyle(isEnabled: Bool = true) -> some View {
        self.modifier(PrimaryButtonModifier(isEnabled: isEnabled))
    }
    
    func secondaryButtonStyle() -> some View {
        self.modifier(SecondaryButtonModifier())
    }
}

// MARK: - Haptic Feedback Helper
struct HapticFeedback {
    static func light() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    static func medium() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    static func heavy() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    static func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    static func warning() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    static func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
}