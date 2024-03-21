//
//  SettingsView.swift
//  ExpanseTracker
//
//  Created by Gytis Ptasinskas on 05/03/2024.
//

import SwiftUI
import Combine

struct SettingsView: View {
    // User Properties
    @AppStorage("userName") private var userName: String = ""
    @State private var temporaryUserName: String = ""
    // App Lock Properties
    @AppStorage("isAppLockEnabled") private var isAppLockEnabled: Bool = false
    @AppStorage("lockWhenAppGoesBackground") private var lockWhenAppGoesBackground: Bool = false
    
    @State private var showPinSettingSheet = false
    var body: some View {
        NavigationStack {
            List {
                Section("User Name") {
                    TextField("User name", text: $userName)
                }
                
                Section("App Lock") {
                    Toggle("Enable App Lock", isOn: $isAppLockEnabled)
                    
                    if isAppLockEnabled {
                        Toggle("Lock When AppGoes Background", isOn: $lockWhenAppGoesBackground)
                        Button("Set Pin") {
                            showPinSettingSheet.toggle()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPinSettingSheet) {
                PinSettingView()
            }
        }
    }
}

#Preview {
    ContentView()
}
