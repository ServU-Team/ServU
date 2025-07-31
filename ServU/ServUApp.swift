import SwiftUI

@main
struct ServUApp: App {
    // This connects your SwiftUI app to the AppDelegate
    // Think of it as hiring a receptionist for your business
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
