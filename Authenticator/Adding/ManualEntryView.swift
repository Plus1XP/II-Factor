import SwiftUI

struct ManualEntryView: View {
        @Environment(\.managedObjectContext) var context
        @EnvironmentObject var settings: SettingsStore

        @Binding var isPresented: Bool
        let completion: (Token) -> Void
        
        @State private var selection: Int = 0
        private var tokenGroup: Binding<String> {
            Binding<String>(get: {
                return settings.config!.defaultTokenGroup!
            }, set: {
                settings.config?.defaultTokenGroup = $0
                settings.saveGlobalSettings(context)
                settings.fetchGlobalSettings(context)
            })
        }
        
        @State private var keyUri: String = .empty
        @State private var issuer: String = .empty
        @State private var accountName: String = .empty
        @State private var secretKey: String = .empty

        @State private var isAlertPresented: Bool = false
        
        var body: some View {
                NavigationView {
                        ZStack {
                                GlobalBackgroundColor().ignoresSafeArea()
                                ScrollView {
                                        Picker("Method", selection: $selection) {
                                                Text("By Key URI").tag(0)
                                                Text("By Secret Key").tag(1)
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                        .padding()
                                        if selection == 0 {
                                                VStack {
                                                        HStack {
                                                                Text("Key URI")
                                                                Spacer()
                                                        }
                                                        TextField("otpauth://totp/...", text: $keyUri)
                                                                .padding(.all, 10)
                                                                .keyboardType(.URL)
//                                                                .submitLabel(.done)
                                                                .autocapitalization(.none)
                                                                .disableAutocorrection(true)
                                                                .font(.system(size: 13, weight: .regular, design: .monospaced))
                                                                .fillBackground(cornerRadius: 8)
                                                }
                                                .padding()
                                                VStack {
                                                    HStack {
                                                        Text("Group")
                                                        Spacer()
                                                    }
                                                    TokenGroupAccountButtonStyleView(buttonSelected: tokenGroup)
                                                }
                                                .padding()
                                        } else {
                                                VStack {
                                                        VStack {
                                                                HStack {
                                                                        Text("Issuer")
                                                                        Spacer()
                                                                }
                                                                TextField("Service Provider (Optional)", text: $issuer)
                                                                        .padding(.all, 8)
//                                                                        .submitLabel(.done)
                                                                        .autocapitalization(.words)
                                                                        .disableAutocorrection(true)
                                                                        .fillBackground(cornerRadius: 8)
                                                        }
                                                        .padding()
                                                        VStack {
                                                                HStack {
                                                                        Text("Account Name")
                                                                        Spacer()
                                                                }
                                                                TextField("email@example.com (Optional)", text: $accountName)
                                                                        .padding(.all, 8)
                                                                        .keyboardType(.emailAddress)
//                                                                        .submitLabel(.done)
                                                                        .autocapitalization(.none)
                                                                        .disableAutocorrection(true)
                                                                        .fillBackground(cornerRadius: 8)
                                                        }
                                                        .padding(.horizontal)
                                                        VStack {
                                                                HStack {
                                                                        Text("Secret Key")
                                                                        Spacer()
                                                                }
                                                                TextField("SECRET (Required)", text: $secretKey)
                                                                        .padding(.all, 8)
                                                                        .keyboardType(.asciiCapable)
//                                                                        .submitLabel(.done)
                                                                        .autocapitalization(.none)
                                                                        .disableAutocorrection(true)
                                                                        .font(.system(.body, design: .monospaced))
                                                                        .fillBackground(cornerRadius: 8)
                                                        }
                                                        .padding()
                                                        VStack {
                                                            HStack {
                                                                Text("Group")
                                                                Spacer()
                                                            }
                                                            TokenGroupAccountButtonStyleView(buttonSelected: tokenGroup)
                                                        }
                                                        .padding()
                                                }
                                        }
                                }
                        }.alert(isPresented: $isAlertPresented) {
                                Alert(title: Text("Error"), message: Text("Invalid Key"), dismissButton: .cancel(Text("OK")))
                        }
                        .navigationTitle("Add Account")
                        .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                        Button(action: {
                                                isPresented = false
                                        }) {
                                                Text("Cancel")
                                        }
                                }
                                ToolbarItem(placement: .navigationBarTrailing) {
                                        Button(action: handleAdding) { Text("Add") }
                                }
                        }
                }
        }
        
        private func handleAdding() {
                var feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                if let token: Token = self.newToken {
                        feedbackGenerator?.notificationOccurred(.success)
                        feedbackGenerator = nil
                        completion(token)
                        isPresented = false
                } else {
                        feedbackGenerator?.notificationOccurred(.error)
                        feedbackGenerator = nil
                        isAlertPresented = true
                }
        }
        
        private var newToken: Token? {
                if selection == 0 {
                        guard !keyUri.isEmpty else { return nil }
                        guard let token: Token = Token(uri: keyUri.trimmed(), group: tokenGroup.wrappedValue.trimmed()) else { return nil }
                        return token
                } else {
                        guard !secretKey.isEmpty else { return nil }
                        guard let token: Token = Token(issuerPrefix: issuer.trimmed(),
                                                       accountName: accountName.trimmed(),
                                                       group: tokenGroup.wrappedValue.trimmed(),
                                                       secret: secretKey.trimmed().removeSpaces(),
                                                       issuer: issuer.trimmed()) else { return nil }
                        return token
                }
        }
}
