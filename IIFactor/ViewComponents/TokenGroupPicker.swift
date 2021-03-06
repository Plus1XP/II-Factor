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
    
    let NoneGroupNAme: String = "All"
    
    var TokenGroups: [TokenGroupType] = [
        TokenGroupType.None,
        TokenGroupType.Personal,
        TokenGroupType.Work
    ]
    
    func SetTokenGroupNames(tokenGroupName: inout String, tokenGroup: TokenGroupType) -> Void {
        switch tokenGroup {
        case .None:
            tokenGroupName = NoneGroupNAme
        case .Personal:
            tokenGroupName = tokenGroup.rawValue
        case .Work:
            tokenGroupName = tokenGroup.rawValue
        }
    }
    
    func GetTokenGroupNames(tokenGroup: TokenGroupType) -> String {
        switch tokenGroup {
        case .None:
            return NoneGroupNAme
        case .Personal:
            return tokenGroup.rawValue
        case .Work:
            return tokenGroup.rawValue
        }
    }
    
    func GetTokenGroupValues(tokenGroup: String?) -> TokenGroupType {
        switch tokenGroup {
        case TokenGroupType.Personal.rawValue:
            return .Personal
        case TokenGroupType.Work.rawValue:
            return .Work
        default:
            return .None
        }
    }
    
    func FilterToken(selectedTokenGroup: TokenGroupType) -> String? {
        if selectedTokenGroup == .Personal {
            return TokenGroupType.Personal.rawValue
        }
        else if selectedTokenGroup == .Work {
            return TokenGroupType.Work.rawValue
        }
        else {
            return nil
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
