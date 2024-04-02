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
        @Published var showingAlert = false
        @Published var errorMessage = ""

        private var firestoreService: FirestoreServiceProtocol

        init(firestoreService: FirestoreServiceProtocol = FirestoreService()) {
            self.firestoreService = firestoreService
        }

        func fetchUser(userID: String) {
            Task {
                do {
                    user = try await firestoreService.fetchUser(userID: userID)
                } catch let error as FirestoreService.FirestoreServiceError {
                    handleError(with: error.errorDescription)
                }
            }
        }

        private func handleError(with message: String) {
            showingAlert.toggle()
            errorMessage = message
        }
    }
}
