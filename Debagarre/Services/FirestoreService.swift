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
    func fetchUserNickname(nicknameID: String) async throws -> Nickname
    func nicknameCheck(nickname: String) async throws -> Bool
    func saveNicknameInDatabase(nickname: Nickname, completion: @escaping (Result<String, Error>) -> Void)
}

final class FirestoreService: FirestoreServiceProtocol {
    private static let userTableName = "User"
    private static let nicknameTableName = "Nickname"

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
        guard !userID.isReallyEmpty else {
            throw FirestoreServiceError.fetchError
        }

        do {
            let docRef = Firestore.firestore()
                .collection(Self.userTableName)
                .document(userID)

            return try await docRef.getDocument(as: User.self)

        } catch {
            throw FirestoreServiceError.fetchError
        }
    }

    func fetchUserNickname(nicknameID: String) async throws -> Nickname {
        do {
            let docRef = Firestore.firestore().collection(
                Self.nicknameTableName
            ).document(
                nicknameID
            )

            return try await docRef.getDocument(as: Nickname.self)
        } catch {
            throw FirestoreServiceError.fetchError
        }
    }

    func nicknameCheck(nickname: String) async throws -> Bool {
        do {
            let docRef = Firestore.firestore()
                .collection(Self.nicknameTableName)
                .document(nickname)

            let result = try await docRef.getDocument()
            return result.exists

        } catch {
            print("MKA - L'erreur est : \(error)")
            throw FirestoreServiceError.fetchError
        }
    }

    func saveNicknameInDatabase(nickname: Nickname, completion: @escaping (Result<String, Error>) -> Void) {
        let db = Firestore.firestore()

        do {
            let result = try db.collection(Self.nicknameTableName).addDocument(from: nickname)
            completion(.success(result.documentID))
        } catch let error {
            completion(.failure(error))
        }
    }
}

extension FirestoreService {
    enum FirestoreServiceError: Error {
        case fetchError
        case cannotSaveUser
        case nicknameAlreadyUsed

        var errorDescription: String {
            switch self {
            case .fetchError:
                return "An error occurred during fetching your informations. Please try to log in again."
            case .cannotSaveUser:
                return "User could not be saved."
            case .nicknameAlreadyUsed:
                return "Nickname already used, please chose a different one."
            }
        }
    }
}
