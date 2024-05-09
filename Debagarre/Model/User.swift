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
