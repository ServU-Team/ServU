//
//  ServUPrimaryButtonStyle.swift
//  ServU
//
//  Created by Amber Still on 8/9/25.
//


//
//  CustomButtonStyles.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  Reusable button styles for consistent UI
//

import SwiftUI

// MARK: - Primary Button Style
struct ServUPrimaryButtonStyle: ButtonStyle {
    var color: Color = .servURed
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDisabled ? Color.gray : color)
                    .shadow(
                        color: (isDisabled ? Color.gray : color).opacity(0.3),
                        radius: configuration.isPressed ? 2 : 4,
                        x: 0,
                        y: configuration.isPressed ? 1 : 2
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .disabled(isDisabled)
    }
}

// MARK: - Secondary Button Style
struct ServUSecondaryButtonStyle: ButtonStyle {
    var color: Color = .servURed
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(isDisabled ? .gray : color)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill((isDisabled ? Color.gray : color).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isDisabled ? Color.gray : color, lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .disabled(isDisabled)
    }
}

// MARK: - Outline Button Style
struct ServUOutlineButtonStyle: ButtonStyle {
    var color: Color = .servURed
    var lineWidth: CGFloat = 1.5
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(isDisabled ? .gray : color)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isDisabled ? Color.gray : color, lineWidth: lineWidth)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(configuration.isPressed ? color.opacity(0.1) : Color.clear)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .disabled(isDisabled)
    }
}

// MARK: - Floating Action Button Style
struct ServUFloatingButtonStyle: ButtonStyle {
    var color: Color = .servURed
    var size: CGFloat = 56
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(color)
                    .shadow(
                        color: color.opacity(0.3),
                        radius: configuration.isPressed ? 4 : 8,
                        x: 0,
                        y: configuration.isPressed ? 2 : 4
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Capsule Button Style
struct ServUCapsuleButtonStyle: ButtonStyle {
    var color: Color = .servURed
    var textColor: Color = .white
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(isDisabled ? .gray : textColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isDisabled ? Color.gray.opacity(0.3) : color)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .disabled(isDisabled)
    }
}

// MARK: - Gradient Button Style
struct ServUGradientButtonStyle: ButtonStyle {
    var gradient: LinearGradient
    var isDisabled: Bool = false
    
    init(colors: [Color] = [.servURed, .servUOrange], isDisabled: Bool = false) {
        self.gradient = LinearGradient(
            colors: colors,
            startPoint: .leading,
            endPoint: .trailing
        )
        self.isDisabled = isDisabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDisabled ? Color.gray : gradient)
                    .shadow(
                        color: Color.black.opacity(0.2),
                        radius: configuration.isPressed ? 2 : 4,
                        x: 0,
                        y: configuration.isPressed ? 1 : 2
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .disabled(isDisabled)
    }
}

// MARK: - Icon Button Style
struct ServUIconButtonStyle: ButtonStyle {
    var color: Color = .servURed
    var backgroundColor: Color = Color.clear
    var size: CGFloat = 44
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(isDisabled ? .gray : color)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(backgroundColor)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .disabled(isDisabled)
    }
}

// MARK: - Card Button Style
struct ServUCardButtonStyle: ButtonStyle {
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: configuration.isPressed ? 4 : 8,
                        x: 0,
                        y: configuration.isPressed ? 2 : 4
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .disabled(isDisabled)
    }
}

// MARK: - Destructive Button Style
struct ServUDestructiveButtonStyle: ButtonStyle {
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDisabled ? Color.gray : Color.red)
                    .shadow(
                        color: Color.red.opacity(0.3),
                        radius: configuration.isPressed ? 2 : 4,
                        x: 0,
                        y: configuration.isPressed ? 1 : 2
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .disabled(isDisabled)
    }
}

// MARK: - Toggle Button Style
struct ServUToggleButtonStyle: ButtonStyle {
    var isSelected: Bool
    var color: Color = .servURed
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? color : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(color, lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .disabled(isDisabled)
    }
}

// MARK: - Bouncy Button Style
struct ServUBouncyButtonStyle: ButtonStyle {
    var color: Color = .servURed
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
            )
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

// MARK: - Button Style Extensions
extension ButtonStyle where Self == ServUPrimaryButtonStyle {
    static func servUPrimary(color: Color = .servURed, isDisabled: Bool = false) -> ServUPrimaryButtonStyle {
        ServUPrimaryButtonStyle(color: color, isDisabled: isDisabled)
    }
}

extension ButtonStyle where Self == ServUSecondaryButtonStyle {
    static func servUSecondary(color: Color = .servURed, isDisabled: Bool = false) -> ServUSecondaryButtonStyle {
        ServUSecondaryButtonStyle(color: color, isDisabled: isDisabled)
    }
}

extension ButtonStyle where Self == ServUOutlineButtonStyle {
    static func servUOutline(color: Color = .servURed, lineWidth: CGFloat = 1.5, isDisabled: Bool = false) -> ServUOutlineButtonStyle {
        ServUOutlineButtonStyle(color: color, lineWidth: lineWidth, isDisabled: isDisabled)
    }
}

extension ButtonStyle where Self == ServUFloatingButtonStyle {
    static func servUFloating(color: Color = .servURed, size: CGFloat = 56) -> ServUFloatingButtonStyle {
        ServUFloatingButtonStyle(color: color, size: size)
    }
}

extension ButtonStyle where Self == ServUCapsuleButtonStyle {
    static func servUCapsule(color: Color = .servURed, textColor: Color = .white, isDisabled: Bool = false) -> ServUCapsuleButtonStyle {
        ServUCapsuleButtonStyle(color: color, textColor: textColor, isDisabled: isDisabled)
    }
}

extension ButtonStyle where Self == ServUGradientButtonStyle {
    static func servUGradient(colors: [Color] = [.servURed, .servUOrange], isDisabled: Bool = false) -> ServUGradientButtonStyle {
        ServUGradientButtonStyle(colors: colors, isDisabled: isDisabled)
    }
}

extension ButtonStyle where Self == ServUIconButtonStyle {
    static func servUIcon(color: Color = .servURed, backgroundColor: Color = .clear, size: CGFloat = 44, isDisabled: Bool = false) -> ServUIconButtonStyle {
        ServUIconButtonStyle(color: color, backgroundColor: backgroundColor, size: size, isDisabled: isDisabled)
    }
}

extension ButtonStyle where Self == ServUCardButtonStyle {
    static func servUCard(isDisabled: Bool = false) -> ServUCardButtonStyle {
        ServUCardButtonStyle(isDisabled: isDisabled)
    }
}

extension ButtonStyle where Self == ServUDestructiveButtonStyle {
    static func servUDestructive(isDisabled: Bool = false) -> ServUDestructiveButtonStyle {
        ServUDestructiveButtonStyle(isDisabled: isDisabled)
    }
}

extension ButtonStyle where Self == ServUToggleButtonStyle {
    static func servUToggle(isSelected: Bool, color: Color = .servURed, isDisabled: Bool = false) -> ServUToggleButtonStyle {
        ServUToggleButtonStyle(isSelected: isSelected, color: color, isDisabled: isDisabled)
    }
}

extension ButtonStyle where Self == ServUBouncyButtonStyle {
    static func servUBouncy(color: Color = .servURed) -> ServUBouncyButtonStyle {
        ServUBouncyButtonStyle(color: color)
    }
}

// MARK: - Usage Examples in Comments
/*
 Usage Examples:
 
 1. Primary button:
 Button("Book Now") {
     // action
 }
 .buttonStyle(.servUPrimary())
 
 2. Secondary button:
 Button("Cancel") {
     // action
 }
 .buttonStyle(.servUSecondary())
 
 3. Outline button:
 Button("Learn More") {
     // action
 }
 .buttonStyle(.servUOutline())
 
 4. Floating action button:
 Button {
     // action
 } label: {
     Image(systemName: "plus")
 }
 .buttonStyle(.servUFloating())
 
 5. Gradient button:
 Button("Purchase") {
     // action
 }
 .buttonStyle(.servUGradient(colors: [.blue, .purple]))
 
 6. Toggle button:
 Button("Filter") {
     isSelected.toggle()
 }
 .buttonStyle(.servUToggle(isSelected: isSelected))
 
 7. Icon button:
 Button {
     // action
 } label: {
     Image(systemName: "heart")
 }
 .buttonStyle(.servUIcon(color: .red))
 
 8. Destructive button:
 Button("Delete") {
     // action
 }
 .buttonStyle(.servUDestructive())
 */