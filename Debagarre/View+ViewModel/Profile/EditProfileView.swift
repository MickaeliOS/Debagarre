//
//  EditProfileView.swift
//  Debagarre
//
//  Created by Mickaël Horn on 17/05/2024.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var homeTabViewModel: HomeTabView.ViewModel
    @StateObject private var viewModel = EditProfileView.ViewModel()

    // Profile Picture
    @State private var profilePictureItem: PhotosPickerItem?
    @State var profilePictureImage: Image?

    // Banner
    @State private var bannerItem: PhotosPickerItem?
    @State var bannerImage: Image?

    @State private var opttest: String?

    var body: some View {
        VStack {

            TextField("iej", text: $opttest ?? "")
            Form {
                Section("Informations") {
                    TextField("About me.", text: $viewModel.aboutMe)

                    DatePicker("Birthday", selection: $viewModel.birthdate, displayedComponents: .date)

                    Picker("Gender", selection: $viewModel.gender) {
                        ForEach(User.Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue)
                        }
                    }
                }

                Section("Photo de profil") {
                    PhotosPicker("Changer la photo de profil", selection: $profilePictureItem, matching: .images)
                    profilePictureImageView()
                }

                Section("Bannière") {
                    PhotosPicker("Changer la bannière", selection: $bannerItem, matching: .images)
                    bannerImageView()
                }
            }
            .onChange(of: profilePictureItem) {
                viewModel.profilePictureDidChange = true

                Task {
                    if let profilePictureData = try? await profilePictureItem?.loadTransferable(type: Data.self),
                       let profilePictureImage = UIImage(data: profilePictureData) {

                        self.profilePictureImage = Image(uiImage: profilePictureImage)
                        viewModel.profilePictureData = profilePictureData
                    } else {
                        viewModel.showingAlert = true
                        viewModel.errorMessage = "Please pick another image."
                    }
                }
            }
            .onChange(of: bannerItem) {
                viewModel.bannerDidChange = true

                Task {
                    if let bannerData = try? await bannerItem?.loadTransferable(type: Data.self),
                       let bannerImage = UIImage(data: bannerData) {

                        self.bannerImage = Image(uiImage: bannerImage)
                        viewModel.bannerData = bannerData
                    } else {
                        viewModel.showingAlert = true
                        viewModel.errorMessage = "Please pick another image."
                    }
                }
            }
        }
        .onChange(of: viewModel.aboutMe) {
            viewModel.compareAboutMe(aboutMe: homeTabViewModel.user?.aboutMe)
        }
        .onChange(of: viewModel.birthdate) {
            viewModel.compareBirthdate(birthdate: homeTabViewModel.user?.birthdate)

        }
        .onChange(of: viewModel.gender) {
            viewModel.compareGender(gender: homeTabViewModel.user?.gender)
        }
        .toolbar {
            Button {
                Task {
                    if viewModel.aboutMeDidChange || viewModel.genderDidChange || viewModel.birthdateDidChange {

                        guard let user = viewModel.updateUserInfos(user: homeTabViewModel.user) else { return }

                        homeTabViewModel.user = user
                    }

                    if viewModel.profilePictureDidChange {
                        guard let profilePicturePath = await viewModel.updateProfilePictureV2(userID: homeTabViewModel.user?.id) else {
                            return
                        }
                        homeTabViewModel.profilePicture?.path = profilePicturePath
                        homeTabViewModel.profilePictureData = viewModel.profilePictureData
                    }

                    if viewModel.bannerDidChange {
                        guard let bannerImagePath = await viewModel.updateBannerImageV2(userID: homeTabViewModel.user?.id) else {
                            return
                        }
                        homeTabViewModel.bannerImage?.path = bannerImagePath
                        homeTabViewModel.bannerImageData = viewModel.bannerData
                    }

                    if viewModel.updateSucceeded {
                        dismiss()
                    }
                }
            } label: {
                Text("Sauvegarder")
            }
            .disabled(viewModel.isSaveButtonDisabled)
        }
        .onAppear {
            viewModel.aboutMe = homeTabViewModel.user?.aboutMe ?? ""
            viewModel.birthdate = homeTabViewModel.user?.birthdate ?? Date.now
            viewModel.gender = homeTabViewModel.user?.gender ?? User.Gender.other
            setupOriginalProfilePictureImage()
            setupOriginalBannerImage()
        }
        .alert("Error", isPresented: $viewModel.showingAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .navigationTitle("Modifier le profil")
    }
}

extension EditProfileView {
    private func setupOriginalProfilePictureImage() {
        if let profilePictureData = homeTabViewModel.profilePictureData,
           let uiImage = UIImage(data: profilePictureData) {
            profilePictureImage = Image(uiImage: uiImage)
        } else {
            profilePictureImage = Image(systemName: "photo")
        }
    }

    private func setupOriginalBannerImage() {
        if let bannerImageData = homeTabViewModel.bannerImageData,
           let uiImage = UIImage(data: bannerImageData) {
            bannerImage = Image(uiImage: uiImage)
        } else {
            bannerImage = Image(systemName: "photo")
        }
    }

    @ViewBuilder
    private func profilePictureImageView() -> some View {
        profilePictureImage?
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(width: 200, height: 200)
    }

    @ViewBuilder
    private func bannerImageView() -> some View {
        bannerImage?
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(width: 200, height: 200)
    }
}

#Preview {
    NavigationStack {
        EditProfileView()
            .environmentObject(HomeTabView.ViewModel())
    }
}

public extension Binding {
    /// Create a non-optional version of an optional `Binding` with a default value
    /// - Parameters:
    ///   - lhs: The original `Binding<Value?>` (binding to an optional value)
    ///   - rhs: The default value if the original `wrappedValue` is `nil`
    /// - Returns: The `Binding<Value>` (where `Value` is non-optional)
    static func ??(lhs: Binding<Optional<Value>>, rhs: Value) -> Binding<Value> {
        Binding {
            lhs.wrappedValue ?? rhs
        } set: {
            lhs.wrappedValue = $0
        }
    }
}
