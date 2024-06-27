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
        @Published var profilePicture: ProfilePicture?
        @Published var bannerImage: BannerImage?
        @Published var profilePictureData: Data?
        @Published var bannerImageData: Data?
        @Published var showingAlert = false
        @Published var errorMessage = ""

        private var firestoreService: FirestoreServiceProtocol
        private var storageService: StorageServiceProtocol

        init(firestoreService: FirestoreServiceProtocol = FirestoreService(),
             storageService: StorageServiceProtocol = StorageService()) {
            self.firestoreService = firestoreService
            self.storageService = storageService
        }

        func fetchUser() async {
            do {
                user = try await firestoreService.fetchUser(userID: Auth.auth().currentUser?.uid ?? "")
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
            }
        }

        func fetchUserNickname() async {
            guard let nicknameID = user?.nicknameID else {
                errorMessage = "Cannot get your nickname, please restart the app."
                showingAlert = true
                return
            }

            do {
                userNickname = try await firestoreService.fetchUserNickname(nicknameID: nicknameID)
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
            }
        }

        func fetchUserProfilePicture() async {
            guard let profilePictureID = user?.profilePictureID else {
                return
            }

            do {
                profilePicture = try await firestoreService.getUserProfilePicture(profilePictureID: profilePictureID)
            } catch {
                self.errorMessage = self.handleError(error: error)
                self.showingAlert = true
                return
            }

            guard let profilePicture else { return }

            storageService.fetchFromStorage(stringPath: profilePicture.path) { result in
                switch result {
                case .success(let profilePictureData):
                    self.profilePictureData = profilePictureData
                case .failure(let error):
                    self.errorMessage = self.handleError(error: error)
                    self.showingAlert = true
                }
            }
        }

        func fetchUserBannerImage() async {
            guard let bannerImageID = user?.bannerImageID else {
                return
            }

            do {
                bannerImage = try await firestoreService.getUserBannerImage(bannerImageID: bannerImageID)
            } catch {
                self.errorMessage = self.handleError(error: error)
                self.showingAlert = true
                return
            }

            guard let bannerImage else { return }

            storageService.fetchFromStorage(stringPath: bannerImage.path) { result in
                switch result {
                case .success(let bannerImageData):
                    self.bannerImageData = bannerImageData
                case .failure(let error):
                    self.errorMessage = self.handleError(error: error)
                    self.showingAlert = true
                }
            }
        }

//        func listenForUserChanges() {
//            guard let userID = user?.id else { return }
//
//            firestoreService.listenForUserChange(userID: userID) { result in
//                switch result {
//                case .success(let user):
//                    self.user = user
//                case .failure(let error):
//                    self.errorMessage = self.handleError(error: error)
//                    self.showingAlert = true
//                }
//            }
//        }

//        func listenForProfilePictureChange() {
//            guard let profilePictureID = profilePicture?.id else { return }
//
//            firestoreService.listenForProfilePictureChange(profilePictureID: profilePictureID) { result in
//                switch result {
//                case .success(let profilePicture):
//                    self.profilePicture = profilePicture
//
//                    Task {
//                        await self.fetchUserProfilePicture()
//                    }
//                case .failure(let error):
//                    self.errorMessage = self.handleError(error: error)
//                    self.showingAlert = true
//                }
//            }
//        }
//
//        func listenForBannerImageChange() {
//            guard let bannerImageID = bannerImage?.id else { return }
//
//            firestoreService.listenForBannerImageChange(bannerImageID: bannerImageID) { result in
//                switch result {
//                case .success(let bannerImage):
//                    self.bannerImage = bannerImage
//
//                    Task {
//                        await self.fetchUserBannerImage()
//                    }
//                case .failure(let error):
//                    self.errorMessage = self.handleError(error: error)
//                    self.showingAlert = true
//                }
//            }
//        }

        private func handleError(error: Error) -> String {
            switch error {
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
}
