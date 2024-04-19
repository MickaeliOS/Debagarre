//
//  ProfileView.swift
//  Debagarre
//
//  Created by Mickaël Horn on 01/04/2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var homeTabViewModel: HomeTabView.ViewModel

    var body: some View {
        GeometryReader { geometry in
            Color.background
                .ignoresSafeArea()

            VStack {
                Rectangle()
                    .fill(.gray)
                    .frame(height: geometry.size.height / 3)
//                    .clipped()
                    .overlay(
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .overlay(Circle().stroke(Color.background, lineWidth: 6))
                            .offset(y: geometry.size.height / 6)
                    )
                    .edgesIgnoringSafeArea(.all)

                HStack {
                    Spacer()

                    Button("Editer le profil") {
                        print("ok")
                    }
                    .padding()
                    .offset(y: -geometry.size.height / 12)

                }

                VStack {
//                    Text(homeTabViewModel.user?.firstname)
                }
                .padding()
                .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    ProfileView()
}
