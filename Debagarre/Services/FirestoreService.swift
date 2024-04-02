//
//  FirestoreService.swift
//  Débagarre
//
//  Created by Mickaël Horn on 06/03/2024.
//

import Foundation
import FirebaseFirestore

protocol FirestoreServiceProtocol {
    func saveUserInDatabase(userID: String, user: User) throws
    func fetchUser(userID: String) async throws -> User
}

final class FirestoreService: FirestoreServiceProtocol {
    private static let userTableName = "User"

    func saveUserInDatabase(userID: String, user: User) throws {
        do {
            try Firestore.firestore().collection(Self.userTableName)
                .document(userID)
                .setData(from: user)
        } catch {
            throw FirestoreServiceError.cannotSaveUser
        }
    }

    func fetchUser(userID: String) async throws -> User {
        do {
            let docRef = Firestore.firestore()
                .collection(Self.userTableName)
                .document(userID)

            return try await docRef.getDocument(as: User.self)

        } catch {
            throw FirestoreServiceError.fetchError
        }
    }
}

extension FirestoreService {
    enum FirestoreServiceError: Error {
        case fetchError
        case cannotSaveUser

        var errorDescription: String {
            switch self {
            case .fetchError:
                return "An error occurred during fetching your informations. Please try to log in again."
            case .cannotSaveUser:
                return "User could not be saved."
            }
        }
    }
}
