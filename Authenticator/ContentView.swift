import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var context
    @StateObject private var biometricService = BiometricService()

    @State var settings: [GlobalSettings] = []
    @State private var isAppLocked = true
    @State private var isLockEnabled = true
    @State private var isAutoLockEnable = true
    
    var body: some View {
        ZStack {
            MainView(settings: $settings)
                .blur(radius: SetBlur(isLocked: isAppLocked))
                .disabled(isAppLocked)
            
            if isLockEnabled && isAppLocked {
                Button(action: {
                    print("authenticate button Pushed")
                    ValidateBiometrics()
                }, label: {
//                    Text("\(Text(Image(systemName: "touchid"))) / \(Text(Image(systemName: "faceid")))")
                    Text("\(Text(biometricService.setBiometricIcon()))")
                        .multilineTextAlignment(.center)
                        .padding(30)
                        .background(Color.secondary.blendMode(.overlay))
                        .opacity(1.0)
                        .cornerRadius(20)
                        .foregroundColor(Color.primary)
                        .font(.largeTitle)
                })
            } else {
                // Not needed for now
            }
        }
        .onAppear {
            getLockStatusFromGlobalSettings()
            if isLockEnabled && isAppLocked {
                ValidateBiometrics()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            print("Moving to the background!")
            if isLockEnabled && isAutoLockEnable {
                isAppLocked = true
            }
        }
    }
    
    func SetBlur(isLocked: Bool) -> CGFloat {
        switch isLocked {
        case false:
            return 0.0
        case true:
            return 8.0
        }
    }
    
    func getLockStatusFromGlobalSettings() -> Void {
        setupGlobalSettings()
        isLockEnabled = settings[0].isLockEnabled
        isAutoLockEnable = settings[0].isAutoLockEnabled
        if !isLockEnabled {
            self.isAppLocked = false
        }
    }
    
    func ValidateBiometrics() -> Void {
        biometricService.canEvaluate { (canEvaluate, _, canEvaluateError) in
            guard canEvaluate else {
                // Face ID/Touch ID may not be available or configured
                print("authentication not available")
                return
            }
            biometricService.evaluate { (success, error) in
                guard success else {
                    // Face ID/Touch ID may not be configured
                    print("authentication not successful")
                    return
                }
                // You are successfully verified
                print("authentication successful")
                self.isAppLocked = false
            }
        }
    }
    
    // Mark: - Core Data

    func setupGlobalSettings() -> Void {
        loadGlobalSettings()
        print("Count: \(settings.count)")
        if settings.isEmpty {
            print("! Settings Empty")
            saveGlobalSettings(isLockEnabled: false, isAutoLockEnabled: false, defaultTokenGroup: "")
            print("! Created new DB")
            loadGlobalSettings()
            print("count: \(settings.count)")
        }
        else {
            print("! Settings Loaded")
        }
    }

    func loadGlobalSettings() -> Void {
        do {
            self.settings = try context.fetch(GlobalSettings.fetchRequest())
        } catch {
            print("Load settings failed")
        }
    }

    func saveGlobalSettings(isLockEnabled: Bool, isAutoLockEnabled: Bool, defaultTokenGroup: String) -> Void {
        let setting = GlobalSettings(context: self.context)
        setting.isLockEnabled = isLockEnabled
        setting.isAutoLockEnabled = isAutoLockEnabled
//        setting.defaultTokenGroup = defaultTokenGroup
        do {
            try context.save()
            loadGlobalSettings()
        } catch {
            print("Savesettings failed")
        }
    }

    func deleteGlobalSettings(settings: GlobalSettings) -> Void {
        self.context.delete(settings)
        do {
            try context.save()
            loadGlobalSettings()
        } catch {
            print("Delete settings failed")
        }
    }
}

// Mark: - Core Data

/*
func setupGlobalSettings(_ context: NSManagedObjectContext) -> GlobalSettings {
    var settings: GlobalSettings?
    settings = loadGlobalSettings(context)
    //print("Count: \(settings.count)")
    if settings == nil {
        print("! Settings Empty")
        settings = saveGlobalSettings(context ,isLockEnabled: false, isAutoLockEnabled: false, defaultTokenGroup: "")
        print("! Created new DB")
        settings = loadGlobalSettings(context)
//        print("count: \(settings.count)")
    }
    else {
        print("! Settings Loaded")
    }
    return settings
}

func loadGlobalSettings(_ context: NSManagedObjectContext) -> GlobalSettings {
    let settings: [GlobalSettings]?
    do {
        settings = try context.fetch(GlobalSettings.fetchRequest())
        return settings?.first ?? GlobalSettings.init()
    } catch {
        print("Load settings failed")
    }
}

func saveGlobalSettings(_ context: NSManagedObjectContext, isLockEnabled: Bool, isAutoLockEnabled: Bool, defaultTokenGroup: String) -> GlobalSettings {
    let setting = GlobalSettings(context: context)
    setting.isLockEnabled = isLockEnabled
    setting.isAutoLockEnabled = isAutoLockEnabled
//        setting.defaultTokenGroup = defaultTokenGroup
    do {
        try context.save()
        return loadGlobalSettings(context)
    } catch {
        print("Save settings failed")
    }
}

func deleteGlobalSettings(_ context: NSManagedObjectContext, settings: GlobalSettings) -> GlobalSettings {
    context.delete(settings)
    do {
        try context.save()
        return loadGlobalSettings(context)
    } catch {
        print("Delete settings failed")
    }
}
*/
