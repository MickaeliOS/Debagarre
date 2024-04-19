//
//  HomeTabViewModel.swift
//  Débagarre
//
//  Created by Mickaël Horn on 06/03/2024.
//

import Foundation
import FirebaseAuth

extension HomeTabView {

    @MainActor
    final class ViewModel: ObservableObject {
        @Published var user: User?
        @Published var userNickname: Nickname?
        @Published var showingAlert = false
        @Published var errorMessage = ""

        private var firestoreService: FirestoreServiceProtocol

        init(firestoreService: FirestoreServiceProtocol = FirestoreService()) {
            self.firestoreService = firestoreService
        }

        func fetchUser() async {
            do {
                user = try await firestoreService.fetchUser(userID: Auth.auth().currentUser?.uid ?? "")
            } catch let error as FirestoreService.FirestoreServiceError {
                handleError(with: error.errorDescription)
            } catch {
                handleError(with: "Something went wrong, please restart the app.")
            }
        }

        func fetchUserNickname() async {
            do {
                userNickname = try await firestoreService.fetchUserNickname(nicknameID: user?.nicknameID ?? "")
            } catch let error as FirestoreService.FirestoreServiceError {
                handleError(with: error.errorDescription)
            } catch {
                handleError(with: "Something went wrong, please restart the app.")
            }
        }

        private func handleError(with message: String) {
            showingAlert.toggle()
            errorMessage = message
        }
    }
}
