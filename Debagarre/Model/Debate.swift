//
//  Debate.swift
//  Debagarre
//
//  Created by Mickaël Horn on 23/04/2024.
//

import Foundation
import FirebaseFirestoreSwift

struct Debate: Codable, Hashable {
    @DocumentID var id: String?
    let creatorID: String
    var challengerID: String?
    let creationTime: Date
    let theme: Theme
    let mode: Mode
    let pointOfView: String
    let timeLimit: Int
    var status: Status
    var isCreatorReady: Bool
    var isChallengerReady: Bool
}

extension Debate {
    enum Theme: String, CaseIterable, Codable, CustomStringConvertible {
        case ecologie
        case veganisme
        case politique
        case guerre
        case surconsommation

        var description: String {
            switch self {
            case .ecologie:
                "Ecologie"
            case .veganisme:
                "Veganisme"
            case .politique:
                "Politique"
            case .guerre:
                "Guerre"
            case .surconsommation:
                "Surconsommation"
            }
        }

        var icon: String {
            switch self {
            case .ecologie:
                return "leaf.fill"
            case .veganisme:
                return "hare.fill"
            case .politique:
                return "building.columns.circle"
            case .guerre:
                return "shield.fill"
            case .surconsommation:
                return "cart.fill"
            }
        }
    }

    enum Mode: String, CaseIterable, Codable, CustomStringConvertible {
        case video
        case chat

        var description: String {
            switch self {
            case .video:
                "Vidéo"
            case .chat:
                "Ecrit"
            }
        }
    }

    enum Status: String, Codable {
        case waiting
        case matched

        var description: String {
            switch self {
            case .waiting:
                "Waiting"
            case .matched:
                "Matched"
            }
        }
    }
}

extension Debate {
    static let previewDebate = Debate(
        creatorID: "1234",
        creationTime: Date.now,
        theme: .ecologie,
        mode: .chat,
        pointOfView: "Test POV",
        timeLimit: 30,
        status: .waiting,
        isCreatorReady: false,
        isChallengerReady: false
    )
}
