import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var biometricService = BiometricService()
    @State private var isAppLocked = true
    private var isLockEnabled = true
    
    var body: some View {
        ZStack {
            MainView()
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
            if isLockEnabled && isAppLocked {
                ValidateBiometrics()
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
}
