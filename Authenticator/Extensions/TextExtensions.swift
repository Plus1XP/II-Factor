//
//  GroupTextStyle.swift
//  Authenticator
//
//  Created by Plus1XP on 13/06/2021.
//  Copyright © 2021 Bing Jeung. All rights reserved.
//

import SwiftUI

extension Text {
    func textStyle<Style: ViewModifier>(_ style: Style) -> some View {
        ModifiedContent(content: self, modifier: style)
    }
}

struct TokenGroupTextModifer: ViewModifier {
    var buttonName: String
    @Binding var buttonSelected: String
    
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .background(Color(UIColor.tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .opacity(GetTokenGroupButtonVisibility(buttonName: buttonName, buttonSelected: buttonSelected) ? 0.4 : 1)
            .foregroundColor(.primary)
    }
}
