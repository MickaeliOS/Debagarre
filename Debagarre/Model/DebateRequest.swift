//
//  DebateRequest.swift
//  Debagarre
//
//  Created by Mickaël Horn on 23/04/2024.
//

import Foundation
import FirebaseFirestoreSwift

struct DebateRequest: Codable, Hashable {
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

extension DebateRequest {
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
