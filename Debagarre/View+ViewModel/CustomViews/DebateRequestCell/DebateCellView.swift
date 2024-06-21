//
//  DebateRequestCellView.swift
//  Debagarre
//
//  Created by Mickaël Horn on 13/05/2024.
//

import SwiftUI

struct DebateCellView: View {
    let debate: Debate
    let debateCreator: User
    let debateCreatorNickname: Nickname

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(debate.theme.description)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.mainElement)
                .cornerRadius(8)
                .padding(.bottom, 10)

            HStack {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .background(Color.background)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 5) {
                    Text(debateCreatorNickname.nickname)
                        .font(.title3)
                        .foregroundColor(.white)

                    HStack {
                        Text("\(debateCreator.gender?.rawValue ?? "N/A")")
                            .font(.headline)
                            .foregroundColor(.mainElement)

                        Text("- \(getUserAgeString(user: debateCreator)) ans")
                            .font(.headline)
                            .foregroundColor(.mainElement)
                    }
                }
                .padding(.leading, 10)
            }
            .padding(.bottom, 10)

            Text(debate.pointOfView)
                .font(.body)
                .foregroundColor(.white)
                .padding(.vertical, 5)

//            Divider()
//                .background(Color.mainElement.opacity(0.7))
        }
        .padding()
        .background(Color.background)
    }

    private func getUserAgeString(user: User?) -> String {
        guard let user = user,
              let userAge = user.getAge() else {
            return "N/A"
        }
        return String(userAge)
    }
}

#Preview {
    DebateCellView(
        debate: Debate.previewDebate,
        debateCreator: User.previewUser,
        debateCreatorNickname: Nickname.previewNickname
    )
}
