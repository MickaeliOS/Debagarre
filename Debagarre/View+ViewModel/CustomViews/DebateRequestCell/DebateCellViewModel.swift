//
//  DebateRequestCellViewModel.swift
//  Debagarre
//
//  Created by Mickaël Horn on 14/05/2024.
//

import Foundation

extension DebateCellView {

    @MainActor
    final class ViewModel: ObservableObject {
        func getUserAgeString(user: User?) -> String {
            guard let user = user,
                  let userAge = user.getAge() else {

                return "N/A"
            }

            return String(userAge)
        }
    }
}
