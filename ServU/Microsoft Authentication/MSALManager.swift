//
//  MSALManager.swift
//  ServU
//
//  Created by Quian Bowden on 6/27/25.
//  Updated by Assistant on 7/19/25.
//

import Foundation
import MSAL
import UIKit

// Think of this as your authentication assistant
class MSALManager: ObservableObject {
    
    // MARK: - Configuration
    // These are like your app's ID card details
    let kClientID = "51a8b01f-ca99-44ac-8727-f1e2dd870b5d"
    let kRedirectUri = "msauth.Serv.ServU://auth"
    let kAuthority = "https://login.microsoftonline.com/common"
    let kGraphEndpoint = "https://graph.microsoft.com/"
    let kScopes = ["User.Read"]
    
    // MARK: - Properties
    @Published var isSignedIn = false
    @Published var currentUser: String = ""
    @Published var loggingText: String = ""
    @Published var accessToken: String = ""
    
    private var applicationContext: MSALPublicClientApplication?
    private var webViewParameters: MSALWebviewParameters?
    private var currentAccount: MSALAccount?
    
    // MARK: - Initialization
    init() {
        setupMSAL()
    }
    
    // MARK: - Setup Methods
    private func setupMSAL() {
        do {
            let authority = try MSALAADAuthority(url: URL(string: "https://login.microsoftonline.com/common")!)
            
            let pcaConfig = MSALPublicClientApplicationConfig(
                clientId: kClientID,
                redirectUri: kRedirectUri,
                authority: authority
            )
            
            // Create the application context - like setting up your authentication office
            self.applicationContext = try MSALPublicClientApplication(configuration: pcaConfig)
            
            // Setup web view parameters - like decorating your sign-in window
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                updateLogging(text: "Could not find window")
                return
            }
            
            self.webViewParameters = MSALWebviewParameters(authPresentationViewController: window.rootViewController!)
            
            updateLogging(text: "MSAL initialized successfully")
            
        } catch {
            updateLogging(text: "Unable to create MSAL application context: \(error)")
        }
    }
    
    // MARK: - Authentication Methods
    
    // Interactive Sign In - Like knocking on Microsoft's front door
    func signInInteractively() {
        guard let applicationContext = self.applicationContext else {
            updateLogging(text: "Application context not available")
            return
        }
        
        guard let webViewParameters = self.webViewParameters else {
            updateLogging(text: "Web view parameters not available")
            return
        }
        
        updateLogging(text: "Starting interactive sign in...")
        
        // Set up the sign-in parameters - like filling out a visitor form
        let parameters = MSALInteractiveTokenParameters(
            scopes: kScopes,
            webviewParameters: webViewParameters
        )
        parameters.promptType = .selectAccount // Show account selection if multiple accounts
        
        // Make the sign-in request - like presenting your visitor form
        applicationContext.acquireToken(with: parameters) { [weak self] (result, error) in
            DispatchQueue.main.async {
                self?.handleSignInResult(result: result, error: error)
            }
        }
    }
    
    // Silent Sign In - Like using a keycard you already have
    func signInSilently() {
        guard let currentAccount = self.currentAccount else {
            updateLogging(text: "No current account available for silent sign in")
            return
        }
        
        acquireTokenSilently(account: currentAccount)
    }
    
    // The actual silent token acquisition - like accessing your office with your keycard
    private func acquireTokenSilently(account: MSALAccount) {
        guard let applicationContext = self.applicationContext else {
            updateLogging(text: "Application context not available")
            return
        }
        
        updateLogging(text: "Attempting silent sign in...")
        
        let parameters = MSALSilentTokenParameters(scopes: kScopes, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters) { [weak self] (result, error) in
            DispatchQueue.main.async {
                if let error = error {
                    let nsError = error as NSError
                    
                    // Check if user interaction is needed - like if your keycard expired
                    if nsError.domain == MSALErrorDomain &&
                       nsError.code == MSALError.interactionRequired.rawValue {
                        self?.updateLogging(text: "Silent sign in failed, trying interactive...")
                        self?.signInInteractively()
                        return
                    }
                    
                    self?.updateLogging(text: "Silent sign in failed: \(error)")
                    return
                }
                
                self?.handleSignInResult(result: result, error: error)
            }
        }
    }
    
    // Handle the result of any sign-in attempt - like processing your visitor badge
    private func handleSignInResult(result: MSALResult?, error: Error?) {
        if let error = error {
            updateLogging(text: "Sign in failed: \(error)")
            return
        }
        
        guard let result = result else {
            updateLogging(text: "No result returned from sign in")
            return
        }
        
        // Success! Update all the relevant information
        self.accessToken = result.accessToken
        self.currentAccount = result.account
        self.isSignedIn = true
        self.currentUser = result.account.username ?? "Unknown User"
        
        updateLogging(text: "Sign in successful! Welcome \(self.currentUser)")
    }
    
    // Sign Out - Like returning your visitor badge and leaving the building
    func signOut() {
        guard let applicationContext = self.applicationContext else {
            updateLogging(text: "Application context not available")
            return
        }
        
        guard let account = self.currentAccount else {
            updateLogging(text: "No account to sign out")
            return
        }
        
        guard let webViewParameters = self.webViewParameters else {
            updateLogging(text: "Web view parameters not available")
            return
        }
        
        updateLogging(text: "Signing out...")
        
        let signoutParameters = MSALSignoutParameters(webviewParameters: webViewParameters)
        signoutParameters.signoutFromBrowser = false // Don't sign out from browser
        
        applicationContext.signout(with: account, signoutParameters: signoutParameters) { [weak self] (success, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.updateLogging(text: "Sign out failed: \(error)")
                    return
                }
                
                // Clear all user data - like cleaning out your desk
                self?.accessToken = ""
                self?.currentAccount = nil
                self?.currentUser = ""
                self?.isSignedIn = false
                
                self?.updateLogging(text: "Sign out completed successfully")
            }
        }
    }
    
    // Check for existing account on app start - like checking if you're already signed in
    func loadCurrentAccount() {
        guard let applicationContext = self.applicationContext else {
            updateLogging(text: "Application context not available")
            return
        }
        
        updateLogging(text: "Checking for existing account...")
        
        let parameters = MSALParameters()
        parameters.completionBlockQueue = DispatchQueue.main
        
        applicationContext.getCurrentAccount(with: parameters) { [weak self] (currentAccount, previousAccount, error) in
            if let error = error {
                let nsError = error as NSError
                
                // Handle keychain errors gracefully
                if nsError.domain == MSALErrorDomain && nsError.code == -50003 {
                    self?.updateLogging(text: "⚠️ Keychain access error (common in simulator). Please sign in manually.")
                    // Don't treat this as a fatal error - just means user needs to sign in
                    return
                }
                
                self?.updateLogging(text: "Error checking current account: \(error)")
                return
            }
            
            if let currentAccount = currentAccount {
                self?.currentAccount = currentAccount
                self?.currentUser = currentAccount.username ?? "Unknown User"
                self?.updateLogging(text: "Found existing account: \(self?.currentUser ?? "")")
                
                // Try to get a token silently - like checking if your keycard still works
                self?.acquireTokenSilently(account: currentAccount)
            } else {
                self?.updateLogging(text: "No existing account found - please sign in")
            }
        }
    }
    
    // MARK: - Public Helper Methods
    // Made this public so ContentView can access it
    func updateLogging(text: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logEntry = "\(timestamp): \(text)\n"
        self.loggingText += logEntry
        print(logEntry) // Also print to console for debugging
    }
    
    // Handle URL callbacks - like receiving a phone call confirming your appointment
    func handleAuthResponse(url: URL) -> Bool {
        return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: nil)
    }
    
    // MARK: - Keychain Reset Helper (for development)
    func resetKeychainForDevelopment() {
        updateLogging(text: "🔧 Attempting to reset keychain for development...")
        
        // Clear current user data
        self.accessToken = ""
        self.currentAccount = nil
        self.currentUser = ""
        self.isSignedIn = false
        
        updateLogging(text: "✅ User data cleared. Please sign in again.")
    }
}
