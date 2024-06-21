//
//  DebateRequestViewModel.swift
//  Debagarre
//
//  Created by Mickaël Horn on 13/05/2024.
//

import Foundation

extension DebateResearchView {

    @MainActor
    final class ViewModel<Firestore: FirestoreServiceProtocol>: ObservableObject {
        @Published var selectedTheme = Debate.Theme.ecologie
        @Published var debateRequestList: [(debate: Debate, user: User, nickname: Nickname)] = []
        @Published var showingAlert = false
        @Published var errorMessage = ""
        @Published var debateRequestCreator: User?

        private var firestoreService: Firestore

        init(firestoreService: Firestore = FirestoreService()) {
            self.firestoreService = firestoreService
        }

        func getDebateRequestListFlow() async {
            do {
                let debates = try await firestoreService.getDebateRequestList(theme: selectedTheme)
                var fetchedDebates: [(debate: Debate, user: User, nickname: Nickname)] = []

                for debate in debates {
                    let user = try await firestoreService.fetchUser(userID: debate.creatorID)
                    let nickname = try await firestoreService.fetchUserNickname(nicknameID: user.nicknameID)
                    fetchedDebates.append((debate: debate, user: user, nickname: nickname))
                }

                debateRequestList = fetchedDebates
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
            }
        }

        private func handleError(error: Error) -> String {
            switch error {
            case let firestoreServiceError as FirestoreService.FirestoreServiceError:
                return firestoreServiceError.errorDescription
            case let firestoreServiceError as FirebaseAuthService.FirebaseAuthServiceError:
                return firestoreServiceError.errorDescription

            default:
                return "Something went wrong, please try again."
            }
        }
    }
}
