//
//  NotificationManager.swift
//  ServU
//
//  Created by Amber Still on 8/9/25.
//


//
//  NotificationManager.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  Push notifications and local notifications management
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    /// Request notification permissions from user
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                self?.checkAuthorizationStatus()
                
                if granted {
                    print("✅ Notification authorization granted")
                    self?.registerForRemoteNotifications()
                } else {
                    print("⚠️ Notification authorization denied")
                }
                
                if let error = error {
                    print("❌ Notification authorization error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Check current authorization status
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    /// Register for remote push notifications
    private func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // MARK: - Booking Notifications
    
    /// Schedule reminder notification for upcoming booking
    func scheduleBookingReminder(for booking: Booking, minutesBefore: Int = 30) {
        guard isAuthorized else {
            print("⚠️ Notifications not authorized - cannot schedule reminder")
            return
        }
        
        let reminderDate = booking.date.addingTimeInterval(-Double(minutesBefore * 60))
        
        // Don't schedule if reminder time is in the past
        guard reminderDate > Date() else {
            print("⚠️ Reminder time is in the past - skipping notification")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Appointment"
        content.body = "Your \(booking.serviceName) appointment with \(booking.businessName) starts in \(minutesBefore) minutes"
        content.sound = .default
        content.badge = 1
        
        // Add custom data
        content.userInfo = [
            "type": "booking_reminder",
            "booking_id": booking.id.uuidString,
            "business_id": booking.businessId.uuidString
        ]
        
        // Create trigger
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create request
        let identifier = "booking_reminder_\(booking.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule booking reminder: \(error.localizedDescription)")
            } else {
                print("✅ Scheduled booking reminder for \(booking.serviceName)")
            }
        }
    }
    
    /// Cancel booking reminder notification
    func cancelBookingReminder(for booking: Booking) {
        let identifier = "booking_reminder_\(booking.id.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("✅ Cancelled booking reminder for \(booking.serviceName)")
    }
    
    /// Schedule booking confirmation notification
    func scheduleBookingConfirmation(for booking: Booking) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Booking Confirmed! 🎉"
        content.body = "Your \(booking.serviceName) appointment with \(booking.businessName) is confirmed for \(DateFormatter.shortDateTime.string(from: booking.date))"
        content.sound = .default
        content.badge = 1
        
        content.userInfo = [
            "type": "booking_confirmation",
            "booking_id": booking.id.uuidString,
            "business_id": booking.businessId.uuidString
        ]
        
        // Immediate notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "booking_confirmation_\(booking.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule booking confirmation: \(error.localizedDescription)")
            } else {
                print("✅ Scheduled booking confirmation for \(booking.serviceName)")
            }
        }
    }
    
    // MARK: - Business Notifications
    
    /// Notify business owner of new booking
    func notifyBusinessOfNewBooking(booking: Booking, businessOwner: UserProfile) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "New Booking! 📅"
        content.body = "New \(booking.serviceName) booking from \(booking.customerName) for \(DateFormatter.shortDateTime.string(from: booking.date))"
        content.sound = .default
        content.badge = 1
        
        content.userInfo = [
            "type": "new_booking",
            "booking_id": booking.id.uuidString,
            "business_id": booking.businessId.uuidString,
            "customer_id": booking.customerName
        ]
        
        // Immediate notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "new_booking_\(booking.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Schedule payment reminder notification
    func schedulePaymentReminder(for booking: Booking, daysBefore: Int = 1) {
        guard isAuthorized else { return }
        
        let reminderDate = booking.date.addingTimeInterval(-Double(daysBefore * 24 * 60 * 60))
        
        guard reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Payment Reminder 💳"
        content.body = "Don't forget to complete payment for your \(booking.serviceName) appointment tomorrow"
        content.sound = .default
        content.badge = 1
        
        content.userInfo = [
            "type": "payment_reminder",
            "booking_id": booking.id.uuidString
        ]
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let identifier = "payment_reminder_\(booking.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Promotional Notifications
    
    /// Schedule promotional notification
    func schedulePromotionalNotification(title: String, body: String, delay: TimeInterval = 0) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        content.userInfo = [
            "type": "promotional"
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(delay, 1), repeats: false)
        let identifier = "promotional_\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Notification Management
    
    /// Get all pending notifications
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            DispatchQueue.main.async {
                completion(notifications)
            }
        }
    }
    
    /// Remove all pending notifications
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("✅ Removed all pending notifications")
    }
    
    /// Remove notifications by type
    func removeNotifications(ofType type: String) {
        getPendingNotifications { notifications in
            let identifiersToRemove = notifications.compactMap { notification in
                if let userInfo = notification.content.userInfo as? [String: Any],
                   let notificationType = userInfo["type"] as? String,
                   notificationType == type {
                    return notification.identifier
                }
                return nil
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            print("✅ Removed \(identifiersToRemove.count) notifications of type: \(type)")
        }
    }
    
    /// Clear badge count
    func clearBadgeCount() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    // MARK: - Settings Helper
    
    /// Open notification settings
    func openNotificationSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    /// Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.alert, .sound, .badge])
    }
    
    /// Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String {
            handleNotificationTap(type: type, userInfo: userInfo)
        }
        
        completionHandler()
    }
    
    private func handleNotificationTap(type: String, userInfo: [AnyHashable: Any]) {
        switch type {
        case "booking_reminder", "booking_confirmation":
            if let bookingId = userInfo["booking_id"] as? String {
                // Navigate to booking details
                NotificationCenter.default.post(
                    name: .navigateToBooking,
                    object: nil,
                    userInfo: ["booking_id": bookingId]
                )
            }
            
        case "new_booking":
            if let businessId = userInfo["business_id"] as? String {
                // Navigate to business dashboard
                NotificationCenter.default.post(
                    name: .navigateToBusiness,
                    object: nil,
                    userInfo: ["business_id": businessId]
                )
            }
            
        case "payment_reminder":
            if let bookingId = userInfo["booking_id"] as? String {
                // Navigate to payment screen
                NotificationCenter.default.post(
                    name: .navigateToPayment,
                    object: nil,
                    userInfo: ["booking_id": bookingId]
                )
            }
            
        case "promotional":
            // Navigate to promotions or home screen
            NotificationCenter.default.post(name: .navigateToHome, object: nil)
            
        default:
            print("⚠️ Unknown notification type: \(type)")
        }
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: - Notification Names
extension Notification.Name {
    static let navigateToBooking = Notification.Name("navigateToBooking")
    static let navigateToBusiness = Notification.Name("navigateToBusiness")
    static let navigateToPayment = Notification.Name("navigateToPayment")
    static let navigateToHome = Notification.Name("navigateToHome")
}