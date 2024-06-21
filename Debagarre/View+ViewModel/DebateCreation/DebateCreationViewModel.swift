//
//  DebateCreationViewModel.swift
//  Debagarre
//
//  Created by Mickaël Horn on 23/04/2024.
//

import Foundation

extension DebateCreationView {

    @MainActor
    final class ViewModel<Firestore: FirestoreServiceProtocol>: ObservableObject {
        @Published var pointOfView = ""
        @Published var themes = Debate.Theme.allCases.map { $0.description }
        @Published var selectedTheme = Debate.Theme.ecologie
        @Published var modes = Debate.Mode.allCases.map { $0.description }
        @Published var selectedMode = Debate.Mode.video
        @Published var debateRequest: Debate?
        @Published var showingAlert = false
        @Published var errorMessage = ""
        @Published var userID: String?

        private let firebaseAuthService: FirebaseAuthServiceProtocol
        private var firestoreService: Firestore

        init(firebaseAuthService: FirebaseAuthServiceProtocol = FirebaseAuthService(), 
             firestoreService: Firestore = FirestoreService()) {

            self.firebaseAuthService = firebaseAuthService
            self.firestoreService = firestoreService
        }

        func debateRequestCreationFlow() async {
            getUserID()

            guard let userID = userID else {
                errorMessage = "No user found, please restart the application."
                showingAlert = true
                return
            }

            buildDebateRequest(creatorID: userID)

            guard let debateRequest else {
                errorMessage = "An error occured during the debate creation, please try again."
                showingAlert = true
                return
            }

            createDebateRequest(debateRequest: debateRequest)

            await getDebateRequest()
        }

        private func createDebateRequest(debateRequest: Debate) {
            firestoreService.createDebateRequest(debateRequest: debateRequest) { result in
                switch result {
                case .success(let debateRequestID):
                    self.debateRequest?.id = debateRequestID
                case .failure(let error):
                    self.errorMessage = self.handleError(error: error)
                    self.showingAlert = true
                }
            }
        }

        private func getDebateRequest() async {
            guard let debateRequest,
                  let debateRequestID = debateRequest.id else {

                self.errorMessage = "An error occured during the debate creation, please try again."
                self.showingAlert = true
                return
            }

            do {
                self.debateRequest = try await firestoreService.getDebateRequest(debateRequestID: debateRequestID)
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
            }
        }

        private func buildDebateRequest(creatorID: String) {
            debateRequest = Debate(
                creatorID:  creatorID,
                creationTime: Date.now,
                theme: selectedTheme,
                mode: selectedMode,
                pointOfView: pointOfView,
                timeLimit: 30,
                status: .waiting,
                isCreatorReady: false,
                isChallengerReady: false
            )
        }

        private func getUserID() {
            do {
                userID = try firebaseAuthService.getUserID()

            } catch let error as FirebaseAuthService.FirebaseAuthServiceError {
                errorMessage = handleError(error: error)
                showingAlert = true
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
            }
        }

        private func handleError(error: Error) -> String {
            switch error {
            case let firestoreServiceError as FirestoreService.FirestoreServiceError:
                return firestoreServiceError.errorDescription
            case let firebaseAuthServiceError as FirebaseAuthService.FirebaseAuthServiceError:
                return firebaseAuthServiceError.errorDescription

            default:
                return "Something went wrong, please try again."
            }
        }
    }
}
