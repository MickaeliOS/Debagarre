//
//  DateExtension.swift
//  Debagarre
//
//  Created by Mickaël Horn on 09/05/2024.
//

import Foundation

extension Date {
    func age() throws -> Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let ageComponents = calendar.dateComponents([.year], from: self, to: currentDate)

        guard let age = ageComponents.year else {
            throw CustomError(errorDescription: "N/A.")
        }

        return age
    }
}
