//
//  SettingsStore.swift
//  Authenticator
//
//  Created by Plus1XP on 19/06/2021.
//  Copyright © 2021 Bing Jeung. All rights reserved.
//

import CoreData

class SettingsStore: ObservableObject {
    
    @Published var config: GlobalSettings?
    
    func setupGlobalSettings(_ context: NSManagedObjectContext) -> Void {
        setUserDefaults()
        fetchGlobalSettings(context)
        if config == nil {
            print("! Settings Empty")
            saveGlobalSettings(context ,isLockEnabled: false, isAutoLockEnabled: false, defaultTokenGroup: TokenGroupType.None.rawValue, defaultView: "")
            print("! Created new DB")
            fetchGlobalSettings(context)
        }
        else {
            print("! Settings Loaded")
        }
    }

    func fetchGlobalSettings(_ context: NSManagedObjectContext) -> Void {
        do {
            let settings: [GlobalSettings] = try context.fetch(GlobalSettings.fetchRequest())
            print("config count: \(settings.count)")
            config = settings.first
        } catch let error as NSError {
            print("Load settings failed: \(error.localizedDescription)")
        }
    }
    
    func saveGlobalSettings(_ context: NSManagedObjectContext) -> Void {
        do {
            try context.save()
        } catch let error as NSError {
            print("Save settings failed: \(error.localizedDescription)")
        }
    }

    func saveGlobalSettings(_ context: NSManagedObjectContext, isLockEnabled: Bool, isAutoLockEnabled: Bool, defaultTokenGroup: String, defaultView: String) -> Void {
        let setting = GlobalSettings(context: context)
        setting.isLockEnabled = isLockEnabled
        setting.isAutoLockEnabled = isAutoLockEnabled
        setting.defaultTokenGroup = defaultTokenGroup
        setting.defaultView = defaultView
        do {
            try context.save()
        } catch let error as NSError {
            print("Save settings failed: \(error.localizedDescription)")
        }
    }

    func deleteGlobalSettings(_ context: NSManagedObjectContext, settings: GlobalSettings) -> Void {
        context.delete(settings)
        do {
            try context.save()
        } catch let error as NSError {
            print("Delete settings failed: \(error.localizedDescription)")
        }
    }
    
    func deleteGlobalSettings(_ context: NSManagedObjectContext) -> Void {
        do {
            var settings: [GlobalSettings] = try context.fetch(GlobalSettings.fetchRequest())
            print("config count: \(settings.count)")
            for item in settings {
                var number: Int = 1
                deleteGlobalSettings(context, settings: item)
                print("Deleted config: \(number) of \(settings.count)")
                number += 1
            }
            settings = try context.fetch(GlobalSettings.fetchRequest())
            print("config count: \(settings.count)")
        } catch let error as NSError {
            print("Load settings failed: \(error.localizedDescription)")
        }
    }
    
    func setUserDefaults() -> Void {
        UserDefaults.standard.register(
            defaults: [
                "isCloudKitEnabled": false
            ]
        )
    }
}
