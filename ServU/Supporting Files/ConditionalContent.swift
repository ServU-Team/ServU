//
//  ConditionalContent.swift
//  ServU
//
//  Created by Amber Still on 8/5/25.
//


//
//  ViewExtensions.swift
//  ServU
//
//  Created by Quian Bowden on 8/4/25.
//  View extensions and utilities to fix ViewBuilder issues
//

import SwiftUI

// MARK: - ViewBuilder Extensions
extension View {
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

// MARK: - Custom ViewBuilder
struct ConditionalContent<TrueContent: View, FalseContent: View>: View {
    let condition: Bool
    let trueContent: TrueContent
    let falseContent: FalseContent
    
    init(_ condition: Bool, @ViewBuilder trueContent: () -> TrueContent, @ViewBuilder falseContent: () -> FalseContent) {
        self.condition = condition
        self.trueContent = trueContent()
        self.falseContent = falseContent()
    }
    
    var body: some View {
        if condition {
            trueContent
        } else {
            falseContent
        }
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

// MARK: - Custom Loading View
struct ServULoadingView: View {
    let message: String
    
    init(message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Button Styles
struct ServUPrimaryButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    
    init(backgroundColor: Color = .blue, foregroundColor: Color = .white, cornerRadius: CGFloat = 12) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ServUSecondaryButtonStyle: ButtonStyle {
    let borderColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    
    init(borderColor: Color = .blue, foregroundColor: Color = .blue, cornerRadius: CGFloat = 12) {
        self.borderColor = borderColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Card Style Modifier
struct CardStyleModifier: ViewModifier {
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: 2)
    }
}

extension View {
    func cardStyle(cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 4) -> some View {
        self.modifier(CardStyleModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
}

// MARK: - Error Handling
struct ErrorView: View {
    let message: String
    let onRetry: (() -> Void)?
    
    init(message: String, onRetry: (() -> Void)? = nil) {
        self.message = message
        self.onRetry = onRetry
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let onRetry = onRetry {
                Button("Try Again") {
                    onRetry()
                }
                .buttonStyle(ServUPrimaryButtonStyle())
            }
        }
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}