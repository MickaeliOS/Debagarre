//
//  PasswordResetView.swift
//  Debagarre
//
//  Created by Mickaël Horn on 15/04/2024.
//

import Foundation
import FirebaseAuth

extension PasswordResetView {

    @MainActor
    class ViewModel: ObservableObject {
        @Published var email = ""
        @Published var errorMessage = ""
        @Published var showingAlert = false
        @Published var isEmailSentMessageHidden = true
        @Published var isSendEmailButtonEnabled = true

        private let firebaseAuthService: FirebaseAuthServiceProtocol

        init(firebaseAuthService: FirebaseAuthServiceProtocol = FirebaseAuthService()) {
            self.firebaseAuthService = firebaseAuthService
        }
    }
}

extension PasswordResetView.ViewModel {
    func resetPassword() async {
        isSendEmailButtonEnabled = false

        guard AuthenticationTools.emailControl(email: email) else {
            errorMessage = AuthenticationTools.AuthenticationError.emailBadlyFormatted.errorDescription
            showingAlert = true
            isSendEmailButtonEnabled = true
            return
        }

        do {
            try await firebaseAuthService.resetPassword(for: email)
            isEmailSentMessageHidden = false
            isSendEmailButtonEnabled = true
        } catch {
            if let error = error as? FirebaseAuthService.FirebaseAuthServiceError {
                errorMessage = error.errorDescription
            } else {
                errorMessage = "Something went wrong, please retry."
            }

            showingAlert = true
            isSendEmailButtonEnabled = true
        }
    }
}
