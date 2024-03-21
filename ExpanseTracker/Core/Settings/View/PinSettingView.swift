//
//  PinSettingView.swift
//  ExpanseTracker
//
//  Created by Gytis Ptasinskas on 20/03/2024.
//

import SwiftUI

struct PinSettingView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userPin") private var userPin: String = ""
    @State private var pinInput: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Set Your Pin")) {
                    SecureField("Enter a new PIN", text: $pinInput)
                }
                
                Section {
                    Button("Save Pin") {
                        userPin = pinInput
                        dismiss()
                    }
                    .disabled(pinInput.isEmpty)
                }
            }
            .navigationTitle("Pin Settings")
        }
    }
}

#Preview {
    PinSettingView()
}
