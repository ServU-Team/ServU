//
//  ConditionalContent.swift
//  ServU
//
//  Created by Amber Still on 8/9/25.
//


//
//  ConditionalContent.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  Conditional view helpers for cleaner SwiftUI code
//

import SwiftUI

// MARK: - Conditional View Builder
struct ConditionalContent<TrueContent: View, FalseContent: View>: View {
    let condition: Bool
    let trueContent: TrueContent
    let falseContent: FalseContent
    
    init(
        _ condition: Bool,
        @ViewBuilder ifTrue: () -> TrueContent,
        @ViewBuilder ifFalse: () -> FalseContent
    ) {
        self.condition = condition
        self.trueContent = ifTrue()
        self.falseContent = ifFalse()
    }
    
    var body: some View {
        Group {
            if condition {
                trueContent
            } else {
                falseContent
            }
        }
    }
}

// MARK: - Optional Content
struct OptionalContent<Content: View>: View {
    let content: Content?
    
    init(@ViewBuilder content: () -> Content?) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            if let content = content {
                content
            } else {
                EmptyView()
            }
        }
    }
}

// MARK: - Loading Content
struct LoadingContent<Content: View, LoadingView: View>: View {
    let isLoading: Bool
    let content: Content
    let loadingView: LoadingView
    
    init(
        isLoading: Bool,
        @ViewBuilder content: () -> Content,
        @ViewBuilder loadingView: () -> LoadingView = { ProgressView() }
    ) {
        self.isLoading = isLoading
        self.content = content()
        self.loadingView = loadingView()
    }
    
    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else {
                content
            }
        }
    }
}

// MARK: - Error Content
struct ErrorContent<Content: View, ErrorView: View>: View {
    let error: Error?
    let content: Content
    let errorView: (Error) -> ErrorView
    
    init(
        error: Error?,
        @ViewBuilder content: () -> Content,
        @ViewBuilder errorView: @escaping (Error) -> ErrorView
    ) {
        self.error = error
        self.content = content()
        self.errorView = errorView
    }
    
    var body: some View {
        Group {
            if let error = error {
                errorView(error)
            } else {
                content
            }
        }
    }
}

// MARK: - Empty State Content
struct EmptyStateContent<Content: View, EmptyView: View>: View {
    let isEmpty: Bool
    let content: Content
    let emptyView: EmptyView
    
    init(
        isEmpty: Bool,
        @ViewBuilder content: () -> Content,
        @ViewBuilder emptyView: () -> EmptyView
    ) {
        self.isEmpty = isEmpty
        self.content = content()
        self.emptyView = emptyView()
    }
    
    var body: some View {
        Group {
            if isEmpty {
                emptyView
            } else {
                content
            }
        }
    }
}

// MARK: - Platform Specific Content
struct PlatformContent<iOSContent: View, macOSContent: View>: View {
    let iosContent: iOSContent
    let macosContent: macOSContent
    
    init(
        @ViewBuilder iOS: () -> iOSContent,
        @ViewBuilder macOS: () -> macOSContent
    ) {
        self.iosContent = iOS()
        self.macosContent = macOS()
    }
    
    var body: some View {
        Group {
            #if os(iOS)
            iosContent
            #elseif os(macOS)
            macosContent
            #endif
        }
    }
}

// MARK: - Device Specific Content
struct DeviceContent<PhoneContent: View, PadContent: View>: View {
    let phoneContent: PhoneContent
    let padContent: PadContent
    
    init(
        @ViewBuilder phone: () -> PhoneContent,
        @ViewBuilder pad: () -> PadContent
    ) {
        self.phoneContent = phone()
        self.padContent = pad()
    }
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .phone {
                phoneContent
            } else {
                padContent
            }
        }
    }
}

// MARK: - Size Class Content
struct SizeClassContent<CompactContent: View, RegularContent: View>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let compactContent: CompactContent
    let regularContent: RegularContent
    
    init(
        @ViewBuilder compact: () -> CompactContent,
        @ViewBuilder regular: () -> RegularContent
    ) {
        self.compactContent = compact()
        self.regularContent = regular()
    }
    
    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                compactContent
            } else {
                regularContent
            }
        }
    }
}

// MARK: - Authentication Content
struct AuthenticationContent<AuthenticatedContent: View, UnauthenticatedContent: View>: View {
    let isAuthenticated: Bool
    let authenticatedContent: AuthenticatedContent
    let unauthenticatedContent: UnauthenticatedContent
    
    init(
        isAuthenticated: Bool,
        @ViewBuilder authenticated: () -> AuthenticatedContent,
        @ViewBuilder unauthenticated: () -> UnauthenticatedContent
    ) {
        self.isAuthenticated = isAuthenticated
        self.authenticatedContent = authenticated()
        self.unauthenticatedContent = unauthenticated()
    }
    
    var body: some View {
        Group {
            if isAuthenticated {
                authenticatedContent
            } else {
                unauthenticatedContent
            }
        }
    }
}

// MARK: - Network Content
struct NetworkContent<OnlineContent: View, OfflineContent: View>: View {
    @State private var isOnline = true // In real app, use network monitoring
    
    let onlineContent: OnlineContent
    let offlineContent: OfflineContent
    
    init(
        @ViewBuilder online: () -> OnlineContent,
        @ViewBuilder offline: () -> OfflineContent
    ) {
        self.onlineContent = online()
        self.offlineContent = offline()
    }
    
    var body: some View {
        Group {
            if isOnline {
                onlineContent
            } else {
                offlineContent
            }
        }
    }
}

// MARK: - Business Type Content
struct BusinessTypeContent<ServicesContent: View, ProductsContent: View, BothContent: View>: View {
    let businessType: BusinessType
    let servicesContent: ServicesContent
    let productsContent: ProductsContent
    let bothContent: BothContent
    
    init(
        businessType: BusinessType,
        @ViewBuilder services: () -> ServicesContent,
        @ViewBuilder products: () -> ProductsContent,
        @ViewBuilder both: () -> BothContent
    ) {
        self.businessType = businessType
        self.servicesContent = services()
        self.productsContent = products()
        self.bothContent = both()
    }
    
    var body: some View {
        Group {
            switch businessType {
            case .services:
                servicesContent
            case .products:
                productsContent
            case .both:
                bothContent
            }
        }
    }
}

// MARK: - Permission Content
struct PermissionContent<GrantedContent: View, DeniedContent: View>: View {
    let isGranted: Bool
    let grantedContent: GrantedContent
    let deniedContent: DeniedContent
    
    init(
        isGranted: Bool,
        @ViewBuilder granted: () -> GrantedContent,
        @ViewBuilder denied: () -> DeniedContent
    ) {
        self.isGranted = isGranted
        self.grantedContent = granted()
        self.deniedContent = denied()
    }
    
    var body: some View {
        Group {
            if isGranted {
                grantedContent
            } else {
                deniedContent
            }
        }
    }
}

// MARK: - View Extensions
extension View {
    /// Conditionally show content
    func showIf(_ condition: Bool) -> some View {
        Group {
            if condition {
                self
            } else {
                EmptyView()
            }
        }
    }
    
    /// Hide content based on condition
    func hideIf(_ condition: Bool) -> some View {
        showIf(!condition)
    }
    
    /// Apply overlay conditionally
    func overlayIf<Overlay: View>(
        _ condition: Bool,
        @ViewBuilder overlay: () -> Overlay
    ) -> some View {
        Group {
            if condition {
                self.overlay(overlay())
            } else {
                self
            }
        }
    }
    
    /// Apply background conditionally
    func backgroundIf<Background: View>(
        _ condition: Bool,
        @ViewBuilder background: () -> Background
    ) -> some View {
        Group {
            if condition {
                self.background(background())
            } else {
                self
            }
        }
    }
    
    /// Apply animation conditionally
    func animateIf<V: Equatable>(
        _ condition: Bool,
        _ animation: Animation?,
        value: V
    ) -> some View {
        Group {
            if condition {
                self.animation(animation, value: value)
            } else {
                self
            }
        }
    }
}

// MARK: - Usage Examples in Comments
/*
 Usage Examples:
 
 1. Basic conditional content:
 ConditionalContent(isLoggedIn) {
     Text("Welcome back!")
 } ifFalse: {
     Text("Please log in")
 }
 
 2. Loading states:
 LoadingContent(isLoading: viewModel.isLoading) {
     List(items) { item in
         Text(item.name)
     }
 } loadingView: {
     ProgressView("Loading...")
 }
 
 3. Empty states:
 EmptyStateContent(isEmpty: items.isEmpty) {
     List(items) { item in
         Text(item.name)
     }
 } emptyView: {
     VStack {
         Image(systemName: "tray")
         Text("No items found")
     }
 }
 
 4. Error handling:
 ErrorContent(error: viewModel.error) {
     ContentView()
 } errorView: { error in
     Text("Error: \(error.localizedDescription)")
 }
 
 5. Device specific:
 DeviceContent {
     CompactPhoneView()
 } pad: {
     ExpandedPadView()
 }
 
 6. Business type specific:
 BusinessTypeContent(businessType: business.type) {
     ServicesView()
 } products: {
     ProductsView()
 } both: {
     CombinedView()
 }
 
 7. Simple conditional modifiers:
 Text("Hello")
     .showIf(shouldShow)
     .backgroundIf(isHighlighted) {
         Color.yellow
     }
 */