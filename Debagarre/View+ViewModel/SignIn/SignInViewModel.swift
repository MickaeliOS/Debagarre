//
//  SignInViewModel.swift
//  Débagarre
//
//  Created by Mickaël Horn on 06/03/2024.
//

import Foundation
import FirebaseAuth

extension SignInView {

    @MainActor
    final class ViewModel: ObservableObject {
        @Published var email = ""
        @Published var password = ""
        @Published var errorMessage = ""
        @Published var showingAlert = false

        private let firebaseAuthService: FirebaseAuthServiceProtocol

        var hasEmptyField: Bool {
            return email.isReallyEmpty || password.isReallyEmpty
        }

        init(firebaseAuthService: FirebaseAuthServiceProtocol = FirebaseAuthService()) {
            self.firebaseAuthService = firebaseAuthService
        }
    }
}

extension SignInView.ViewModel {
    enum FormError: Error {
        case emptyField

        var errorDescription: String {
            switch self {
            case .emptyField:
                return "All fields must be filled."
            }
        }
    }
}

extension SignInView.ViewModel {
    func signIn() async {
        do {
            try formCheck()
            try await firebaseAuthService.signIn(email: email, password: password)
        } catch {
            showingAlert.toggle()
            errorMessage = handleError(error: error)
        }
    }

    private func formCheck() throws {
        guard !hasEmptyField else {
            throw FormError.emptyField
        }

        guard AuthenticationTools.emailControl(email: email) else {
            throw AuthenticationTools.AuthenticationError.emailBadlyFormatted
        }
    }

    private func handleError(error: Error) -> String {
        switch error {
        case let formError as FormError:
            return formError.errorDescription
        case let authenticationError as AuthenticationTools.AuthenticationError:
            return authenticationError.errorDescription
        case let authServiceError as FirebaseAuthService.FirebaseAuthServiceError:
            return authServiceError.errorDescription
        default:
            return "Something went wrong, please try again."
        }
    }
}
