//
//  RoundedCorner.swift
//  ServU
//
//  Created by Amber Still on 7/31/25.
//


//
//  SwiftUIExtensions.swift
//  ServU
//
//  Created by Quian Bowden on 7/19/25.
//  Updated by Assistant on 7/31/25.
//

import SwiftUI
import UIKit

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Custom Shapes
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Color Extensions
extension Color {
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
    
    // Tuskegee University Brand Colors
    static let tuskegeeGold = Color(hex: "FFD700")
    static let tuskegeeMaroon = Color(hex: "800000")
    
    // ServU Brand Colors
    static let servUGold = Color(hex: "FFD700")
    static let servURed = Color(hex: "DC143C")
}

// MARK: - Font Extensions
extension Font {
    static func servUTitle(_ size: CGFloat = 32) -> Font {
        return .system(size: size, weight: .bold, design: .rounded)
    }
    
    static func servUHeadline(_ size: CGFloat = 24) -> Font {
        return .system(size: size, weight: .semibold, design: .default)
    }
    
    static func servUBody(_ size: CGFloat = 16) -> Font {
        return .system(size: size, weight: .regular, design: .default)
    }
    
    static func servUCaption(_ size: CGFloat = 12) -> Font {
        return .system(size: size, weight: .medium, design: .default)
    }
}

// MARK: - Animation Extensions
extension Animation {
    static let servUSpring = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let servUEaseInOut = Animation.easeInOut(duration: 0.3)
    static let servUBounce = Animation.interpolatingSpring(stiffness: 300, damping: 30)
}

// MARK: - Image Extensions
extension Image {
    func profileImageStyle(size: CGFloat = 50, borderColor: Color = .blue) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(borderColor, lineWidth: 2))
    }
    
    func businessImageStyle(height: CGFloat = 120, cornerRadius: CGFloat = 12) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: height)
            .cornerRadius(cornerRadius)
    }
}

// MARK: - Shadow Styles
extension View {
    func servUCardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    func servUElevatedShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
    }
    
    func servUButtonShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Haptic Feedback
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
    
    static func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
}

// MARK: - Custom Button Styles
struct ServUPrimaryButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    
    init(backgroundColor: Color = .servURed, foregroundColor: Color = .white, cornerRadius: CGFloat = 12) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.servUHeadline(16))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.servUEaseInOut, value: configuration.isPressed)
            .servUButtonShadow()
            .onTapGesture {
                HapticFeedback.light()
            }
    }
}

struct ServUSecondaryButtonStyle: ButtonStyle {
    let borderColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    
    init(borderColor: Color = .servURed, foregroundColor: Color = .servURed, cornerRadius: CGFloat = 12) {
        self.borderColor = borderColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.servUHeadline(16))
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
            .animation(.servUEaseInOut, value: configuration.isPressed)
            .onTapGesture {
                HapticFeedback.light()
            }
    }
}

// MARK: - Loading States
struct ServULoadingView: View {
    let message: String
    let color: Color
    
    init(message: String = "Loading...", color: Color = .servURed) {
        self.message = message
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: color))
                .scaleEffect(1.5)
            
            Text(message)
                .font(.servUBody())
                .foregroundColor(color)
        }
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .servUElevatedShadow()
    }
}

// MARK: - Image Picker (UIKit Wrapper)
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                // Compress image for better performance
                if let imageData = editedImage.jpegData(compressionQuality: 0.7) {
                    parent.imageData = imageData
                }
            } else if let originalImage = info[.originalImage] as? UIImage {
                if let imageData = originalImage.jpegData(compressionQuality: 0.7) {
                    parent.imageData = imageData
                }
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}