//
//  CreateAccountView.swift
//  Débagarre
//
//  Created by Mickaël Horn on 06/03/2024.
//

import SwiftUI
import FirebaseAuth

struct CreateAccountView: View {
    @StateObject var viewModel = ViewModel()
    @FocusState private var nicknameFocused: Bool
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool
    @FocusState private var confirmPasswordFocused: Bool

    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            VStack(alignment: .leading) {
                VStack(spacing: 15) {
                    accountInfos
                }
                .padding([.bottom])

                Text(viewModel.errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.red)

                Spacer()

                signUpButton
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Créer ton compte")
                        .foregroundStyle(.white)
                }
            }
        }
    }

    @ViewBuilder private var accountInfos: some View {
        VStack {
            HStack {
                TextField("Pseudo", text: $viewModel.nickname)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .padding(.leading, 30)
                    .background(.ultraThickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .submitLabel(.next)
                    .overlay(Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                        .padding(.leading, 15),
                    alignment: .leading)
                    .onSubmit {
                        nicknameFocused = true
                    }
                .focused($nicknameFocused)

                Button("Vérifier") {
                    Task {
                        await viewModel.checkNicknameAvailability()
                    }
                }
                .padding()
                .background(.mainButton)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 10)
                .font(.title3)
            }

            Text(viewModel.nicknameAvailability.description)
                .disabled(true)
                .foregroundStyle(
                    viewModel.nicknameAvailability == .available ? .green : .red
                )
        }

        HStack {
            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .padding()
                .padding(.leading, 30)
                .background(.ultraThickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .submitLabel(.next)
                .overlay(Image(systemName: "envelope")
                    .foregroundColor(.gray)
                    .padding(.leading, 15),
                alignment: .leading)
                .onSubmit {
                    passwordFocused = true
                }
                .focused($emailFocused)
        }

        PasswordView(fieldName: "Mot de passe", password: $viewModel.password)
            .padding()
            .background(.ultraThickMaterial)
            .submitLabel(.next)
            .focused($passwordFocused)
            .onSubmit {
                confirmPasswordFocused = true
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))


        PasswordView(fieldName: "Confirmer le Mot de passe", password: $viewModel.confirmPassword)
            .padding()
            .background(.ultraThickMaterial)
            .submitLabel(.done)
            .focused($confirmPasswordFocused)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var signUpButton: some View {
        Button("Entre dans l'arène !") {
            Task {
                await viewModel.createUser()

                if viewModel.userID.isReallyEmpty == false {
                    viewModel.saveNicknameInDatabase { result in
                        if result {
                            viewModel.saveUserInDatabase(userID: viewModel.userID)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .font(.title)
        .padding()
        .background(.mainButton)
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 10)
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateAccountView()
        }
    }
}
