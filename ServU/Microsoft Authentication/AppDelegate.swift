import Foundation
import UIKit
import MSAL

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // This is like your app's receptionist - it handles incoming calls
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // When Microsoft calls back after authentication, this answers the phone
        return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
    }
    
    // If your app uses Scene Delegate (newer iOS versions), this also handles the callback
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

// Scene Delegate - like having a specialized receptionist for different office areas
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // This handles authentication callbacks in newer iOS versions
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else {
            return
        }
        
        let url = urlContext.url
        let sourceApp = urlContext.options.sourceApplication
        
        // Pass the authentication callback to MSAL
        MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: sourceApp)
    }
}
