//
//  RoundedCorner.swift
//  ServU
//
//  Created by Amber Still on 8/9/25.
//


//
//  RoundedCorner.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  UI shape extensions for custom corner rounding
//

import SwiftUI

// MARK: - Rounded Corner Shape
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

// MARK: - View Extension for Rounded Corners
extension View {
    /// Apply custom corner radius to specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    /// Apply top corner radius only
    func topCornerRadius(_ radius: CGFloat) -> some View {
        cornerRadius(radius, corners: [.topLeft, .topRight])
    }
    
    /// Apply bottom corner radius only
    func bottomCornerRadius(_ radius: CGFloat) -> some View {
        cornerRadius(radius, corners: [.bottomLeft, .bottomRight])
    }
    
    /// Apply left corner radius only
    func leftCornerRadius(_ radius: CGFloat) -> some View {
        cornerRadius(radius, corners: [.topLeft, .bottomLeft])
    }
    
    /// Apply right corner radius only
    func rightCornerRadius(_ radius: CGFloat) -> some View {
        cornerRadius(radius, corners: [.topRight, .bottomRight])
    }
}

// MARK: - Custom Card Shapes
struct ServUCardShape: Shape {
    var cornerRadius: CGFloat = 16
    var shadowRadius: CGFloat = 8
    
    func path(in rect: CGRect) -> Path {
        return RoundedRectangle(cornerRadius: cornerRadius).path(in: rect)
    }
}

struct ServUButtonShape: Shape {
    var cornerRadius: CGFloat = 12
    var isPressed: Bool = false
    
    func path(in rect: CGRect) -> Path {
        let adjustedRadius = isPressed ? cornerRadius * 0.8 : cornerRadius
        return RoundedRectangle(cornerRadius: adjustedRadius).path(in: rect)
    }
}

// MARK: - Bubble Shapes
struct ChatBubbleShape: Shape {
    var isFromUser: Bool
    var cornerRadius: CGFloat = 16
    
    func path(in rect: CGRect) -> Path {
        let corners: UIRectCorner = isFromUser ? 
            [.topLeft, .bottomLeft, .bottomRight] : 
            [.topRight, .bottomLeft, .bottomRight]
        
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return Path(path.cgPath)
    }
}

struct NotificationBadgeShape: Shape {
    func path(in rect: CGRect) -> Path {
        return Circle().path(in: rect)
    }
}

// MARK: - Custom Clipping Shapes
struct TopRoundedRectangle: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(
            center: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
        path.addArc(
            center: CGPoint(x: rect.width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

struct BottomRoundedRectangle: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.width - cornerRadius, y: rect.height - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
        path.addArc(
            center: CGPoint(x: cornerRadius, y: rect.height - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Tab Bar Shape
struct CustomTabBarShape: Shape {
    var cornerRadius: CGFloat = 20
    var tabHeight: CGFloat = 80
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start from bottom left
        path.move(to: CGPoint(x: 0, y: rect.height))
        
        // Top left corner
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        
        // Top edge
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
        
        // Top right corner
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: cornerRadius),
            control: CGPoint(x: rect.width, y: 0)
        )
        
        // Right edge and bottom
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        
        return path
    }
}

// MARK: - Wave Shapes
struct WaveShape: Shape {
    var amplitude: CGFloat = 20
    var frequency: CGFloat = 2
    var phase: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: rect.midY))
        
        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / rect.width
            let sine = sin(relativeX * frequency * 2 * .pi + phase)
            let y = rect.midY + sine * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

// MARK: - Triangle Shapes
struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

struct ArrowShape: Shape {
    var direction: ArrowDirection = .right
    var headSize: CGFloat = 10
    
    enum ArrowDirection {
        case up, down, left, right
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        switch direction {
        case .right:
            path.move(to: CGPoint(x: rect.minX, y: rect.midY - headSize/2))
            path.addLine(to: CGPoint(x: rect.maxX - headSize, y: rect.midY - headSize/2))
            path.addLine(to: CGPoint(x: rect.maxX - headSize, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX - headSize, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX - headSize, y: rect.midY + headSize/2))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY + headSize/2))
            
        case .left:
            path.move(to: CGPoint(x: rect.maxX, y: rect.midY - headSize/2))
            path.addLine(to: CGPoint(x: rect.minX + headSize, y: rect.midY - headSize/2))
            path.addLine(to: CGPoint(x: rect.minX + headSize, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX + headSize, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + headSize, y: rect.midY + headSize/2))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY + headSize/2))
            
        case .up:
            path.move(to: CGPoint(x: rect.midX - headSize/2, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX - headSize/2, y: rect.minY + headSize))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + headSize))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + headSize))
            path.addLine(to: CGPoint(x: rect.midX + headSize/2, y: rect.minY + headSize))
            path.addLine(to: CGPoint(x: rect.midX + headSize/2, y: rect.maxY))
            
        case .down:
            path.move(to: CGPoint(x: rect.midX - headSize/2, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX - headSize/2, y: rect.maxY - headSize))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - headSize))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - headSize))
            path.addLine(to: CGPoint(x: rect.midX + headSize/2, y: rect.maxY - headSize))
            path.addLine(to: CGPoint(x: rect.midX + headSize/2, y: rect.minY))
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Usage Examples in Comments
/*
 Usage Examples:
 
 1. Custom corner radius:
 Rectangle()
     .cornerRadius(16, corners: [.topLeft, .topRight])
 
 2. Top rounded only:
 Rectangle()
     .topCornerRadius(20)
 
 3. Custom card shape:
 VStack { }
     .background(Color.white)
     .clipShape(ServUCardShape(cornerRadius: 16))
 
 4. Chat bubble:
 Text("Hello!")
     .padding()
     .background(Color.blue)
     .clipShape(ChatBubbleShape(isFromUser: true))
 
 5. Custom tab bar:
 HStack { }
     .background(Color.white)
     .clipShape(CustomTabBarShape())
 
 6. Arrow indicator:
 ArrowShape(direction: .right)
     .fill(Color.gray)
     .frame(width: 20, height: 20)
 */