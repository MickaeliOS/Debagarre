//
//  DebagarreSplashScreenView.swift
//  Debagarre
//
//  Created by Mickaël Horn on 13/03/2024.
//

import SwiftUI

struct DebagarreSplashScreenView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Débagarre")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Image(systemName: "brain.head.profile")
                    .resizable()
                    .foregroundStyle(.white)
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .opacity(animate ? 1.0 : 0.5)

                Image(systemName: "figure.boxing")
                    .resizable()
                    .foregroundStyle(.red)
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .scaleEffect(animate ? 1.0 : 0.5)
            }
            .padding()
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    animate.toggle()
                }
            }
        }
    }
}

#Preview {
    DebagarreSplashScreenView()
}
