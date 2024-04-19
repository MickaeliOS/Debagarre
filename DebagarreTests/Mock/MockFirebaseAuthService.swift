//
//  MockFirebaseAuthService.swift
//  DébagarreTests
//
//  Created by Mickaël Horn on 06/03/2024.
//

import Foundation
@testable import Debagarre

final class MockFirebaseAuthService: FirebaseAuthServiceProtocol {
    var isCreateUserTriggered = false
    var isSignInTriggered = false
    var isResetPasswordTriggered = false
    var error: Error?

    func createUser(email: String, password: String) async throws -> FirebaseAuthServiceProtocol.UserID {
        isCreateUserTriggered = true

        if let error = error {
            throw error
        }

        return "userID123"
    }

    func signIn(email: String, password: String) async throws {
        isSignInTriggered = true

        if let error = error {
            throw error
        }
    }

    func resetPassword(for email: String) async throws {
        isResetPasswordTriggered = true

        if let error = error {
            throw error
        }
    }
}
