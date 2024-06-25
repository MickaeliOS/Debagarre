//
//  FirebaseAuthManager.swift
//  Débagarre
//
//  Created by Mickaël Horn on 06/03/2024.
//

import Foundation
import FirebaseAuth

final class FirebaseAuthManager: ObservableObject {
    var authStateHandler: AuthStateDidChangeListenerHandle?

    @Published var state: State = .loading

    init() {
        registerAuthStateHandler()
    }
}

extension FirebaseAuthManager {
    enum State {
        case loading
        case loggedOut
        case loggedIn
    }
}

extension FirebaseAuthManager {
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
