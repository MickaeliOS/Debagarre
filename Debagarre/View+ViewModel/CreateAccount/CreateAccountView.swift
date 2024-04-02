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
                    Text("Create your account")
                        .foregroundStyle(.white)
                }
            }
        }
    }

    @ViewBuilder private var accountInfos: some View {
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

        PasswordView(fieldName: "Password", password: $viewModel.password)
            .padding()
            .background(.ultraThickMaterial)
            .submitLabel(.next)
            .focused($passwordFocused)
            .onSubmit {
                confirmPasswordFocused = true
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))


        PasswordView(fieldName: "Confirm Password", password: $viewModel.confirmPassword)
            .padding()
            .background(.ultraThickMaterial)
            .submitLabel(.done)
            .focused($confirmPasswordFocused)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var signUpButton: some View {
        Button("Sign me up!") {
            Task {
                await viewModel.createUser()

                if viewModel.userID.isReallyEmpty == false {
                    viewModel.saveUserInDatabase(userID: viewModel.userID)
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
        NavigationView {
            CreateAccountView()
        }
    }
}
