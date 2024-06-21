//
//  DebateWaitingRoomView.swift
//  Debagarre
//
//  Created by Mickaël Horn on 23/04/2024.
//

import SwiftUI

struct DebateWaitingRoomView: View {
    @State var debateRequest: Debate
    @State private var shouldAnimate = false
    @StateObject var viewModel = DebateWaitingRoomView.ViewModel()
    @EnvironmentObject var homeTabViewModel: HomeTabView.ViewModel<FirestoreService>

    var body: some View {
        GeometryReader { proxy in
            Color(.background)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading) {
                    VStack {
                        HStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .scaledToFit()

                            Spacer()

                            VStack(alignment: .leading) {
                                Text(viewModel.debateRequestCreatorNickname ?? "Unknown")
                                Text(viewModel.debateRequestCreator?.gender?.rawValue ?? "Unknown gender")
                                Text("\(viewModel.getUserAgeString(user: viewModel.debateRequestCreator)) ans.")
                            }

                            Spacer()
                        }
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 25.0)
                                .stroke(lineWidth: 2)
                        }
                        .padding()
                    }

                    HStack {
                        Spacer()

                        Text("VS")
                            .font(.title)
                            .padding()
                            .background(.mainButton)
                            .clipShape(Circle())

                        Spacer()
                    }

                    VStack {
                        HStack {
                            if viewModel.showChallenger {

                                Spacer()

                                VStack(alignment: .trailing) {
                                    Text(viewModel.debateRequestChallengerNickname ?? "Unknown")
                                    Text(viewModel.debateRequestChallenger?.gender?.rawValue ?? "Unknown gender")
                                    Text("\(viewModel.getUserAgeString(user: viewModel.debateRequestChallenger)) ans.")
                                }

                                Spacer()

                                Image(systemName: "person.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .scaledToFit()

                            } else {
                                Spacer()
                                VStack {
                                    Text("En attente d'un challenger")

                                    HStack(spacing: 5) {
                                        ForEach(0..<3) { index in
                                            Circle()
                                                .frame(width: 8, height: 8)
                                                .scaleEffect(shouldAnimate ? 1 : 0.5)
                                                .animation(
                                                    .easeInOut(duration: 0.6)
                                                    .repeatForever()
                                                    .delay(0.2 * Double(index)),
                                                    value: shouldAnimate
                                                )
                                        }
                                    }
                                    .onAppear {
                                        withAnimation {
                                            shouldAnimate = true
                                        }
                                    }

                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 25.0)
                                .stroke(lineWidth: 2)
                        }
                        .padding()
                    }

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Paramètres")
                                .font(.headline)
                                .padding([.bottom], 10)

                            Text("Thème : \(debateRequest.theme.rawValue)")
                            Text("Point de vue : \(debateRequest.pointOfView)")
                            Text("Mode : \(debateRequest.mode.rawValue)")
                            Text("Temps : \(debateRequest.timeLimit) min")
                        }
                        .padding()

                        Spacer()

                        if homeTabViewModel.user?.id == debateRequest.creatorID {
                            VStack {
                                Button(debateRequest.isCreatorReady ? "Prêt" : "Pas Prêt") {
                                    debateRequest.isCreatorReady.toggle()

                                    Task {
                                        await viewModel.updateDebateRequest(debateRequest: debateRequest)
                                    }
                                }
                                .font(.title)
                                .padding()
                                .background(debateRequest.isCreatorReady ? .green : .red)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                        } else {
                            VStack {
                                Button(debateRequest.isChallengerReady ? "Prêt" : "Pas Prêt") {
                                    debateRequest.isChallengerReady.toggle()

                                    Task {
                                        await viewModel.updateDebateRequest(debateRequest: debateRequest)
                                    }
                                }
                                .font(.title)
                                .padding()
                                .background(debateRequest.isChallengerReady ? .green : .red)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                        }

                        Spacer()
                    }
                }

                goButton
                    .frame(width: proxy.size.width / 2)
            }
            .task {
                guard let currentUser = homeTabViewModel.user,
                      let currentUserNickname = homeTabViewModel.userNickname else {

                    viewModel.showingAlert = true
                    viewModel.errorMessage = "No user found, please restart the application."
                    return
                }

                await viewModel.setupCreatorAndChallenger(currentUser: currentUser, currentUserNickname: currentUserNickname, debateRequest: debateRequest)
                viewModel.listenForDebateChanges(debateRequestID: debateRequest.id)
            }
            .alert("Erreur", isPresented: $viewModel.showingAlert) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToDebateFightingView) {
                DebateFightingView(debate: debateRequest)
            }
        }
    }

    @ViewBuilder private var goButton: some View {
        Button(action: {
            Task {
                //TODO: Aller au débat
            }
        }, label: {
            Image(.debateButton)
                .resizable()
                .aspectRatio(contentMode: .fit)
        })
    }
}

//#Preview {
//    TabView {
//        DebateWaitingRoomView(
//            debateRequest: DebateRequest(
//                creatorID: "1234",
//                creationTime: Date.now,
//                theme: .ecologie,
//                mode: .chat,
//                pointOfView: "Test POV",
//                timeLimit: 30,
//                status: .waiting,
//                isCreatorReady: false,
//                isChallengerReady: false
//            )
//        )
//        .environmentObject(HomeTabView.ViewModel())
//        .tabItem {
//            Label("Débat", systemImage: "figure.boxing")
//        }
//    }
//}
