//
//  GroupButtonStyle.swift
//  Authenticator
//
//  Created by Plus1XP on 12/06/2021.
//  Copyright © 2021 Bing Jeung. All rights reserved.
//

import SwiftUI

// GroupTextStyleView & GroupTextStyle essentially does the same thing,
// Just wanted to test using an extention method rather than a view.

struct TokenGroupOverlayButtonStyleView: View {
    @Binding var buttonSelected: String
    var personalGroup: String = "Personal"
    var workGroup: String = "Work"

    var body: some View {
        HStack {
            Button(
                action: {
                    buttonSelected = GetTokenGroupSelection(buttonName: personalGroup, buttonSelected: buttonSelected)
                }) {
                TokenGroupOverlayTextView(buttonSelected: $buttonSelected, buttonName: personalGroup)
            }
            Button(
                action: {
                    buttonSelected = GetTokenGroupSelection(buttonName: workGroup, buttonSelected: buttonSelected)
                }) {
                TokenGroupOverlayTextView(buttonSelected: $buttonSelected, buttonName: workGroup)
            }
        }
    }
}

struct TokenGroupButtonStyleView: View {
    @Binding var buttonSelected: String
    var personalGroup: String = "Personal"
    var workGroup: String = "Work"
    
    var body: some View {
        Button(
            action: {
                buttonSelected = GetTokenGroupSelection(buttonName: personalGroup, buttonSelected: buttonSelected)
            }) {
            Text(personalGroup)
                .modifier(TokenGroupTextModifer(buttonName: personalGroup, buttonSelected: $buttonSelected))
        }
        Button(
            action: {
                buttonSelected = GetTokenGroupSelection(buttonName: workGroup, buttonSelected: buttonSelected)
            }) {
            Text(workGroup)
                .modifier(TokenGroupTextModifer(buttonName: workGroup, buttonSelected: $buttonSelected))
        }
    }
}

struct TokenGroupOverlayTextView: View {
    @Binding var buttonSelected: String
    var buttonName: String
    
    var body: some View {
        Text(buttonName)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .background(Color(UIColor.secondarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .opacity(GetTokenGroupButtonVisibility(buttonName: buttonName, buttonSelected: buttonSelected) ? 0.5 : 1)
            .foregroundColor(.primary)
    }
}

struct TokenGroupButtonTextView: View {
    @Binding var buttonSelected: String
    var buttonName: String
    
    var body: some View {
        Text(buttonName)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .background(Color(UIColor.tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .opacity(GetTokenGroupButtonVisibility(buttonName: buttonName, buttonSelected: buttonSelected) ? 0.4 : 1)
            .foregroundColor(.primary)
    }
}

func GetTokenGroupButtonVisibility(buttonName: String, buttonSelected: String) -> Bool {
    if buttonName != buttonSelected {
        return true
    }
    else {
        return false
    }
}

func GetTokenGroupSelection(buttonName: String, buttonSelected: String) -> String {
    if buttonName == buttonSelected {
        return ""
    }
    else {
        return buttonName
    }
}

// ButtonStyles below are not in use, left for refernces to future styles

/*
struct TokenGroupButtonDefault: ButtonStyle {
    @Binding var buttonName: String
    @Binding var groupName: String
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .background(Color(UIColor.tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .opacity(GetGroupButtonVisibility(buttonName: buttonName, buttonSelected: groupName) ? 0.4 : 1)
            .foregroundColor(.primary)
    }
}

struct TokenGroupButtonSelected: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .background(Color(UIColor.tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .foregroundColor(.primary)
    }
}

struct TokenGroupButtonDeselected: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .background(Color(UIColor.quaternarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .foregroundColor(.secondary)
    }
}
*/
