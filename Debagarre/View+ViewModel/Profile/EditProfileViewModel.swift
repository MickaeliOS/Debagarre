//
//  EditProfileViewModel.swift
//  Debagarre
//
//  Created by Mickaël Horn on 30/05/2024.
//

import Foundation

extension EditProfileView {

    @MainActor
    final class ViewModel<Firestore: FirestoreServiceProtocol>: ObservableObject {
        @Published var showingAlert = false
        @Published var errorMessage = ""
        @Published var updateSucceeded = false
        @Published var aboutMe: String = ""
        @Published var birthdate: Date = Date.now
        @Published var gender: User.Gender = .other
        @Published var bannerDidChange = false
        @Published var profilePictureDidChange = false
        @Published var profilePictureData: Data?
        @Published var bannerData: Data?
        @Published var modifiedUser: User?
        @Published var userInfosDidChange = false
        @Published var profilePicturePath: String?
        @Published var bannerPath: String?

        var isSaveButtonDisabled: Bool {
            return !(profilePictureDidChange || bannerDidChange || userInfosDidChange)
        }

        private var firestoreService: Firestore
        private var storageService: StorageServiceProtocol

        init(firestoreService: Firestore = FirestoreService(),
             storageService: StorageServiceProtocol = StorageService()) {

            self.firestoreService = firestoreService
            self.storageService = storageService
        }

        func updateUserFlow(user: User?, profilePicture: User.ProfilePicture?, bannerImage: User.BannerImage?) async {
            guard var user, let userID = user.id else {
                errorMessage = "Error, no user detected, please restart the app."
                showingAlert = true
                return
            }

            await profilePictureDidChange ? updateProfilePicture(userID: userID) : ()
            await bannerDidChange ? updateBannerImage(userID: userID) : ()

            if userInfosDidChange {
                user.birthdate = birthdate
                user.gender = gender
                user.aboutMe = aboutMe
            }

            updateUserInFirestore(user: user)

            if !showingAlert { updateSucceeded = true }
        }

        private func updateUserInFirestore(user: User) {
            do {
                try firestoreService.updateUser(user: user)
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
            }
        }

        private func updateProfilePicture(userID: String) async {
            guard let profilePictureData else {
                return
            }

            do {
                profilePicturePath = try await storageService.saveProfilePicture(data: profilePictureData, userID: userID)
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
            }
        }

        private func updateBannerImage(userID: String) async {
            guard let bannerData else {
                return
            }

            do {
                bannerPath = try await storageService.saveBannerImage(data: bannerData, userID: userID)
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
            }
        }

        func compareBirthdate(birthdate: Date?) {
            userInfosDidChange = self.birthdate != birthdate
        }

        func compareGender(gender: User.Gender?) {
            userInfosDidChange = self.gender != gender
        }

        func compareAboutMe(aboutMe: String?) {
            userInfosDidChange = self.aboutMe != aboutMe
        }

        private func handleError(error: Error) -> String {
            switch error {
            case let firestoreServiceError as FirestoreService.FirestoreServiceError:
                return firestoreServiceError.errorDescription
            case let storageServiceError as StorageService.StorageServiceError:
                return storageServiceError.errorDescription
            default:
                return "Something went wrong, please try again."
            }
        }
    }
}
