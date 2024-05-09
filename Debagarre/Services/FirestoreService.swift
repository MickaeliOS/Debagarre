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
//    func getOldestWaitingDebate(mode: DebateRequest.Mode, theme: DebateRequest.Theme) async throws -> DebateRequest?
    func createDebateRequest(debateRequest: DebateRequest, completion: @escaping (Result<String, Error>) -> Void)
    func listenForDebateChanges(debateRequestID: String, updateHandler: @escaping (Result<DebateRequest, Error>) -> Void)
    func updateDebateRequest(debateRequest: DebateRequest) async throws
    func getDebateRequest(debateRequestID: String) async throws -> DebateRequest
}

final class FirestoreService: FirestoreServiceProtocol {
    private static let userTableName = "User"
    private static let nicknameTableName = "Nickname"
    private static let debateRequestTableName = "DebateRequest"

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
            let querySnapshot = try await Firestore.firestore()
                .collection(Self.nicknameTableName)
                .whereField("nickname", isEqualTo: nickname)
                .getDocuments()

            return !querySnapshot.documents.isEmpty

        } catch {
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

//    func getOldestWaitingDebate(mode: DebateRequest.Mode, theme: DebateRequest.Theme) async throws -> DebateRequest? {
//        let db = Firestore.firestore()
//
//        do {
//            let querySnapshot = try await db
//                .collection(Self.debateRequestName)
//                .whereField("mode", isEqualTo: mode.description)
//                .whereField("theme", isEqualTo: theme.description)
//                .whereField("status", isEqualTo: DebateRequest.Status.waiting.rawValue)
//                .whereField("challengerID", isEqualTo: "")
//                .order(by: "creationTime", descending: false)
//                .getDocuments()
//
//            if let document = querySnapshot.documents.first {
//                return try document.data(as: DebateRequest.self)
//            } else {
//                return nil
//            }
//
//        } catch {
//            throw FirestoreServiceError.fetchError
//        }
//    }

    func createDebateRequest(debateRequest: DebateRequest, completion: @escaping (Result<String, Error>) -> Void) {
        let db = Firestore.firestore()

        do {
            let result = try db.collection(Self.debateRequestTableName).addDocument(from: debateRequest)
            completion(.success(result.documentID))
        } catch let error {
            completion(.failure(error))
        }
    }

    func listenForDebateChanges(debateRequestID: String, updateHandler: @escaping (Result<DebateRequest, Error>) -> Void) {
        let db = Firestore.firestore()
        let debateRequestRef = db.collection(Self.debateRequestTableName).document(debateRequestID)

        debateRequestRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot,
                  let debate = try? document.data(as: DebateRequest.self) else {

                updateHandler(.failure(FirestoreServiceError.fetchError))
                return
            }

            updateHandler(.success(debate))
        }
    }

    func updateDebateRequest(debateRequest: DebateRequest) async throws {
        guard let debateRequestID = debateRequest.id else {
            throw FirestoreServiceError.couldNotJoinDebate
        }

        let db = Firestore.firestore()
        let debateRequestRef = db.collection(Self.debateRequestTableName).document(debateRequestID)

        do {
            try debateRequestRef.setData(from: debateRequest)
        } catch {
            throw FirestoreServiceError.couldNotJoinDebate
        }
    }

    func getDebateRequest(debateRequestID: String) async throws -> DebateRequest {
        do {
            let docRef = Firestore
                .firestore()
                .collection(Self.debateRequestTableName)
                .document(debateRequestID)

            return try await docRef.getDocument(as: DebateRequest.self)
        } catch {
            throw FirestoreServiceError.fetchError
        }
    }
}

extension FirestoreService {
    enum FirestoreServiceError: Error {
        case fetchError
        case cannotSaveUser
        case nicknameAlreadyUsed
        case cannotCreateDebate
        case couldNotJoinDebate

        var errorDescription: String {
            switch self {
            case .fetchError:
                return "An error occurred during fetching your informations. Please try to log in again."
            case .cannotSaveUser:
                return "User could not be saved."
            case .nicknameAlreadyUsed:
                return "Nickname already used, please chose a different one."
            case .cannotCreateDebate:
                return "We could not create your debate, please try again."
            case .couldNotJoinDebate:
                return "Sorry, we could not get you to the debate, please try again."
            }
        }
    }
}
