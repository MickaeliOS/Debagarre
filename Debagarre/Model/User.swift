//
//  User.swift
//  Débagarre
//
//  Created by Mickaël Horn on 06/03/2024.
//

import Foundation

struct User: Codable {
    let nicknameID: String
    let email: String
    var lastname: String?
    var firstname: String?
    var birthdate: Date?
    var gender: String?
    var profilePicture: String?
}

extension User {
    enum Gender: String, CaseIterable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
    }
}
