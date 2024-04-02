//
//  MockFirestoreService.swift
//  DébagarreTests
//
//  Created by Mickaël Horn on 06/03/2024.
//

import Foundation
@testable import Debagarre

final class MockFirestoreService: FirestoreServiceProtocol {
    var isSaveUserInDatabaseTriggered = false
    var error: Error?

    func saveUserInDatabase(userID: String, user: Debagarre.User) throws {
        isSaveUserInDatabaseTriggered = true

        if let error = error {
            throw error
        }
    }

    func fetchUser(userID: String) async throws -> Debagarre.User {
        // To delete, just to not generate a warning
        return User(email: "",
                    lastname: "",
                    firstname: "",
                    birthdate: Date.now,
                    gender: User.Gender.male.rawValue, 
                    profilePicture: "")
    }
}
