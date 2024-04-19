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
    let nickname: String
}
