//
//  ErrorExtension.swift
//  Debagarre
//
//  Created by Mickaël Horn on 25/06/2024.
//

import Foundation

extension Error {
    func handleError() -> String {
        switch self {
        case let firestoreServiceError as FirestoreService.FirestoreServiceError:
            return firestoreServiceError.errorDescription
        case let firebaseAuthServiceError as FirebaseAuthService.FirebaseAuthServiceError:
            return firebaseAuthServiceError.errorDescription
        case let storageServiceError as StorageService.StorageServiceError:
            return storageServiceError.errorDescription

        default:
            return "Something went wrong, please try again."
        }
    }
}
