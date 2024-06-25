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
        @Published var updateSucceeded = false
        @Published var aboutMe: String = ""
        @Published var birthdate: Date = Date.now
        @Published var gender: User.Gender = .other
        @Published var bannerDidChange = false
        @Published var profilePictureDidChange = false
        @Published var profilePictureData: Data?
        @Published var bannerData: Data?
        @Published var modifiedUser: User?
        @Published var aboutMeDidChange = false
        @Published var genderDidChange = false
        @Published var birthdateDidChange = false
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

        func updateProfilePictureV2(userID: String?) async -> String? {
            guard let profilePictureData else { return nil }

            guard let userID else {
                errorMessage = "Error, no user detected, please restart the app."
                showingAlert = true
                return nil
            }

            do {
                return try await storageService.saveProfilePicture(data: profilePictureData, userID: userID)
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
                return nil
            }
        }

        func updateBannerImageV2(userID: String?) async -> String? {
            guard let bannerData else { return nil }

            guard let userID else {
                errorMessage = "Error, no user detected, please restart the app."
                showingAlert = true
                return nil
            }

            do {
                return try await storageService.saveBannerImage(data: bannerData, userID: userID)
            } catch {
                errorMessage = handleError(error: error)
                showingAlert = true
                return nil
            }
        }

//        func updateUserFlow(user: User?, profilePicture: User.ProfilePicture?, bannerImage: User.BannerImage?) async {
//
//            guard var newUser = user, let userID = newUser.id else {
//                errorMessage = "Error, no user detected, please restart the app."
//                showingAlert = true
//                return
//            }
//
//            if profilePictureDidChange {
//                await updateProfilePicture(userID: userID)
//                profilePicture?.path = profilePicturePath ?? ""
//                profilePictureData = self.profilePictureData
//            }
//
//            if bannerDidChange {
//                await updateBannerImage(userID: userID)
//                banner?.path = bannerPath ?? ""
//                bannerData = self.bannerData
//            }
//
//            aboutMeDidChange ? newUser.aboutMe = aboutMe : ()
//            genderDidChange ? newUser.gender = gender : ()
//            birthdateDidChange ? newUser.birthdate = birthdate : ()
//
//
//            if userInfosDidChange {
//                user.birthdate = birthdate
//                user.gender = gender
//                user.aboutMe = aboutMe
//            }
//
//            updateUserInFirestore(user: user)
//
//            if !showingAlert { updateSucceeded = true }
//
////            guard var newUser = user, let userID = newUser.id else {
////                errorMessage = "Error, no user detected, please restart the app."
////                showingAlert = true
////                return
////            }
////
////            if profilePictureDidChange {
////                await updateProfilePicture(userID: userID)
////                profilePicture?.path = profilePicturePath ?? ""
////                profilePictureData = self.profilePictureData
////            }
////
////            if bannerDidChange {
////                await updateBannerImage(userID: userID)
////                banner?.path = bannerPath ?? ""
////                bannerData = self.bannerData
////            }
////
////            aboutMeDidChange ? newUser.aboutMe = aboutMe : ()
////            genderDidChange ? newUser.gender = gender : ()
////            birthdateDidChange ? newUser.birthdate = birthdate : ()
////
////            if updateUserInFirestore(user: newUser) {
////                user = newUser
////            }
////
////            if !showingAlert { updateSucceeded = true }
//        }

//        private func updateUserInFirestore(user: User) {
//            do {
//                try firestoreService.updateUser(user: user)
//            } catch {
//                errorMessage = handleError(error: error)
//                showingAlert = true
//            }
//        }

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
