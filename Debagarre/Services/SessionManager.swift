//
//  SessionManager.swift
//  Débagarre
//
//  Created by Mickaël Horn on 06/03/2024.
//

import Foundation
import FirebaseAuth

final class SessionManager: ObservableObject {
    var authStateHandler: AuthStateDidChangeListenerHandle?

    @Published var state: State = .loading

    init() {
        registerAuthStateHandler()
    }
}

extension SessionManager {
    enum State {
        case loading
        case loggedOut
        case loggedIn
    }
}

extension SessionManager {
    private func registerAuthStateHandler() {
        authStateHandler = Auth.auth().addStateDidChangeListener { _, user in
            guard user != nil else {
                self.state = .loggedOut
                return
            }

            self.state = .loggedIn
        }
    }
}
