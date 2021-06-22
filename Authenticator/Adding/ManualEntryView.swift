import SwiftUI

struct ManualEntryView: View {
        @Environment(\.managedObjectContext) var context
        @EnvironmentObject var settings: SettingsStore

        @Binding var isPresented: Bool
        let completion: (Token) -> Void
        
        @State private var selection: Int = 0
        @State private var keyUri: String = ""
        @State private var issuer: String = ""
        @State private var accountName: String = ""
        @State private var secretKey: String = ""
    
        private var tokenGroup: Binding<String> {
            Binding<String>(get: {
                return settings.config!.defaultTokenGroup!
            }, set: {
                settings.config?.defaultTokenGroup = $0
                settings.saveGlobalSettings(context)
                settings.fetchGlobalSettings(context)
            })
        }
        
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
                                                                .keyboardType(.URL)
                                                                .autocapitalization(.none)
                                                                .disableAutocorrection(true)
                                                                .font(.system(.footnote, design: .monospaced))
                                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                }.padding()
                                            
                                                VStack {
                                                    HStack {
                                                        Text("Group")
                                                        Spacer()
                                                    }
                                                    TokenGroupAccountButtonStyleView(buttonSelected: tokenGroup)
                                                }.padding()
                                            
                                        } else {
                                                VStack {
                                                        VStack {
                                                                HStack {
                                                                        Text("Issuer")
                                                                        Spacer()
                                                                }
                                                                TextField("Service Provider (Optional)", text: $issuer)
                                                                        .disableAutocorrection(true)
                                                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                                        }.padding()
                                                        VStack {
                                                                HStack {
                                                                        Text("Account Name")
                                                                        Spacer()
                                                                }
                                                                TextField("email@example.com (Optional)", text: $accountName)
                                                                        .keyboardType(.emailAddress)
                                                                        .autocapitalization(.none)
                                                                        .disableAutocorrection(true)
                                                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                                        }.padding(.horizontal)
                                                        VStack {
                                                                HStack {
                                                                        Text("Secret Key")
                                                                        Spacer()
                                                                }
                                                                TextField("SECRET (Required)", text: $secretKey)
                                                                        .keyboardType(.alphabet)
                                                                        .autocapitalization(.none)
                                                                        .disableAutocorrection(true)
                                                                        .font(.system(.body, design: .monospaced))
                                                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                                        }.padding()
                                                        VStack {
                                                            HStack {
                                                                Text("Group")
                                                                Spacer()
                                                            }
                                                            TokenGroupAccountButtonStyleView(buttonSelected: tokenGroup)
                                                        }.padding()
                                                }
                                        }
                                }
                        }.alert(isPresented: $isAlertPresented) {
                                Alert(title: Text("Error"), message: Text("Invalid Key"), dismissButton: .cancel(Text("OK")))
                        }
                        .navigationTitle("Add account")
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
                        guard let token: Token = Token(uri: keyUri.trimming(), group: tokenGroup.wrappedValue.trimming()) else { return nil }
                        return token
                } else {
                        guard !secretKey.isEmpty else { return nil }
                        guard let token: Token = Token(issuerPrefix: issuer.trimming(),
                                                       accountName: accountName.trimming(),
                                                       group: tokenGroup.wrappedValue.trimming(),
                                                       secret: secretKey.trimming(),
                                                       issuer: issuer.trimming()) else { return nil }
                        return token
                }
        }
}
