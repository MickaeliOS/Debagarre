//
//  PasswordResetView.swift
//  Debagarre
//
//  Created by Mickaël Horn on 15/04/2024.
//

import SwiftUI

struct PasswordResetView: View {
    @StateObject private var viewModel = PasswordResetView.ViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { proxy in
            Color.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .padding()
                    .background(.mainButton)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .font(.headline)
                }

                Text("Donne-nous ton email pour qu'on puisse t'envoyer un lien de réinitialisation de Mot de passe.")
                    .font(.headline)

                VStack {
                    TextField("Ton Email.", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .frame(height: proxy.size.height * 0.06)
                        .padding()
                        .padding(.leading, 30)
                        .background(.ultraThickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(Image(systemName: "envelope")
                            .foregroundColor(.gray)
                            .padding(.leading, 15), alignment: .leading)

                    HStack {
                        Text("Email envoyé!")
                            .font(.footnote)
                            .foregroundStyle(.green)
                            .isHidden(viewModel.isEmailSentMessageHidden)

                        Spacer()
                    }
                }

                if viewModel.isSendEmailButtonEnabled {
                    Button("Envoyer le mail") {
                        Task {
                            await viewModel.resetPassword()
                        }
                    }
                    .frame(width: proxy.frame(in: .local).midX)
                    .padding([.top, .bottom])
                    .background(.mainButton)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .font(.title2)
                    .shadow(radius: 10)
                } else {
                    ProgressView()
                        .controlSize(.large)
                }
            }
            .padding()
            .alert("Erreur", isPresented: $viewModel.showingAlert) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

#Preview {
    PasswordResetView()
}
