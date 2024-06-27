//
//  BannerImage.swift
//  Debagarre
//
//  Created by Mickaël Horn on 25/06/2024.
//

import Foundation
import FirebaseFirestore

struct BannerImage: Codable {
    @DocumentID var id: String?
    var path: String
}
