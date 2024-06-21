//
//  StorageService.swift
//  Debagarre
//
//  Created by Mickaël Horn on 28/05/2024.
//

import Foundation
import FirebaseStorage

protocol StorageServiceProtocol {
    func saveProfilePicture(data: Data, userID: String) async throws -> String
    func saveBannerImage(data: Data, userID: String) async throws -> String
    func fetchFromStorage(stringPath: String, completion: @escaping (Result<Data, Error>) -> Void)
}

final class StorageService: StorageServiceProtocol {
    static let userFolder = "User"
    static let profilePictureName = "ProfilePicture"
    static let bannerName = "Banner"
    static let maxSize = 10485760

    func saveProfilePicture(data: Data, userID: String) async throws -> String {
        let storage = Storage.storage()

        let result: (path: String, storageRef: StorageReference) = {
            let path = "/\(Self.userFolder)/\(userID)/\(Self.profilePictureName)"
            let storageRef = storage.reference(withPath: path)
            return (path, storageRef)
        }()

        do {
            let metadata = try await result.storageRef.putDataAsync(data)
            return metadata.path ?? result.path
        } catch {
            throw StorageServiceError.cannotPutData
        }
    }

    func saveBannerImage(data: Data, userID: String) async throws -> String {
        let storage = Storage.storage()

        let result: (path: String, storageRef: StorageReference) = {
            let path = "/\(Self.userFolder)/\(userID)/\(Self.bannerName)"
            let storageRef = storage.reference(withPath: path)
            return (path, storageRef)
        }()

        do {
            let metadata = try await result.storageRef.putDataAsync(data)
            return metadata.path ?? result.path
        } catch {
            throw StorageServiceError.cannotPutData
        }
    }

    func fetchFromStorage(stringPath: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference(withPath: stringPath)

        storageRef.getData(maxSize: Int64(Self.maxSize)) { result in
            switch result {
            case .success(let data):
                completion(.success(data))

            case .failure:
                completion(.failure(StorageServiceError.loadingDataError))
            }
        }
    }
}

extension StorageService {
    enum StorageServiceError: Error {
        case loadingDataError
        case cannotPutData
        case userError

        var errorDescription: String {
            switch self {
            case .loadingDataError:
                return "An error occurred during fetching your data. Please try to log in again."
            case .cannotPutData:
                return "Cannot save your data, please try again."
            case .userError:
                return "A problem occured with the user, please restart the application."
            }
        }
    }
}
