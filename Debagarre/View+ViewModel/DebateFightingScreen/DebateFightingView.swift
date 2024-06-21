//
//  DebateFightingView.swift
//  Debagarre
//
//  Created by Mickaël Horn on 29/04/2024.
//

import SwiftUI

struct DebateFightingView: View {
    @State var debate: Debate

    var body: some View {
        Text("Creator : \(debate.creatorID)")

        Text("Challenger : \(debate.challengerID ?? "No challenger")")
    }
}

#Preview {
    DebateFightingView(debate: Debate.previewDebate)
}
