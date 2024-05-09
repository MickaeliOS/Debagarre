
 //
 //  SignInView.swift
 //  Débagarre
 //
 //  Created by Mickaël Horn on 06/03/2024.
 //

 import SwiftUI

 struct SignInView: View {
     @StateObject private var viewModel = ViewModel()
     @State private var showingResetPasswordView = false

     var body: some View {
         NavigationStack {
             GeometryReader { proxy in
                 Color(.background)
                     .ignoresSafeArea()
                 
                 VStack {
                     Image(.testLogo)
                         .resizable()
                         .scaledToFit()
                         .frame(width: proxy.size.width)

                     VStack {
                         TextField("Email", text: $viewModel.email)
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
                             SecureField("Mot de passe", text: $viewModel.password)
                                 .frame(height: proxy.size.height * 0.06)
                                 .padding()
                                 .padding(.leading, 30)
                                 .background(.ultraThickMaterial)
                                 .clipShape(RoundedRectangle(cornerRadius: 10))
                                 .overlay(Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 15), alignment: .leading)
                         }

                         HStack {
                             Spacer()

                             Button {
                                 showingResetPasswordView = true
                             } label: {
                                 Text("Mot de passe oublié ?")
                                     .font(.headline)
                             }
                             .sheet(isPresented: $showingResetPasswordView) {
                                 PasswordResetView()
                             }
                         }
                     }
                     .padding()

                     Spacer()

                     HStack {
                         if viewModel.isLoginButtonEnabled {
                             Button("Se connecter") {
                                 Task {
                                     await viewModel.signIn()
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

                     Spacer()

                     HStack {
                         Text("Prêt à débattre ?")
                             .foregroundStyle(.white)

                         NavigationLink {
                             CreateAccountView()
                         } label: {
                             Text("Par ici ! 🥊")
                                 .font(.headline)
                                 .padding(5)
                                 .foregroundStyle(.blue)
                                 .background(.black)
                                 .clipShape(RoundedRectangle(cornerRadius: 10))
                         }
                     }
                 }
             }
             .alert("Erreur de Connexion", isPresented: $viewModel.showingAlert) {
                 Button("OK") { }
             } message: {
                 Text(viewModel.errorMessage)
             }
         }
     }
 }

 struct LoginView_Previews: PreviewProvider {
     static var previews: some View {
         SignInView()
     }
 }


