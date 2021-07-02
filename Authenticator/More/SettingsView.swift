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
    @State private var isDeletionAlertPresented: Bool = false
    @State private var isDeletionBannerPresented: Bool = false
    @State private var hasIcloudDeletedSuccessfuly: Bool = false
    
    var personalGroup: String = "Personal"
    var workGroup: String = "Work"

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
    
    private var isCloudKitEnabled: Binding<Bool> {
        Binding<Bool>(get: {
            return UserDefaults.standard.bool(forKey: "isCloudKitEnabled")
        }, set: {
            UserDefaults.standard.setValue($0, forKey: "isCloudKitEnabled")
            canDeleteIcloudData(isCloudKitEnabled: $0)
        })
    }
    
    private let versionString: String = {
            let version: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "_error"
            let build: String = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "_error"
            return version + " (" + build + ")"
    }()
    
    private let iCloudDeleteSuccessfulBanner: BannerData = BannerData(
        title: "iCloud Data has been Deleted",
        level: .success,
        style: .popUp
    )
    
    private let iCloudDeleteErrorBanner: BannerData = BannerData(
        title: "Error Deleting iCloud Data",
        level: .warning,
        style: .popUp
    )
    
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
                            Toggle("Enable App Lock", isOn: isLockEnabled)
                            Toggle("Enable Auto-Lock", isOn: isAutoLockEnabled)
                                .disabled(!isLockEnabled.wrappedValue)
                            }
                        .padding()
                    }
                    
                    VStack {
                        GroupBox(
                            label: Label("Sync", systemImage: "icloud")
                                .foregroundColor(.secondary)
                        ) {
                            Toggle("iCloud", isOn: isCloudKitEnabled)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("NOTE: iCloud Changes will not be applied untill app is restarted")
                                .font(.footnote)
                                .foregroundColor(Color.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack {
                        GroupBox(
                            label: Label("Default Group", systemImage: "checkmark.circle")
                                .foregroundColor(.secondary)
                                .padding(.bottom)
                        ) {
                            TokenGroupAccountButtonStyleView(buttonSelected: tokenGroupSelected)
                                .padding(.bottom)
                        }
                        .padding()
                    }
                    
                    VStack {
                        GroupBox(
                            label: Label("Export", systemImage: "square.and.arrow.up")
                                .foregroundColor(.secondary)
                        ) {
                            ExportView(tokens: tokens)
                                .padding(.top)
                        }
                        .padding()
                    }
                    
                    VStack {
                        GroupBox(
                            label: Label("About", systemImage: "info.circle")
                                .foregroundColor(.secondary)
                        ) {
                            AboutView()
                                .padding(.top)
                        }
                        .padding()
                    }
                    
                    HStack {
                            Text("Version - \(versionString)")
                    }
                    .font(.footnote)
                    .contextMenu(menuItems: {
                            MenuCopyButton(content: versionString)
                    })
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
        .accentColor(.primary)
        .alert(isPresented: $isDeletionAlertPresented) {
            deletionAlert
        }
        .banner(isPresented: $isDeletionBannerPresented, data: GetdeletionBanner(), action: {
            // Place action here..
        })
    }
    
    func canDeleteIcloudData(isCloudKitEnabled: Bool) -> Void {
        if isCloudKitEnabled == false {
            isDeletionAlertPresented = true
        }
    }
    
    func GetdeletionBanner() -> BannerData {
        if hasIcloudDeletedSuccessfuly {
            return iCloudDeleteSuccessfulBanner
        } else {
            return iCloudDeleteErrorBanner
        }
    }
    
    private var deletionAlert: Alert {
        let message: String = "This is an irreversable action.\nPlease ensure you have a backup."
        return Alert(title: Text("Delete iCloud Data?"),
                     message: Text(NSLocalizedString(message, comment: "")),
                     primaryButton: .cancel(cancelDeletion),
                     secondaryButton: .destructive(Text("Delete"), action: performDeletion))
    }
    
    private func performDeletion() {
        guard let isSuccessful = (UIApplication.shared.delegate as? AppDelegate)?.RemoveiCloudData() else { return }
        if isSuccessful {
            hasIcloudDeletedSuccessfuly = true
        } else {
            hasIcloudDeletedSuccessfuly = false
        }
        isDeletionBannerPresented = true
    }
    
    private func cancelDeletion() {
        isDeletionAlertPresented = false
    }
}
