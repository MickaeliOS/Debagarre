//
//  User.swift
//  Débagarre
//
//  Created by Mickaël Horn on 06/03/2024.
//

import Foundation
import FirebaseFirestore

struct User: Codable {
    @DocumentID var id: String?
    let nicknameID: String
    let email: String
    var birthdate: Date?
    var gender: Gender?
    var profilePictureID: String?
    var bannerImageID: String?
    var numberOfDebate: Int?
    var aboutMe: String?
}

extension User {
    enum Gender: String, CaseIterable, Codable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
    }
}

extension User {
    func getAge() -> Int? {
        guard let birthdate = self.birthdate else {
            return nil
        }

        let calendar = Calendar.current
        let currentDate = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: currentDate)

        return ageComponents.year
    }
}

extension User {
    static let previewUser = User(
        nicknameID: "1234",
        email: "test@mail.com",
        birthdate: Date.now,
        gender: .male
    )
}
