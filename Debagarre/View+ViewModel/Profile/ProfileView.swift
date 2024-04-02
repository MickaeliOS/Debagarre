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
                    .clipped()
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

/*
 GeometryReader { geometry in
 VStack {
 VStack {
 ZStack {
 Image(systemName: "photo")
 .resizable()
 .ignoresSafeArea()
 .scaledToFill()
 .frame(height: geometry.size.height / 3)

 Image(systemName: "person.crop.circle.fill")
 .resizable()
 .scaledToFit()
 .frame(width: 140, height: 140)
 .background(Circle().fill(Color.background))
 .overlay(Circle().stroke(Color.white, lineWidth: 4))
 .shadow(radius: 7)
 //                        .offset(y: geometry.size.height / 5)
 }
 .background(.yellow)
 }
 .background(.green)

 Text("rgih")
 .foregroundStyle(.red)
 Text("rgih")
 .foregroundStyle(.red)
 Text("rgih")
 .foregroundStyle(.red)
 Text("rgih")
 .foregroundStyle(.red)
 }
 }
 */
