//
//  DebateCreationView.swift
//  Debagarre
//
//  Created by Mickaël Horn on 18/03/2024.
//

import SwiftUI
import FirebaseAuth

struct DebateCreationView: View {
    @State private var showPopover = false
    @State private var pointOfViewLimit = 100
    @State private var path = NavigationPath()

    @EnvironmentObject var homeTabViewModel: HomeTabView.ViewModel<FirestoreService>
    @StateObject var viewModel = DebateCreationView.ViewModel()

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { proxy in
                Color(.background)
                    .ignoresSafeArea()

                VStack {
                    VStack(alignment: .leading) {
                        theme

                        Divider()

                        pointOfViewInfos
                            .frame(height: proxy.frame(in: .local).height / 5)

                        Divider()

                        format

                        Text(homeTabViewModel.userNickname?.nickname ?? "")
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                    .padding()

                    Spacer()
                    
                    goButton
                        .padding()
                }
            }
            .navigationDestination(for: Debate.self) { debateRequest in
                DebateWaitingRoomView(debateRequest: debateRequest)
            }
            // MARK: PROBLEM -> si je tape vite au clavier, un 6ème charactère apparaît
            .onChange(of: viewModel.pointOfView, { oldValue, newValue in
                if newValue.count > pointOfViewLimit {
                    viewModel.pointOfView = String(newValue.prefix(pointOfViewLimit))
                }
            })
            .alert("Error", isPresented: $viewModel.showingAlert) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .navigationTitle("Création du débat")
        }
    }

    @ViewBuilder private var theme: some View {
        HStack {
            Text("Choisis ton thème")
                .font(.title2)

            Spacer()

            Picker("Theme", selection: $viewModel.selectedTheme) {
                ForEach(Debate.Theme.allCases, id: \.self) { theme in
                    Text(String(describing: theme))
                }
            }
        }
    }

    @ViewBuilder private var pointOfViewInfos: some View {
        HStack {
            TextField("Ton point de vue", text: $viewModel.pointOfView, axis: .vertical)
                .font(.title2)

            Text("\(viewModel.pointOfView.count) / \(pointOfViewLimit)")
                .foregroundStyle(.gray)

            Button(action: {
                self.showPopover.toggle()
            }) {
                Image(systemName: "questionmark.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .popover(isPresented: $showPopover, attachmentAnchor: .point(.leading)) {
                Text("Aide les utilisateurs à choisir avec qui débattre.")
                    .presentationCompactAdaptation(.popover)
            }
        }
        .padding([.top, .bottom])
    }

    @ViewBuilder private var format: some View {
        Text("Choisis le format du débat")
            .font(.title2)
            .padding([.top])

        Picker("Format", selection: $viewModel.selectedMode) {
            ForEach(Debate.Mode.allCases, id: \.self) { mode in
                Text(String(describing: mode))
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder private var goButton: some View {
        Button("Suivant") {
            Task {
                await debateRequestCreationFlow()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.mainButton)
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .font(.title2)
        .shadow(radius: 10)
    }

    private func debateRequestCreationFlow() async {
        await viewModel.debateRequestCreationFlow()

        guard let debateRequest = viewModel.debateRequest else {
            viewModel.errorMessage = "Error, we could not create your debate, please try again."
            viewModel.showingAlert = true
            return
        }

        path.append(debateRequest)
    }
}

#Preview {
    TabView {
        DebateCreationView()
            .environmentObject(HomeTabView.ViewModel())
            .tabItem {
                Label("Débat", systemImage: "figure.boxing")
            }
    }
}
