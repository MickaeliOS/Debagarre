//
//  StringExtension.swift
//  Débagarre
//
//  Created by Mickaël Horn on 06/03/2024.
//

import Foundation

extension String {
    var isReallyEmpty: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
