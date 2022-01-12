import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var settings: SettingsStore
    
    @State private var isAppLocked = true
    @State private var isLockEnabled = true
    @State private var isAutoLockEnable = true
    @State private var defaultGroup = TokenGroupType.None.rawValue
    
    var body: some View {
        ZStack {
            MainView()
                .environmentObject(settings)
                .blur(radius: SetBlur(isLocked: isAppLocked))
                .disabled(isAppLocked)
            
            if isLockEnabled && isAppLocked {
                Button(action: {
                    debugPrint("authenticate button Pushed")
                    ValidateBiometrics()
                }, label: {
                    let biometric = BiometricService()
                    Text("\(Text(biometric.setBiometricIcon()))")
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
            ValidateBiometrics()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            debugPrint("Moving to the background!")
            getLockStatusFromGlobalSettings()
            if isLockEnabled && isAutoLockEnable {
                isAppLocked = true
                NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "AppLocked")))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            debugPrint("Moving to the foreground!")
            ValidateBiometrics()
        }
//        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { (_) in
//            debugPrint("Moving to the background!")
//            isBackground = true
//            getLockStatusFromGlobalSettings()
//            if isLockEnabled && isAutoLockEnable {
//              isAppLocked = true
//              NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "AppLocked")))
//            }
//        }
//        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { (_) in
//            debugPrint("Moving to the foreground!")
//            isBackground = false
//            ValidateBiometrics()
//        }
    }
    
    private func SetBlur(isLocked: Bool) -> CGFloat {
        switch isLocked {
        case false:
            return 0.0
        case true:
            return 8.0
        }
    }
    
    private func getLockStatusFromGlobalSettings() -> Void {
        settings.setupGlobalSettings(context)
        isLockEnabled = settings.config!.isLockEnabled
        isAutoLockEnable = settings.config!.isAutoLockEnabled
        defaultGroup = settings.config!.defaultTokenGroup ?? TokenGroupType.None.rawValue
        if !isLockEnabled {
            self.isAppLocked = false
        }
    }
    
    private func ValidateBiometrics() -> Void {
        let biometric = BiometricService()
        biometric.canEvaluate { (canEvaluate, _, canEvaluateError) in
            guard canEvaluate else {
                debugPrint(canEvaluateError?.localizedDescription ?? "Authentication Failure, No Biometrics or Password Set")
                return
            }
            biometric.evaluate { (success, error) in
                guard success else {
                    debugPrint(error?.localizedDescription ?? "Authentication Error, Incorrect Biometrics or Password, User Cancelled")
                    return
                }
                debugPrint("Authentication Successful")
                self.isAppLocked = false
            }
        }
    }
}
