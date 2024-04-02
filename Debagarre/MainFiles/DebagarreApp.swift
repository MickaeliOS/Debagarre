//
//  DebagarreApp.swift
//  Debagarre
//
//  Created by Mickaël Horn on 06/03/2024.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct YourApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var sessionManager = SessionManager()
    @State private var showLogin = false

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ZStack {
                    switch sessionManager.state {
                    case .loading:
                        DebagarreSplashScreenView()
                        
                    case .loggedOut:
                        SignInView()
                            .transition(.move(edge: .trailing))

                    case .loggedIn:
                        HomeTabView()
                            .transition(.move(edge: .leading))
                    }
                }
                .animation(.easeInOut(duration: 0.5), value: sessionManager.state)
            }
        }
    }
}
