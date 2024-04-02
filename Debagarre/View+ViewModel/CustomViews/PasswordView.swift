//
//  PasswordView.swift
//  Débagarre
//
//  Created by Mickaël Horn on 06/03/2024.
//

import SwiftUI

struct PasswordView: View {
    let fieldName: String

    @State private var isSecure = true
    @Binding var password: String

    var body: some View {
        if isSecure {
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)

                SecureField(fieldName, text: $password)
                    .textInputAutocapitalization(.never)
                    .overlay(Button {
                        isSecure.toggle()
                    } label: {
                        Image(systemName: "eye.slash")
                            .foregroundColor(.gray)
                    }, alignment: .trailing)
            }
        } else {
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)

                TextField(fieldName, text: $password)
                    .textInputAutocapitalization(.never)
                    .overlay(Button {
                        isSecure.toggle()
                        print("TextField")
                    } label: {
                        Image(systemName: "eye")
                            .foregroundColor(.gray)
                    }, alignment: .trailing)
            }
        }
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView(fieldName: "PreviewField", password: .constant("12345"))
    }
}
