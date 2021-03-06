import SwiftUI

struct EditAccountView: View {

        @Binding var isPresented: Bool
        let token: Token
        let tokenIndex: Int
        let completion: (Int, String, String, String) -> Void

        @State private var displayGroup: String = TokenGroupType.None.rawValue
        @State private var displayIssuer: String = .empty
        @State private var displayAccountName: String = .empty

        var body: some View {
                NavigationView {
                        ZStack {
                                GlobalBackgroundColor().ignoresSafeArea()
                                ScrollView {
                                        VStack {
                                                HStack {
                                                        Text("Issuer").font(.headline)
                                                        Spacer()
                                                }
                                                TextField(token.displayIssuer, text: $displayIssuer)
                                                        .padding(.all, 8)
                                                        .disableAutocorrection(true)
                                                        .autocapitalization(.words)
                                                        .fillBackground(cornerRadius: 8)
                                        }
                                        .padding()
                                        VStack {
                                                HStack {
                                                        Text("Account Name").font(.headline)
                                                        Spacer()
                                                }
                                                TextField(token.displayAccountName, text: $displayAccountName)
                                                        .padding(.all, 8)
                                                        .keyboardType(.emailAddress)
                                                        .disableAutocorrection(true)
                                                        .autocapitalization(.none)
                                                        .fillBackground(cornerRadius: 8)
                                        }
                                        .padding(.horizontal)
                                        VStack {
                                            HStack {
                                                Text("Group").font(.headline)
                                                Spacer()
                                            }
                                            TokenGroupAccountButtonStyleView(buttonSelected: $displayGroup)
                                        }
                                        .padding()
                                        HStack {
                                                // TODO: Localization
                                                Text("**NOTE**: Changes would not apply to the Key URI")
                                                        .font(.footnote)
                                                        .foregroundColor(Color.secondary)
                                                Spacer()
                                        }
                                        .padding()
                                }
                        }
                        .navigationTitle("title.edit_account")
                        .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                        Button(action: {
                                                isPresented = false
                                        }) {
                                                Text("Cancel")
                                        }
                                }
                                ToolbarItem(placement: .navigationBarTrailing) {
                                        Button(action: {
                                                displayIssuer = displayIssuer.trimmed()
                                                displayAccountName = displayAccountName.trimmed()
                                                displayGroup = displayGroup.trimmed()
                                                completion(tokenIndex, displayIssuer, displayAccountName, displayGroup)
                                                isPresented = false
                                        }) {
                                                Text("Done")
                                        }
                                }
                        }
                }
                .onAppear {
                        displayIssuer = token.displayIssuer
                        displayAccountName = token.displayAccountName
                        displayGroup = token.displayGroup
                }
        }
}
