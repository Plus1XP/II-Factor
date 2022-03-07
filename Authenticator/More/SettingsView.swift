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
            if settings.config?.isLockEnabled == true {
                // Results is un-needed as we only need to trigger iOS notification.
                // Strictly here to stop Xcode complaining
                ValidateBiometrics()
            }
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
                            label: Label {
                                Text("Sync")
                                    .foregroundColor(.secondary)
                                Text(stateText(for:SyncMonitor.shared.importState))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .foregroundColor(.secondary)
                                    .font(.footnote)
                            } icon: {
                                Image(systemName: stateIcon(for:SyncMonitor.shared.importState))
                                    .foregroundColor(stateColour(for:SyncMonitor.shared.importState))
                            }
                        ) {
                            Toggle("iCloud", isOn: isCloudKitEnabled)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("NOTE: iCloud Changes may take a while & will not be applied untill app is restarted")
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
        return Alert(title: Text("Delete iCloud data?"),
                     message: Text(NSLocalizedString(message, comment: .empty)),
                     primaryButton: .cancel(Text("Turn off, KEEP data"), action: cancelDeletion),
                     secondaryButton: .destructive(Text("Turn off, DELETE data"), action: performDeletion))
    }

    private func performDeletion() {
        (UIApplication.shared.delegate as? AppDelegate)?.RemoveiCloudData() { (result) in
            if result {
                hasIcloudDeletedSuccessfuly = true
            } else {
                hasIcloudDeletedSuccessfuly = false
            }
            debugPrint("iCloud Banner Displayed: \(result)")
            isDeletionBannerPresented = true
            DismissBanner()
        }
    }
    
    private func cancelDeletion() {
        isDeletionAlertPresented = false
    }
    
    private func DismissBanner() {
        // Delay of 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            isDeletionBannerPresented = false
            debugPrint("iCloud Banner Dismissed")
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
            }
        }
    }
}

fileprivate var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = DateFormatter.Style.short
    dateFormatter.timeStyle = DateFormatter.Style.short
    return dateFormatter
}()

/// Returns a user-displayable text description of the sync state
func stateText(for state: SyncMonitor.SyncState) -> String {
    switch state {
    case .notStarted:
        return "Not started"
    case .inProgress(started: let date):
        return "In progress since \(dateFormatter.string(from: date))"
    case let .succeeded(started: _, ended: endDate):
        return "Suceeded at \(dateFormatter.string(from: endDate))"
    case let .failed(started: _, ended: endDate, error: _):
        return "Failed at \(dateFormatter.string(from: endDate))"
    }
}

func stateIcon(for state: SyncMonitor.SyncState) -> String {
    switch state {
    case .notStarted:
        return "bolt.horizontal.icloud"
    case .inProgress:
        return "arrow.clockwise.icloud"
    case .succeeded:
        return "icloud"
    case .failed:
        return "exclamationmark.icloud"
    }
}

func stateColour(for state: SyncMonitor.SyncState) -> Color {
    switch state {
    case .notStarted:
        return .gray
    case .inProgress:
        return .yellow
    case .succeeded:
        return .green
    case .failed:
        return .red
    }
}
