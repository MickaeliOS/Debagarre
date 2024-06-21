//
//  Nickname.swift
//  Debagarre
//
//  Created by Mickaël Horn on 09/04/2024.
//

import Foundation
import FirebaseFirestoreSwift

struct Nickname: Codable {
    @DocumentID var id: String?
    var nickname: String
}

extension Nickname {
    static let previewNickname = Nickname(nickname: "Creator")
}
