//
//  SettingsView.swift
//  Authenticator
//
//  Created by Plus1XP on 17/06/2021.
//  Copyright © 2021 Bing Jeung. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var settings: SettingsStore

    @Binding var isPresented: Bool
    @State var tokens: [Token]
    
    var personalGroup: String = "Personal"
    var workGroup: String = "Work"
    
//    @State var isAutoLockToggleActive: Bool = false
//    @State var group: TokenGroupType = .None
    
//    private var isLockEnabled: Binding<Bool> {
//        Binding<Bool>(get: {
//            return settings.config?.isLockEnabled ?? false
//        }, set: {
//            settings.config?.isLockEnabled = $0
//            if ((settings.config?.isLockEnabled) != nil) {
//                isAutoLockToggleActive = false
//            }
//            if (!(settings.config?.isLockEnabled ?? false)){
//                isAutoLockToggleActive = true
//            }
//        })
//    }
//
//    private var isAutoLockEnabled: Binding<Bool> {
//        Binding<Bool>(get: {
//            return settings.config!.isAutoLockEnabled
//        }, set: {
//            settings.config?.isAutoLockEnabled = $0
//        })
//    }
//
//    private var tokenGroupSelected: Binding<String> {
//        Binding<String>(get: {
//            return settings.config!.defaultTokenGroup!
//        }, set: {
//            settings.config?.defaultTokenGroup = $0
//        })
//    }
    
    private var isLockEnabled: Binding<Bool> {
        Binding<Bool>(get: {
            return settings.config!.isLockEnabled
        }, set: {
            settings.config?.isLockEnabled = $0
            settings.saveGlobalSettings(context)
            settings.fetchGlobalSettings(context)
        })
    }

    private var isAutoLockEnabled: Binding<Bool> {
        Binding<Bool>(get: {
            return settings.config!.isAutoLockEnabled
        }, set: {
            settings.config?.isAutoLockEnabled = $0
            settings.saveGlobalSettings(context)
            settings.fetchGlobalSettings(context)
        })
    }

    private var tokenGroupSelected: Binding<String> {
        Binding<String>(get: {
            return settings.config!.defaultTokenGroup!
        }, set: {
            settings.config?.defaultTokenGroup = $0
            settings.saveGlobalSettings(context)
            settings.fetchGlobalSettings(context)
        })
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                GlobalBackgroundColor().ignoresSafeArea()
                ScrollView {
                    VStack {
                        GroupBox(
                            label: Label("Security", systemImage: "lock")
                                .foregroundColor(.secondary)
                        ) {
                            Toggle("Enable Password", isOn: isLockEnabled)
                            Toggle("Enable Auto-Lock", isOn: isAutoLockEnabled)
//                                .disabled(isAutoLockToggleActive)
                                .disabled(!isLockEnabled.wrappedValue)
                        }
                        .padding()
                    }
                    
                    VStack {
                        GroupBox(
                            label: Label("Defaults", systemImage: "arrow.counterclockwise")
                                .foregroundColor(.secondary)
                                .padding(.bottom)
                        ) {
                            HStack {
                                Text(NSLocalizedString("Image Group", comment: "")).font(.headline)
                                Spacer()
                            }
//                            TokenGroupSettingsButtonStyleView()
                            TokenGroupAccountButtonStyleView(buttonSelected: tokenGroupSelected)
                                .padding(.bottom)
                        }
                        .padding()
                    }
                    //Uncomment in stach
//                        }
//                        .padding()
//                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Back")
                    }
                }
            }
        }
    }
}
