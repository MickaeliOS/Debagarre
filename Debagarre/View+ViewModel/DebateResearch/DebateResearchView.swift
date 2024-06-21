//
//  DebateResearchView.swift
//  Debagarre
//
//  Created by Mickaël Horn on 03/05/2024.
//

import SwiftUI

struct DebateResearchView: View {
    @StateObject private var viewModel = DebateResearchView.ViewModel()
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geometry in
                Color.background
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Debate.Theme.allCases, id: \.self) { theme in
                                Button {
                                    viewModel.selectedTheme = theme

                                    Task {
                                        await viewModel.getDebateRequestListFlow()
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: theme.icon)
                                            .renderingMode(.original)

                                        Text(theme.description)
                                            .fontWeight(viewModel.selectedTheme == theme ? .bold : .regular)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(viewModel.selectedTheme == theme ? .mainElement : .secondElement)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(viewModel.selectedTheme == theme ? .mainElement : Color.clear, lineWidth: 2)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)

                    List {
                        ForEach(viewModel.debateRequestList, id: \.debate.id) { (debate, user, nickname) in
                            DebateCellView(debate: debate, debateCreator: user, debateCreatorNickname: nickname)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
                .padding(.top)
            }
            .navigationTitle("Rechercher un débat")
        }
        .task {
            await viewModel.getDebateRequestListFlow()
        }
    }
}

//#Preview {
//    DebateResearchView()
//}
