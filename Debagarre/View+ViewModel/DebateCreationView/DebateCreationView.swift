//
//  DebateCreationView.swift
//  Debagarre
//
//  Created by Mickaël Horn on 18/03/2024.
//

import SwiftUI

struct DebateCreationView: View {
    @State private var themes = ["Ecologie", "Veganisme", "Politique", "Guerre", "Surconsommation"]
    @State private var selectedTheme = "Ecologie"
    @State private var pointOfView = ""
    @State private var showPopover = false
    @State private var pointOfViewLimit = 100
    @State private var formats = ["Ecrit", "Vidéo"]
    @State private var selectedFormat = "Ecrit"

    @EnvironmentObject var homeTabViewModel: HomeTabView.ViewModel

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                Color(.background)
                    .ignoresSafeArea()

                VStack {
                    Spacer()

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

                    goButton
                        .frame(width: proxy.size.width / 2)
                }
            }
            // MARK: PROBLEM -> si je tape vite au clavier, un 6ème charactère apparaît
            .onChange(of: pointOfView, { oldValue, newValue in
                if newValue.count > pointOfViewLimit {
                    pointOfView = String(newValue.prefix(pointOfViewLimit))
                }
            })
            .navigationTitle("Création du débat")
        }
    }

    @ViewBuilder private var theme: some View {
        HStack {
            Text("Choisis ton thème")
                .font(.title2)

            Spacer()

            Picker("Theme", selection: $selectedTheme) {
                ForEach(themes, id: \.self) { theme in
                    Text(theme)
                }
            }
        }
    }

    @ViewBuilder private var pointOfViewInfos: some View {
        HStack {
            TextField("Ton point de vue", text: $pointOfView, axis: .vertical)
                .font(.title2)

            Text("\(pointOfView.count) / \(pointOfViewLimit)")
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

        Picker("Format", selection: $selectedFormat) {
            ForEach(formats, id: \.self) { format in
                Text(format)
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder private var goButton: some View {
        Button(action: {
        }) {
            ZStack {
                Image(.debateButton)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}

#Preview {
    TabView {
        DebateCreationView()
            .tabItem {
                Label("Débat", systemImage: "figure.boxing")
            }
    }
}
