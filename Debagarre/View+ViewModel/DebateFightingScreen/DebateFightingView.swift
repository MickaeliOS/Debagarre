//
//  DebateFightingView.swift
//  Debagarre
//
//  Created by Mickaël Horn on 29/04/2024.
//

import SwiftUI

struct DebateFightingView: View {
    @State var debateRequest: DebateRequest

    var body: some View {
        Text("Creator : \(debateRequest.creatorID)")

        Text("Challenger : \(debateRequest.challengerID ?? "No challenger")")
    }
}

#Preview {
    let debateRequestDummy = DebateRequest(
        creatorID: "1234",
        creationTime: Date.now,
        theme: .ecologie,
        mode: .chat,
        pointOfView: "User's point of view on the debate.", timeLimit: 30,
        status: .matched,
        isCreatorReady: true,
        isChallengerReady: true
    )

    return DebateFightingView(debateRequest: debateRequestDummy)
}
