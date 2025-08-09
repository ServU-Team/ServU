//
//  HapticFeedback.swift
//  ServU
//
//  Created by Amber Still on 8/9/25.
//


//
//  HapticFeedback.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  Tactile feedback for enhanced user experience
//

import UIKit

struct HapticFeedback {
    
    // MARK: - Impact Feedback
    
    /// Light impact feedback (e.g., button taps, toggle switches)
    static func light() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    /// Medium impact feedback (e.g., refresh actions, moderate interactions)
    static func medium() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    /// Heavy impact feedback (e.g., important actions, confirmations)
    static func heavy() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - Notification Feedback
    
    /// Success feedback (e.g., completed tasks, successful payments)
    static func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    /// Warning feedback (e.g., form validation errors, cautions)
    static func warning() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    /// Error feedback (e.g., failed actions, critical errors)
    static func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    // MARK: - Selection Feedback
    
    /// Selection feedback (e.g., picker wheels, segment controls)
    static func selection() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
    
    // MARK: - Custom Patterns
    
    /// Double tap feedback pattern
    static func doubleTap() {
        light()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            light()
        }
    }
    
    /// Confirmation pattern (medium + success)
    static func confirm() {
        medium()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            success()
        }
    }
    
    /// Purchase completion pattern
    static func purchase() {
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            success()
        }
    }
    
    /// Booking confirmation pattern
    static func bookingConfirmed() {
        medium()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            light()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            success()
        }
    }
    
    /// Card swipe pattern
    static func cardSwipe() {
        light()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            medium()
        }
    }
    
    /// Pull to refresh pattern
    static func pullToRefresh() {
        light()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            medium()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            success()
        }
    }
    
    // MARK: - Context-Specific Feedback
    
    /// Feedback for adding items to cart
    static func addToCart() {
        light()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            success()
        }
    }
    
    /// Feedback for removing items from cart
    static func removeFromCart() {
        medium()
    }
    
    /// Feedback for favoriting/unfavoriting
    static func toggleFavorite() {
        light()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            medium()
        }
    }
    
    /// Feedback for navigation transitions
    static func navigate() {
        light()
    }
    
    /// Feedback for search actions
    static func search() {
        light()
    }
    
    /// Feedback for filter applications
    static func filter() {
        selection()
    }
    
    /// Feedback for booking creation
    static func createBooking() {
        medium()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            success()
        }
    }
    
    /// Feedback for payment processing
    static func paymentProcessing() {
        heavy()
    }
    
    /// Feedback for message sending
    static func sendMessage() {
        light()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            medium()
        }
    }
    
    // MARK: - Business Owner Feedback
    
    /// Feedback for new order received
    static func newOrder() {
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            success()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            light()
        }
    }
    
    /// Feedback for service completion
    static func serviceCompleted() {
        medium()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            success()
        }
    }
    
    /// Feedback for business profile updates
    static func profileUpdated() {
        light()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            success()
        }
    }
    
    // MARK: - Utility Methods
    
    /// Check if haptic feedback is supported
    static var isSupported: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    /// Prepare haptic engine (call before anticipated feedback)
    static func prepare() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare()
        
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.prepare()
        
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.prepare()
    }
}