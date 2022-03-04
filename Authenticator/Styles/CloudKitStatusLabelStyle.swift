//
//  CloudKitStatusLabelStyle.swift
//  Authenticator
//
//  Created by Plus1XP on 04/03/2022.
//

import SwiftUI

struct CloudKitStatusLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
            Text("Sync")
                .foregroundColor(.secondary)
            configuration.title
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
