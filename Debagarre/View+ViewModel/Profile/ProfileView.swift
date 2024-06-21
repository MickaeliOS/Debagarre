//
//  ProfileView.swift
//  Debagarre
//
//  Created by Mickaël Horn on 01/04/2024.
//

import SwiftUI

struct ProfileView: View {
    @State private var isEditProfilePresented = false
    @EnvironmentObject var homeTabViewModel: HomeTabView.ViewModel<FirestoreService>

    var externalUser: User?
    var externalUserNickname: Nickname?
    let isExternalUserPresented: Bool

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                Color.background
                    .ignoresSafeArea()

                VStack {
                    let currentUser = isExternalUserPresented ? externalUser : homeTabViewModel.user
                    let currentUserNickname = isExternalUserPresented ? externalUserNickname : homeTabViewModel.userNickname

                    if let currentUser, let currentUserNickname {
                        profileHeaderView(geometry: geometry, user: currentUser)
                        debateCountView(user: currentUser)
                        userInfoView(user: currentUser, nickname: currentUserNickname)

                        Spacer()

                        if !isExternalUserPresented {
                            editProfileButton(user: currentUser)
                        }
                    } else {
                        Text("Erreur lors du chargement du profil, veuillez redémarrer l'application.")
                            .foregroundStyle(.red)
                    }
                }
            }
            .background(Color.background.ignoresSafeArea())
        }
    }

    @ViewBuilder
    private func profileHeaderView(geometry: GeometryProxy, user: User) -> some View {
        AsyncImage(url: URL(string: homeTabViewModel.user?.profilePicture ?? "")) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(height: geometry.size.height / 3)
                .clipped()
        } placeholder: {
            Color.gray
                .frame(height: geometry.size.height / 3)
        }
        .overlay(
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 150, height: 150)
                .scaledToFit()
                .background(Color.background)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.background, lineWidth: 6)
                )
                .offset(y: geometry.size.height / 6)
        )
        .edgesIgnoringSafeArea(.all)
    }

    @ViewBuilder
    private func debateCountView(user: User) -> some View {
        HStack {
            Image(systemName: "figure.boxing")
                .font(.system(size: 72))
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    .linearGradient(colors: [.blue, .red], startPoint: .top, endPoint: .bottomTrailing)
                )

            Text("\(user.numberOfDebate ?? 0) débat(s) réalisés.")
                .font(.title2)
        }
    }

    @ViewBuilder
    private func userInfoView(user: User, nickname: Nickname) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            profileInfoRows(user: user, nickname: nickname)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func editProfileButton(user: User) -> some View {
        Button(action: {
            isEditProfilePresented.toggle()
        }) {
            Text("Éditer le profil")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.mainElement)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .sheet(isPresented: $isEditProfilePresented) {
            NavigationView {
                EditProfileView()

            }
//            TestLagView()
        }
    }

    @ViewBuilder
    private func profileInfoRows(user: User, nickname: Nickname) -> some View {
        ProfileInfoRow(icon: "person.fill", title: "Pseudo", value: nickname.nickname)

        if !isExternalUserPresented {
            ProfileInfoRow(icon: "envelope.fill", title: "Email", value: user.email)
        }

        ProfileInfoRow(icon: "person.fill", title: "Genre", value: user.gender?.rawValue ?? "N/A")
        ProfileInfoRow(icon: "calendar", title: "Âge", value: "\(getUserAgeString(user: user)) ans")
    }

    private func getUserAgeString(user: User?) -> String {
        guard let user = user, let userAge = user.getAge() else {
            return "N/A"
        }

        return String(userAge)
    }
}

struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.mainElement)

            Text(title + ":")
                .font(.title2)
                .foregroundColor(.mainElement)

            Text(value)
                .font(.title2)
                .foregroundColor(.white)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    let homeTabViewModel = HomeTabView.ViewModel()
    homeTabViewModel.user = User.previewUser
    homeTabViewModel.userNickname = Nickname(nickname: "NicknameTest")

    return TabView {
        ProfileView(externalUser: nil, externalUserNickname: nil, isExternalUserPresented: false)
            .environmentObject(homeTabViewModel)
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
    }
}
