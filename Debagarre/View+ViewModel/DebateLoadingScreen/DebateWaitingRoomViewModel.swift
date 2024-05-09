//
//  DebateWaitingRoomViewModel.swift
//  Debagarre
//
//  Created by Mickaël Horn on 23/04/2024.
//

import Foundation

extension DebateWaitingRoomView {

    @MainActor
    class ViewModel: ObservableObject {
        @Published var newDebateRequestID = ""
        @Published var showingAlert = false
        @Published var errorMessage = ""
        @Published var shouldNavigateToDebateFightingView = false
        @Published var debateRequestCreator: User?
        @Published var debateRequestChallenger: User?
        @Published var debateRequestCreatorNickname: String?
        @Published var debateRequestChallengerNickname: String?
        @Published var showChallenger = true

        private var firestoreService: FirestoreServiceProtocol

        init(firestoreService: FirestoreServiceProtocol = FirestoreService()) {
            self.firestoreService = firestoreService
        }
    }
}

extension DebateWaitingRoomView.ViewModel {
    func setupCreatorAndChallenger(currentUser: User, currentUserNickname: Nickname, debateRequest: DebateRequest) async {
        if debateRequest.creatorID == currentUser.id {
            debateRequestCreator = currentUser
            debateRequestCreatorNickname = currentUserNickname.nickname

        } else if debateRequest.challengerID == currentUser.id {
            debateRequestChallenger = currentUser
            debateRequestChallengerNickname = currentUserNickname.nickname
            showChallenger = true

            do {
                debateRequestCreator = try await getUser(id: debateRequest.creatorID)
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
            }
        }
    }

    func getUser(id: String) async throws -> User {
        do {
            return try await firestoreService.fetchUser(userID: id)
        } catch {
            throw error
        }
    }

    func getUserAgeString(user: User?) -> String {
        guard let user = user,
              let userAge = user.getAge() else {
            
            return "N/A"
        }

        return String(userAge)
    }

    func updateDebateRequest(debateRequest: DebateRequest) async {
        do {
            try await firestoreService.updateDebateRequest(debateRequest: debateRequest)
        } catch {
            errorMessage = handleError(error: error)
            showingAlert = true
        }
    }

    func listenForDebateChanges(debateRequestID: String?) {
        guard let debateRequestID = debateRequestID else {
            errorMessage = "Something went wrong, please create a new debate."
            showingAlert = true
            return
        }

        firestoreService.listenForDebateChanges(debateRequestID: debateRequestID) { [weak self] result in
            switch result {
            case .success(let debate):
                if debate.isCreatorReady {
                    print("GG!")
                }

                guard debate.challengerID != nil, debate.isCreatorReady, debate.isChallengerReady else {
                    return
                }

                self?.shouldNavigateToDebateFightingView = true
            case .failure(let error):
                self?.errorMessage = self?.handleError(error: error) ?? ""
                self?.showingAlert = true
            }
        }
    }

    private func handleError(error: Error) -> String {
        switch error {
        case let firestoreServiceError as FirestoreService.FirestoreServiceError:
            return firestoreServiceError.errorDescription

        default:
            return "Something went wrong, please try again."
        }
    }
}
