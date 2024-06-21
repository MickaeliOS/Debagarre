//
//  HomeTabView.swift
//  Débagarre
//
//  Created by Mickaël Horn on 06/03/2024.
//

import SwiftUI
import FirebaseAuth

struct HomeTabView: View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
        TabView {
            // DEBATE CREATION

            VStack {
                DebateCreationView()

                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .padding([.bottom], 5)
            }

            .tabItem {
                Label("Débat", systemImage: "figure.boxing")
            }
            .environmentObject(viewModel)

            // PROFILE
            ProfileView(isExternalUserPresented: false)
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
                .environmentObject(viewModel)

            // SETTINGS
            VStack {
                Button { // DELETE
                    try? Auth.auth().signOut()
                } label: {
                    Text(viewModel.user?.email ?? "no mail")
                        .foregroundStyle(.blue)
                }
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }

            DebateResearchView()
                .tabItem {
                    Label("Recherche", systemImage: "magnifyingglass")
                }
                .environmentObject(viewModel)
        }
        .task {
            await viewModel.fetchUser()
            await viewModel.fetchUserNickname()
            await viewModel.fetchUserProfilePicture()
            await viewModel.fetchUserBannerImage()
            viewModel.listenForUserChanges()
        }
        .alert("Could not retrieve User", isPresented: $viewModel.showingAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

//struct TabView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeTabView()
//    }
//}
