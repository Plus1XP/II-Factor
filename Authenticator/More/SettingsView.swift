//
//  SettingsView.swift
//  Authenticator
//
//  Created by Plus1XP on 17/06/2021.
//  Copyright © 2021 Bing Jeung. All rights reserved.
//

import SwiftUI

struct SettingsView: View {    
    @Binding var isPresented: Bool
    @Binding var settings: [GlobalSettings]
    
    var body: some View {
        NavigationView {
            ZStack {
                GlobalBackgroundColor().ignoresSafeArea()
                ScrollView {
                    VStack {
                        GroupBox(
                            label: Label("Security", systemImage: "lock.circle")
                                .foregroundColor(.secondary)
                        ) {
                            Toggle("Enable Password", isOn: $settings[0].isLockEnabled)
                            Toggle("Enable Auto-Lock", isOn: $settings[0].isAutoLockEnabled)
                                .disabled(false)
                        }
                        .padding()
                    }
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
