//
//  GroupPickerView.swift
//  Authenticator
//
//  Created by Plus1XP on 12/06/2021.
//  Copyright © 2021 Bing Jeung. All rights reserved.
//

import SwiftUI

struct TokenGroupPickerView: View {
    var tokenGroupPicker = TokenGroupPicker()
    @Binding var selectedTokenGroup: TokenGroupType

    var body: some View {
        Picker("Select Group", selection: $selectedTokenGroup) {
            ForEach(tokenGroupPicker.TokenGroups, id: \.self) { group in
                Button(
                    action: {
                        self.selectedTokenGroup = group
                    },
                    label: {
                        Text(tokenGroupPicker.GetTokenGroupNames(tokenGroup: group))
                    })
            }
        }
    }
}
