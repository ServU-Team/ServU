//
//  ContrastLevel.swift
//  ServU
//
//  Created by Amber Still on 8/9/25.
//


//
//  ColorExtensions.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  Brand color definitions and color utilities
//

import SwiftUI
import UIKit

// MARK: - ServU Brand Colors
extension Color {
    
    // MARK: - Primary Brand Colors
    static let servURed = Color(red: 0.85, green: 0.25, blue: 0.25)
    static let servUBlue = Color(red: 0.2, green: 0.4, blue: 0.8)
    static let servUGreen = Color(red: 0.2, green: 0.7, blue: 0.3)
    static let servUOrange = Color(red: 1.0, green: 0.6, blue: 0.0)
    static let servUPurple = Color(red: 0.6, green: 0.3, blue: 0.8)
    static let servUYellow = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let servUPink = Color(red: 0.9, green: 0.4, blue: 0.6)
    static let servUCyan = Color(red: 0.3, green: 0.8, blue: 0.9)
    
    // MARK: - Secondary Brand Colors
    static let servULightRed = Color(red: 0.95, green: 0.8, blue: 0.8)
    static let servUDarkRed = Color(red: 0.7, green: 0.1, blue: 0.1)
    static let servULightBlue = Color(red: 0.8, green: 0.9, blue: 1.0)
    static let servUDarkBlue = Color(red: 0.1, green: 0.2, blue: 0.6)
    
    // MARK: - Neutral Colors
    static let servUGray50 = Color(red: 0.98, green: 0.98, blue: 0.98)
    static let servUGray100 = Color(red: 0.96, green: 0.96, blue: 0.96)
    static let servUGray200 = Color(red: 0.93, green: 0.93, blue: 0.93)
    static let servUGray300 = Color(red: 0.83, green: 0.83, blue: 0.83)
    static let servUGray400 = Color(red: 0.64, green: 0.64, blue: 0.64)
    static let servUGray500 = Color(red: 0.46, green: 0.46, blue: 0.46)
    static let servUGray600 = Color(red: 0.32, green: 0.32, blue: 0.32)
    static let servUGray700 = Color(red: 0.25, green: 0.25, blue: 0.25)
    static let servUGray800 = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let servUGray900 = Color(red: 0.07, green: 0.07, blue: 0.07)
    
    // MARK: - Semantic Colors
    static let servUSuccess = Color(red: 0.13, green: 0.69, blue: 0.3)
    static let servUWarning = Color(red: 0.98, green: 0.75, blue: 0.18)
    static let servUError = Color(red: 0.91, green: 0.3, blue: 0.24)
    static let servUInfo = Color(red: 0.23, green: 0.52, blue: 0.96)
    
    // MARK: - Background Colors
    static let servUBackground = Color(.systemGray6)
    static let servUCardBackground = Color(.systemBackground)
    static let servUModalBackground = Color(.systemBackground)
    static let servUOverlayBackground = Color.black.opacity(0.3)
    
    // MARK: - Text Colors
    static let servUPrimaryText = Color.primary
    static let servUSecondaryText = Color.secondary
    static let servUTertiaryText = Color(.tertiaryLabel)
    static let servUPlaceholderText = Color(.placeholderText)
}

// MARK: - Color Utilities
extension Color {
    
    /// Create color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Convert to hex string
    var hexString: String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb: Int = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
    
    /// Lighten color by percentage
    func lighten(by percentage: Double) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let newBrightness = min(brightness + CGFloat(percentage), 1.0)
        
        return Color(UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha))
    }
    
    /// Darken color by percentage
    func darken(by percentage: Double) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let newBrightness = max(brightness - CGFloat(percentage), 0.0)
        
        return Color(UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha))
    }
    
    /// Adjust saturation
    func saturate(by percentage: Double) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let newSaturation = min(saturation + CGFloat(percentage), 1.0)
        
        return Color(UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha))
    }
    
    /// Desaturate color
    func desaturate(by percentage: Double) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let newSaturation = max(saturation - CGFloat(percentage), 0.0)
        
        return Color(UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha))
    }
    
    /// Get contrasting text color (black or white)
    var contrastingTextColor: Color {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate luminance
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        
        return luminance > 0.5 ? .black : .white
    }
    
    /// Check if color is dark
    var isDark: Bool {
        return contrastingTextColor == .white
    }
    
    /// Check if color is light
    var isLight: Bool {
        return contrastingTextColor == .black
    }
}

// MARK: - Color Schemes
extension Color {
    
    /// Get college-specific color palette
    static func collegeColors(for college: College?) -> (primary: Color, secondary: Color) {
        guard let college = college else {
            return (.servURed, .servUBlue)
        }
        return (college.primaryColor, college.secondaryColor)
    }
    
    /// Get service category color
    static func serviceColor(for category: ServiceCategory) -> Color {
        return category.color
    }
    
    /// Get product category color
    static func productColor(for category: ProductCategory) -> Color {
        return category.color
    }
    
    /// Get status color
    static func statusColor(for status: BookingStatus) -> Color {
        return status.color
    }
    
    /// Get price range color
    static func priceRangeColor(for range: PriceRange) -> Color {
        return range.color
    }
}

// MARK: - Gradient Utilities
extension LinearGradient {
    
    /// ServU brand gradient
    static let servUBrand = LinearGradient(
        colors: [.servURed, .servUOrange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Success gradient
    static let success = LinearGradient(
        colors: [.servUGreen, .servUGreen.lighten(by: 0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Warning gradient
    static let warning = LinearGradient(
        colors: [.servUWarning, .servUOrange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Error gradient
    static let error = LinearGradient(
        colors: [.servUError, .servUError.darken(by: 0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Neutral gradient
    static let neutral = LinearGradient(
        colors: [.servUGray100, .servUGray200],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Create custom gradient
    static func custom(colors: [Color], startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing) -> LinearGradient {
        return LinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }
}

// MARK: - Service Category Colors
extension ServiceCategory {
    var color: Color {
        switch self {
        case .photoVideo: return .servUPurple
        case .hairStylist: return .servUPink
        case .barber: return .servUBlue
        case .lashTech: return .servUOrange
        case .nailTech: return .servURed
        case .tutor: return .servUGreen
        case .foodDelivery: return .servUYellow
        case .cleaning: return .servUCyan
        case .eventPlanning: return .servUPurple.lighten(by: 0.2)
        case .other: return .servUGray500
        }
    }
}

// MARK: - Product Category Colors
extension ProductCategory {
    var color: Color {
        switch self {
        case .clothing: return .servUPurple
        case .electronics: return .servUBlue
        case .books: return .servUGreen
        case .food: return .servUOrange
        case .health: return .servUPink
        case .home: return Color(red: 0.65, green: 0.16, blue: 0.16)
        case .sports: return .servURed
        case .art: return Color(red: 0.6, green: 0.3, blue: 0.8)
        case .other: return .servUGray500
        }
    }
}

// MARK: - Status Colors
extension BookingStatus {
    var color: Color {
        switch self {
        case .pending: return .servUWarning
        case .confirmed: return .servUBlue
        case .inProgress: return .servUPurple
        case .completed: return .servUSuccess
        case .cancelled: return .servUError
        case .noShow: return .servUGray500
        }
    }
}

// MARK: - Price Range Colors
extension PriceRange {
    var color: Color {
        switch self {
        case .budget: return .servUGreen
        case .moderate: return .servUBlue
        case .premium: return .servUOrange
        case .luxury: return .servUPurple
        }
    }
}

// MARK: - Dynamic Color Support
extension Color {
    
    /// Create color that adapts to light/dark mode
    static func adaptive(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
    
    /// Get appropriate color for current interface style
    func forCurrentStyle() -> Color {
        return self
    }
}

// MARK: - Color Accessibility
extension Color {
    
    /// Check if color meets WCAG contrast requirements
    func meetsContrastRequirements(against background: Color, level: ContrastLevel = .AA) -> Bool {
        let contrastRatio = self.contrastRatio(with: background)
        
        switch level {
        case .AA:
            return contrastRatio >= 4.5
        case .AAA:
            return contrastRatio >= 7.0
        }
    }
    
    /// Calculate contrast ratio between two colors
    func contrastRatio(with other: Color) -> Double {
        let luminance1 = self.relativeLuminance()
        let luminance2 = other.relativeLuminance()
        
        let lighter = max(luminance1, luminance2)
        let darker = min(luminance1, luminance2)
        
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    /// Calculate relative luminance
    private func relativeLuminance() -> Double {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        func adjust(_ component: CGFloat) -> Double {
            let c = Double(component)
            return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        
        return 0.2126 * adjust(red) + 0.7152 * adjust(green) + 0.0722 * adjust(blue)
    }
}

enum ContrastLevel {
    case AA
    case AAA
}

// MARK: - Usage Examples in Comments
/*
 Usage Examples:
 
 1. Using brand colors:
 Text("ServU")
     .foregroundColor(.servURed)
     .background(.servULightRed)
 
 2. Creating colors from hex:
 let customColor = Color(hex: "#FF6B6B")
 
 3. Color manipulation:
 let lighterRed = Color.servURed.lighten(by: 0.2)
 let darkerBlue = Color.servUBlue.darken(by: 0.3)
 
 4. Using gradients:
 Rectangle()
     .fill(LinearGradient.servUBrand)
 
 5. Service category colors:
 Circle()
     .fill(ServiceCategory.photoVideo.color)
 
 6. Contrast checking:
 let textColor = backgroundColor.contrastingTextColor
 
 7. Accessibility:
 if textColor.meetsContrastRequirements(against: backgroundColor) {
     // Use this color combination
 }
 
 8. Dynamic colors:
 let adaptiveColor = Color.adaptive(
     light: .servURed,
     dark: .servULightRed
 )
 */