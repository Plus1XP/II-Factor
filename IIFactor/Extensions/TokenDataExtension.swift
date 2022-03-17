//
//  TokenData.swift
//  Authenticator
//
//  Created by Plus1XP on 24/06/2021.
//

//import Foundation
import SwiftUI
import CoreData

extension TokenData {
    
    static var AllResults: NSFetchRequest<TokenData> {
        let request: NSFetchRequest<TokenData> = TokenData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "indexNumber", ascending: true)]
        
        return request
    }
    
    static var PersonalResults: NSFetchRequest<TokenData> {
        let request: NSFetchRequest<TokenData> = TokenData.fetchRequest()
        request.predicate = NSPredicate(format: "displayGroup == %@", TokenGroupType.Personal.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "indexNumber", ascending: true)]
        
        return request
    }
    
    static var WorkResults: NSFetchRequest<TokenData> {
        let request: NSFetchRequest<TokenData> = TokenData.fetchRequest()
        request.predicate = NSPredicate(format: "displayGroup == %@", TokenGroupType.Work.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "indexNumber", ascending: true)]
        
        return request
    }
}
