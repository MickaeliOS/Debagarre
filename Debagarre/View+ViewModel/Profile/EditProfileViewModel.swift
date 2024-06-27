//
//  EditProfileViewModel.swift
//  Debagarre
//
//  Created by Mickaël Horn on 30/05/2024.
//

import Foundation

extension EditProfileView {

    @MainActor
    final class ViewModel: ObservableObject {
        @Published var showingAlert = false
        @Published var errorMessage = ""

        @Published var aboutMe: String = ""
        @Published var birthdate: Date = Date.now
        @Published var gender: User.Gender = .other

        @Published var bannerDidChange = false
        @Published var aboutMeDidChange = false
        @Published var genderDidChange = false

        // IMAGES
        @Published var birthdateDidChange = false
        @Published var profilePictureDidChange = false
        @Published var profilePictureData: Data?
        @Published var bannerImageData: Data?
        @Published var profilePicturePath: String?
        @Published var bannerPath: String?

        var isSaveButtonDisabled: Bool {
            return !(profilePictureDidChange || bannerDidChange || aboutMeDidChange || genderDidChange || birthdateDidChange)
        }

        private var firestoreService: FirestoreServiceProtocol
        private var storageService: StorageServiceProtocol

        init(firestoreService: FirestoreServiceProtocol = FirestoreService(),
             storageService: StorageServiceProtocol = StorageService()) {

            self.firestoreService = firestoreService
            self.storageService = storageService
        }

        func updateUserInfos(user: User?) -> User? {
            guard var userCopy = user else {
                errorMessage = "Error, no user detected, please restart the app."
                showingAlert = true
                return nil
            }

            aboutMeDidChange ? userCopy.aboutMe = aboutMe : ()
            genderDidChange ? userCopy.gender = gender : ()
            birthdateDidChange ? userCopy.birthdate = birthdate : ()

            do {
                try firestoreService.updateUser(user: userCopy)
                return userCopy
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
                return nil
            }
        }

        func updateProfilePictureFlow(user: User?) async -> ProfilePicture? {
            guard let profilePictureData else {
                errorMessage = "Error, no Profile Picture to be uploaded."
                showingAlert = true
                return nil
            }

            guard let userID = user?.id else {
                errorMessage = "Error, no user detected, please restart the app."
                showingAlert = true
                return nil
            }

            if let profilePictureID = user?.profilePictureID {
                return await updateProfilePicture(userID: userID, profilePictureID: profilePictureID, profilePictureData: profilePictureData)
            }

            return await createProfilePicture(userID: userID, profilePictureData: profilePictureData)
        }

        func updateBannerImageFlow(user: User?) async -> BannerImage? {
            guard let bannerImageData else {
                errorMessage = "Error, no Banner Image to be uploaded."
                showingAlert = true
                return nil
            }

            guard let userID = user?.id else {
                errorMessage = "Error, no user detected, please restart the app."
                showingAlert = true
                return nil
            }

            if let bannerImageID = user?.bannerImageID {
                return await updateBannerImage(userID: userID, bannerImageID: bannerImageID, bannerImageData: bannerImageData)
            }

            return await createBannerImage(userID: userID, bannerImageData: bannerImageData)
        }

        private func createProfilePicture(userID: String, profilePictureData: Data) async -> ProfilePicture? {
            do {
                let profilePicturePath = try await storageService.saveProfilePicture(data: profilePictureData, userID: userID)
                var profilePicture = ProfilePicture(path: profilePicturePath)
                let profilePictureID = try firestoreService.createProfilePicture(profilePicture: profilePicture)
                profilePicture.id = profilePictureID
                return profilePicture
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
                return nil
            }
        }

        private func createBannerImage(userID: String, bannerImageData: Data) async -> BannerImage? {
            do {
                let bannerImagePath = try await storageService.saveBannerImage(data: bannerImageData, userID: userID)
                var bannerImage = BannerImage(path: bannerImagePath)
                let bannerImageID = try firestoreService.createBannerImage(bannerImage: bannerImage)
                bannerImage.id = bannerImageID
                return bannerImage
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
                return nil
            }
        }

        private func updateProfilePicture(userID: String, profilePictureID: String, profilePictureData: Data) async -> ProfilePicture? {
            do {
                let profilePicturePath = try await storageService.saveProfilePicture(data: profilePictureData, userID: userID)
                let profilePicture = ProfilePicture(path: profilePicturePath)
                try firestoreService.updateProfilePicture(profilePicture: profilePicture, profilePictureID: profilePictureID)
                return profilePicture
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
                return nil
            }
        }

        private func updateBannerImage(userID: String, bannerImageID: String, bannerImageData: Data) async -> BannerImage? {
            do {
                let bannerImagePath = try await storageService.saveBannerImage(data: bannerImageData, userID: userID)
                let bannerImage = BannerImage(path: bannerImagePath)
                try firestoreService.updateBannerImage(bannerImage: bannerImage, bannerImageID: bannerImageID)
                return bannerImage
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
                return nil
            }
        }

        private func updateUserInFirestore(user: User) {
            do {
                try firestoreService.updateUser(user: user)
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
            }
        }

        func compareBirthdate(birthdate: Date?) {
            birthdateDidChange = self.birthdate != birthdate
        }

        func compareGender(gender: User.Gender?) {
            genderDidChange = self.gender != gender
        }

        func compareAboutMe(aboutMe: String?) {
            aboutMeDidChange = self.aboutMe != aboutMe
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
