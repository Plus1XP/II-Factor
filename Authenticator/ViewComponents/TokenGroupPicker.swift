//
//  GroupPickerModel.swift
//  Authenticator
//
//  Created by Plus1XP on 12/06/2021.
//  Copyright © 2021 Bing Jeung. All rights reserved.
//

import Foundation

enum TokenGroupType: String, Codable {
    case None = ""
    case Personal = "Personal"
    case Work = "Work"
}

struct TokenGroupPicker {
    
    var TokenGroups: [TokenGroupType] = [
        TokenGroupType.None,
        TokenGroupType.Personal,
        TokenGroupType.Work
    ]
    
    func SetTokenGroupNames(tokenGroupName: inout String, tokenGroup: TokenGroupType) -> Void {
        switch tokenGroup {
        case .None:
            tokenGroupName = "All"
        case .Personal:
            tokenGroupName = tokenGroup.rawValue
        case .Work:
            tokenGroupName = tokenGroup.rawValue
        }
    }
    
    func GetTokenGroupNames(tokenGroup: TokenGroupType) -> String {
        switch tokenGroup {
        case .None:
            return "All"
        case .Personal:
            return tokenGroup.rawValue
        case .Work:
            return tokenGroup.rawValue
        }
    }
    
    func FilterToken(token: [Token], selectedTokenGroup: TokenGroupType) -> [Token] {
        if selectedTokenGroup == .Personal {
            return token.filter { $0.displayGroup.contains(TokenGroupType.Personal.rawValue) }
        }
        else if selectedTokenGroup == .Work {
            return token.filter { $0.displayGroup.contains(TokenGroupType.Work.rawValue) }
        }
        else {
            return token
        }
    }
    
    func MatchTokenGroup(tokenName: String, tokenGroup: [TokenGroupType]) -> TokenGroupType {
        var tokenGroupType: TokenGroupType? = .none
        for group in TokenGroups {
            if tokenName == group.rawValue {
                tokenGroupType = group
                break
            }
        }
        return tokenGroupType!
    }
}
