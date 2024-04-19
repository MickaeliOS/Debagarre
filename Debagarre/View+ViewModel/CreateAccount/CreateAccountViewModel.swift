//
//  CreateAccountViewModel.swift
//  Débagarre
//
//  Created by Mickaël Horn on 06/03/2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

extension CreateAccountView {

    @MainActor
    final class ViewModel: ObservableObject {
        @Published var nickname = ""
        @Published var email = ""
        @Published var password = ""
        @Published var confirmPassword = ""
        @Published var showingError = false
        @Published var errorMessage = ""
        @Published var nicknameAvailability = NicknameAvailability.unknown

        var userID = ""
        var nicknameID = ""
        private let firebaseAuthService: FirebaseAuthServiceProtocol
        private var firestoreService: FirestoreServiceProtocol

        var hasEmptyField: Bool {
            return email.isReallyEmpty
            || password.isReallyEmpty
            || confirmPassword.isReallyEmpty
            || nickname.isReallyEmpty
        }

        init(firebaseAuthService: FirebaseAuthServiceProtocol = FirebaseAuthService(),
             firestoreService: FirestoreServiceProtocol = FirestoreService()) {
            self.firebaseAuthService = firebaseAuthService
            self.firestoreService = firestoreService
        }
    }
}

extension CreateAccountView.ViewModel {
    enum FormError: Error {
        case emptyFields
        case passwordsNotEquals

        var errorDescription: String {
            switch self {
            case .emptyFields:
                return "All fields must be filled."
            case .passwordsNotEquals:
                return "Passwords must be equals."
            }
        }
    }

    enum NicknameAvailability {
        case available, unavailable, unknown

        var description: String {
            switch self {
            case .available:
                return "Le pseudo est disponible !"
            case .unavailable:
                return "Le pseudo n'est pas disponible."
            case .unknown:
                return ""
            }
        }
    }
}

extension CreateAccountView.ViewModel {
    func createUser() async {
        do {
            try formCheck()
            userID = try await firebaseAuthService.createUser(email: email, password: password)
        } catch {
            showingError.toggle()
            errorMessage = handleError(error: error)
        }
    }

    func saveUserInDatabase(userID: String) {
        do {
            let user = User(nicknameID: nicknameID, email: email)
            try firestoreService.saveUserInDatabase(userID: userID, user: user)
        } catch {
            showingError.toggle()
            errorMessage = handleError(error: error)
        }
    }

    func saveNicknameInDatabase(completion: @escaping (Bool) -> Void) {
        let nickname = Nickname(nickname: nickname)

        firestoreService.saveNicknameInDatabase(nickname: nickname) { result in
            switch result {
            case .success(let nicknameID):
                self.nicknameID = nicknameID
                completion(true)
            case .failure(let error):
                self.showingError.toggle()
                self.errorMessage = self.handleError(error: error)
                completion(false)
            }
        }
    }

    func checkNicknameAvailability() async {
        do {
            let isNicknameUsed = try await firestoreService.nicknameCheck(nickname: nickname)

            if isNicknameUsed {
                nicknameAvailability = .unavailable
            } else {
                nicknameAvailability = .available
            }

        } catch {
            showingError.toggle()
            errorMessage = handleError(error: error)
        }
    }

    private func formCheck() throws {
        guard !hasEmptyField else {
            throw FormError.emptyFields
        }

        guard AuthenticationTools.emailControl(email: email) else {
            throw AuthenticationTools.AuthenticationError.emailBadlyFormatted
        }

        guard AuthenticationTools.isValidPassword(password) else {
            throw AuthenticationTools.AuthenticationError.weakPassword
        }

        guard passwordEqualityCheck(password: password, confirmPassword: confirmPassword) else {
            throw FormError.passwordsNotEquals
        }
    }

    private func passwordEqualityCheck(password: String, confirmPassword: String) -> Bool {
        return password == confirmPassword
    }

    private func handleError(error: Error) -> String {
        switch error {
        case let formError as FormError:
            return formError.errorDescription

        case let authenticationError as AuthenticationTools.AuthenticationError:
            return authenticationError.errorDescription

        case let authErrorCode as FirebaseAuthService.FirebaseAuthServiceError:
            return authErrorCode.errorDescription

        case let firestoreServiceError as FirestoreService.FirestoreServiceError:
            return firestoreServiceError.errorDescription

        default:
            return "Something went wrong, please try again."
        }
    }
}
