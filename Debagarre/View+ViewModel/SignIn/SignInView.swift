
 //
 //  SignInView.swift
 //  Débagarre
 //
 //  Created by Mickaël Horn on 06/03/2024.
 //

 import SwiftUI

 struct SignInView: View {
     @StateObject private var viewModel = ViewModel()

     var body: some View {
         Color(.background)
             .ignoresSafeArea()

         GeometryReader { proxy in
             VStack {
                 Image(.logoWithName)
                     .resizable()
                     .scaledToFit()
                     .frame(width: proxy.size.width)

                 TextField("Username", text: $viewModel.email)
                     .keyboardType(.emailAddress)
                     .textInputAutocapitalization(.never)
                     .frame(height: proxy.size.height * 0.06)
                     .padding()
                     .padding(.leading, 30)
                     .background(.ultraThickMaterial)
                     .clipShape(RoundedRectangle(cornerRadius: 10))
                     .overlay(Image(systemName: "envelope")
                         .foregroundColor(.gray)
                         .padding(.leading, 15),
                     alignment: .leading)

                 HStack {
                     SecureField("Password", text: $viewModel.password)
                         .frame(height: proxy.size.height * 0.06)
                         .padding()
                         .padding(.leading, 30)
                         .background(.ultraThickMaterial)
                         .clipShape(RoundedRectangle(cornerRadius: 10))
                         .overlay(Image(systemName: "lock.fill")
                             .foregroundColor(.gray)
                             .padding(.leading, 15),
                         alignment: .leading)
                 }

                 Spacer()

                 HStack {
                     Button("Login") {
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
                 }

                 Spacer()

                 HStack {
                     Text("Wanna fight? ")
                         .foregroundStyle(.white)

                     NavigationLink {
                         CreateAccountView()
                     } label: {
                         Text("Sign Up here 🥊")
                             .padding(5)
                             .foregroundStyle(.blue)
                             .background(.black)
                             .clipShape(RoundedRectangle(cornerRadius: 10))
                     }
                 }
             }
         }
         .padding()
         .alert("Login Error", isPresented: $viewModel.showingAlert) {
             Button("OK") { }
         } message: {
             Text(viewModel.errorMessage)
         }
     }
 }

 struct LoginView_Previews: PreviewProvider {
     static var previews: some View {
         SignInView()
     }
 }


