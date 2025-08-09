//
//  ServUSpacing.swift
//  ServU
//
//  Created by Amber Still on 8/9/25.
//


//
//  ViewExtensions.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  SwiftUI view modifiers and extensions for consistent UI
//

import SwiftUI

// MARK: - Card Styling
extension View {
    /// Apply ServU card styling with shadow and corner radius
    func servUCardShadow() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    /// Apply light card styling
    func lightCardShadow() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    /// Apply heavy card styling for emphasis
    func heavyCardShadow() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Button Styling
extension View {
    /// Primary ServU button style
    func servUPrimaryButton(color: Color = .servURed) -> some View {
        self
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(color)
            .cornerRadius(12)
            .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    /// Secondary ServU button style
    func servUSecondaryButton(color: Color = .servURed) -> some View {
        self
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(color.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
    }
    
    /// Outline button style
    func servUOutlineButton(color: Color = .servURed) -> some View {
        self
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.clear)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color, lineWidth: 1.5)
            )
    }
    
    /// Small button style
    func servUSmallButton(color: Color = .servURed) -> some View {
        self
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color)
            .cornerRadius(8)
    }
}

// MARK: - Text Field Styling
extension View {
    /// ServU text field styling
    func servUTextField() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
    
    /// Focused text field styling
    func servUTextFieldFocused() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.servURed, lineWidth: 2)
            )
            .shadow(color: Color.servURed.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Loading States
extension View {
    /// Show loading overlay
    func loadingOverlay(isLoading: Bool) -> some View {
        self
            .overlay(
                Group {
                    if isLoading {
                        ZStack {
                            Color.black.opacity(0.3)
                                .edgesIgnoringSafeArea(.all)
                            
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                
                                Text("Loading...")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .padding(32)
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(16)
                        }
                    }
                }
            )
    }
    
    /// Shimmer loading effect
    func shimmerLoading() -> some View {
        self
            .redacted(reason: .placeholder)
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.white.opacity(0.6), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(-45))
                    .animation(
                        Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                        value: UUID()
                    )
            )
    }
}

// MARK: - Navigation
extension View {
    /// Hide navigation bar
    func hideNavigationBar() -> some View {
        self.navigationBarHidden(true)
    }
    
    /// Custom navigation bar
    func customNavigationBar<Content: View>(
        title: String = "",
        @ViewBuilder trailing: () -> Content = { EmptyView() }
    ) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                trailing()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            
            self
        }
    }
}

// MARK: - Spacing
extension View {
    /// Add consistent spacing
    func servUSpacing(_ spacing: ServUSpacing = .medium) -> some View {
        self.padding(spacing.value)
    }
    
    /// Add horizontal spacing
    func servUHorizontalSpacing(_ spacing: ServUSpacing = .medium) -> some View {
        self.padding(.horizontal, spacing.value)
    }
    
    /// Add vertical spacing
    func servUVerticalSpacing(_ spacing: ServUSpacing = .medium) -> some View {
        self.padding(.vertical, spacing.value)
    }
}

enum ServUSpacing {
    case xs, small, medium, large, xl, xxl
    
    var value: CGFloat {
        switch self {
        case .xs: return 4
        case .small: return 8
        case .medium: return 16
        case .large: return 24
        case .xl: return 32
        case .xxl: return 48
        }
    }
}

// MARK: - Animations
extension View {
    /// Bounce animation on tap
    func bounceOnTap() -> some View {
        self
            .scaleEffect(1.0)
            .animation(.interpolatingSpring(stiffness: 300, damping: 10), value: UUID())
    }
    
    /// Fade transition
    func fadeTransition() -> some View {
        self
            .transition(.opacity.animation(.easeInOut(duration: 0.3)))
    }
    
    /// Slide transition
    func slideTransition(edge: Edge = .trailing) -> some View {
        self
            .transition(.move(edge: edge).combined(with: .opacity))
    }
    
    /// Scale and fade transition
    func scaleAndFadeTransition() -> some View {
        self
            .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Conditional Modifiers
extension View {
    /// Conditionally apply a modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Conditionally apply a modifier with else clause
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if trueTransform: (Self) -> TrueContent,
        else falseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }
}

// MARK: - Accessibility
extension View {
    /// Add accessibility label and hint
    func servUAccessibility(label: String, hint: String? = nil, traits: AccessibilityTraits = []) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
    
    /// Mark as button for accessibility
    func accessibilityButton() -> some View {
        self.accessibilityAddTraits(.isButton)
    }
    
    /// Mark as header for accessibility
    func accessibilityHeader() -> some View {
        self.accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Color Extensions
extension Color {
    static let servURed = Color(red: 0.85, green: 0.25, blue: 0.25)
    static let servUBlue = Color(red: 0.2, green: 0.4, blue: 0.8)
    static let servUGreen = Color(red: 0.2, green: 0.7, blue: 0.3)
    static let servUOrange = Color(red: 1.0, green: 0.6, blue: 0.0)
    static let servUPurple = Color(red: 0.6, green: 0.3, blue: 0.8)
    
    // Background colors
    static let servUBackground = Color(.systemGray6)
    static let servUCardBackground = Color(.systemBackground)
    
    // Text colors
    static let servUPrimary = Color.primary
    static let servUSecondary = Color.secondary
    static let servUTertiary = Color(.tertiaryLabel)
}

// MARK: - Safe Area Extensions
extension View {
    /// Ignore safe area for specific edges
    func ignoreSafeArea(_ edges: Edge.Set = .all) -> some View {
        self.edgesIgnoringSafeArea(edges)
    }
    
    /// Add safe area padding
    func safeAreaPadding(_ edges: Edge.Set = .all) -> some View {
        self.padding(edges, 0) // Will use safe area by default
    }
}