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
            DebateCreationView()
                .tabItem {
                    Label("Débat", systemImage: "figure.boxing")
                }
                .environmentObject(viewModel)

            VStack {
                Button { // DELETE
                    try? Auth.auth().signOut()
                } label: {
                    Text(viewModel.user?.email ?? "no mail")
                        .foregroundStyle(.blue)
                }
            }
        }
        .onAppear {
            viewModel.fetchUser(userID: Auth.auth().currentUser?.uid ?? "")
        }
        .alert("Could not retrieve User", isPresented: $viewModel.showingAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
    }
}
