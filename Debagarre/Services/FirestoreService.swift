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
    func createDebateRequest(debateRequest: Debate, completion: @escaping (Result<String, Error>) -> Void)
    func listenForDebateChanges(debateRequestID: String, updateHandler: @escaping (Result<Debate, Error>) -> Void)
    func listenForUserChange(userID: String, updateHandler: @escaping (Result<User, Error>) -> Void)
    func listenForProfilePictureChange(profilePictureID: String, updateHandler: @escaping (Result<ProfilePicture, Error>) -> Void)
    func listenForBannerImageChange(bannerImageID: String, updateHandler: @escaping (Result<BannerImage, Error>) -> Void)
    func updateDebateRequest(debateRequest: Debate) async throws
    func getDebateRequest(debateRequestID: String) async throws -> Debate
    func getDebateRequestList(theme: Debate.Theme) async throws -> [Debate]
    func updateUser(user: User) throws
    func getUserProfilePicture(profilePictureID: String) async throws -> ProfilePicture
    func getUserBannerImage(bannerImageID: String) async throws -> BannerImage
    func createProfilePicture(profilePicture: ProfilePicture) throws -> String
    func createBannerImage(bannerImage: BannerImage) throws -> String
    func updateProfilePicture(profilePicture: ProfilePicture, profilePictureID: String) throws
    func updateBannerImage(bannerImage: BannerImage, bannerImageID: String) throws
}

final class FirestoreService: FirestoreServiceProtocol {
    enum CollectionName: String {
        case userTableName = "User"
        case nicknameTableName = "Nickname"
        case debateRequestTableName = "Debate"
        case userProfilePictureTableName = "ProfilePicture"
        case userBannerImageTableName = "BannerImage"
    }

    func saveUserInDatabase(userID: String, user: User) throws {
        do {
            try Firestore.firestore().collection(CollectionName.userTableName.rawValue)
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
                .collection(CollectionName.userTableName.rawValue)
                .document(userID)

            return try await docRef.getDocument(as: User.self)

        } catch {
            throw FirestoreServiceError.fetchError
        }
    }

    func fetchUserNickname(nicknameID: String) async throws -> Nickname {
        do {
            let docRef = Firestore.firestore().collection(
                CollectionName.nicknameTableName.rawValue
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
                .collection(CollectionName.nicknameTableName.rawValue)
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
            let result = try db.collection(CollectionName.nicknameTableName.rawValue).addDocument(from: nickname)
            completion(.success(result.documentID))
        } catch let error {
            completion(.failure(error))
        }
    }

    func createDebateRequest(debateRequest: Debate, completion: @escaping (Result<String, Error>) -> Void) {
        let db = Firestore.firestore()

        do {
            let result = try db.collection(CollectionName.debateRequestTableName.rawValue).addDocument(from: debateRequest)
            completion(.success(result.documentID))
        } catch let error {
            completion(.failure(error))
        }
    }

    func listenForDebateChanges(debateRequestID: String, updateHandler: @escaping (Result<Debate, Error>) -> Void) {
        let db = Firestore.firestore()
        let debateRequestRef = db.collection(CollectionName.debateRequestTableName.rawValue).document(debateRequestID)

        debateRequestRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot,
                  let debate = try? document.data(as: Debate.self) else {

                updateHandler(.failure(FirestoreServiceError.fetchError))
                return
            }

            updateHandler(.success(debate))
        }
    }

    func listenForUserChange(userID: String, updateHandler: @escaping (Result<User, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection(CollectionName.userTableName.rawValue).document(userID)

        userRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot,
                  let user = try? document.data(as: User.self) else {

                updateHandler(.failure(FirestoreServiceError.fetchError))
                return
            }

            updateHandler(.success(user))
        }
    }

    func listenForProfilePictureChange(profilePictureID: String, updateHandler: @escaping (Result<ProfilePicture, Error>) -> Void) {
        let db = Firestore.firestore()
        let profilePictureRef = db.collection(CollectionName.userProfilePictureTableName.rawValue).document(profilePictureID)

        profilePictureRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot,
                  let profilePicture = try? document.data(as: ProfilePicture.self) else {

                updateHandler(.failure(FirestoreServiceError.fetchError))
                return
            }

            updateHandler(.success(profilePicture))
        }
    }

    func listenForBannerImageChange(bannerImageID: String, updateHandler: @escaping (Result<BannerImage, Error>) -> Void) {
        let db = Firestore.firestore()
        let bannerImageRef = db.collection(CollectionName.userBannerImageTableName.rawValue).document(bannerImageID)

        bannerImageRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot,
                  let bannerImage = try? document.data(as: BannerImage.self) else {

                updateHandler(.failure(FirestoreServiceError.fetchError))
                return
            }

            updateHandler(.success(bannerImage))
        }
    }

    func updateDebateRequest(debateRequest: Debate) async throws {
        guard let debateRequestID = debateRequest.id else {
            throw FirestoreServiceError.couldNotJoinDebate
        }

        let db = Firestore.firestore()
        let debateRequestRef = db.collection(CollectionName.debateRequestTableName.rawValue).document(debateRequestID)

        do {
            try debateRequestRef.setData(from: debateRequest)
        } catch {
            throw FirestoreServiceError.couldNotJoinDebate
        }
    }

    func getDebateRequest(debateRequestID: String) async throws -> Debate {
        do {
            let docRef = Firestore
                .firestore()
                .collection(CollectionName.debateRequestTableName.rawValue)
                .document(debateRequestID)

            return try await docRef.getDocument(as: Debate.self)
        } catch {
            throw FirestoreServiceError.fetchError
        }
    }

    func getDebateRequestList(theme: Debate.Theme) async throws -> [Debate] {
        var debateRequests: [Debate] = []

        do {
            let querySnapshot = try await Firestore
                .firestore()
                .collection(CollectionName.debateRequestTableName.rawValue)
                .whereField("theme", isEqualTo: theme.rawValue)
                .getDocuments()

            try querySnapshot.documents.forEach { document in
                let debateRequest = try document.data(as: Debate.self)
                debateRequests.append(debateRequest)
            }

            return debateRequests
        } catch {
            throw FirestoreServiceError.fetchError
        }
    }

    func updateUser(user: User) throws {
        guard let userID = user.id else {
            throw FirestoreServiceError.cannotSaveUser
        }

        let db = Firestore.firestore()
        let userRef = db.collection(CollectionName.userTableName.rawValue).document(userID)

        do {
            try userRef.setData(from: user, merge: true)
        } catch {
            throw FirestoreServiceError.cannotSaveUser
        }
    }

    func getUserProfilePicture(profilePictureID: String) async throws -> ProfilePicture {
        do {
            let docRef = Firestore.firestore().collection(
                CollectionName.userProfilePictureTableName.rawValue
            ).document(
                profilePictureID
            )

            return try await docRef.getDocument(as: ProfilePicture.self)
        } catch {
            throw FirestoreServiceError.fetchError
        }
    }

    func getUserBannerImage(bannerImageID: String) async throws -> BannerImage {
        do {
            let docRef = Firestore.firestore().collection(
                CollectionName.userBannerImageTableName.rawValue
            ).document(
                bannerImageID
            )

            return try await docRef.getDocument(as: BannerImage.self)
        } catch {
            throw FirestoreServiceError.fetchError
        }
    }

    func createProfilePicture(profilePicture: ProfilePicture) throws -> String {
        let db = Firestore.firestore()

        do {
            let docRef = try db.collection(CollectionName.userProfilePictureTableName.rawValue).addDocument(from: profilePicture.self)
            return docRef.documentID
        } catch {
            throw FirestoreServiceError.couldNotCreateDocument
        }
    }


    func createBannerImage(bannerImage: BannerImage) throws -> String {
        let db = Firestore.firestore()

        do {
            let docRef = try db.collection(CollectionName.userBannerImageTableName.rawValue).addDocument(from: bannerImage.self)
            return docRef.documentID
        } catch {
            throw FirestoreServiceError.couldNotCreateDocument
        }
    }

    func updateProfilePicture(profilePicture: ProfilePicture, profilePictureID: String) throws {
        let db = Firestore.firestore()

        do {
            try db.collection(CollectionName.userProfilePictureTableName.rawValue)
                .document(profilePictureID)
                .setData(from: profilePicture)
        } catch {
            throw FirestoreServiceError.couldNotUpdateProfilePicture
        }
    }

    func updateBannerImage(bannerImage: BannerImage, bannerImageID: String) throws {
        let db = Firestore.firestore()

        do {
            try db.collection(CollectionName.userProfilePictureTableName.rawValue)
                .document(bannerImageID)
                .setData(from: bannerImage)
        } catch {
            throw FirestoreServiceError.couldNotUpdateBannerImage
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
        case couldNotCreateDocument
        case couldNotUpdateProfilePicture
        case couldNotUpdateBannerImage

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
            case .couldNotCreateDocument:
                return "Error, your document could not be saved, please retry."
            case .couldNotUpdateProfilePicture:
                return "Error, your Profile Picture could not be saved."
            case .couldNotUpdateBannerImage:
                return "Error, your Banner image could not be saved."
            }
        }
    }
}
