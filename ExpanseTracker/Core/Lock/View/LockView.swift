//
//  LockView.swift
//  ExpanseTracker
//
//  Created by Gytis Ptasinskas on 20/03/2024.
//

import SwiftUI
import LocalAuthentication
import RiveRuntime

struct LockView<Content: View>: View {
    var lockType: LockType
    var lockPin: String
    var isEnabled: Bool
    var lockWhenAppGoesBackground: Bool = true
    var forgotPin: () -> () = { }
    @ViewBuilder var content: Content
    @State private var pin: String = ""
    @State private var animateField: Bool = false
    @State private var isUnlocked: Bool = false
    @State private var noBiometricAccess: Bool = true
    @State private var isAuthenticating = false
    @State private var showFaceIDRetryOption: Bool = false
    @State private var requestBiometricAuth: Bool = false
    @AppStorage("userPin") private var savedPin: String = ""
    let context = LAContext()
    @Environment(\.scenePhase) private var phase

    var body: some View {
        GeometryReader { geometry in
            content
                .frame(width: geometry.size.width, height: geometry.size.height)
                .disabled(!isUnlocked)
                .blur(radius: isUnlocked ? 0 : 10)
            
            if isEnabled && !isUnlocked {
                ZStack {
                    RiveViewModel(fileName: "background").view()
                        .ignoresSafeArea()
                        .blur(radius: 20)
              
                        NumberPadPinView()
                }
                .transition(.offset(y: geometry.size.height + 100))
            }
        }
        .onChange(of: phase) { _, newPhase in
             handlePhaseChange(to: newPhase)
         }
         .onChange(of: isEnabled) { _, newValue in
             isUnlocked = !newValue
         }
         .onChange(of: requestBiometricAuth) { _, newValue in
             if newValue {
                 unlockView()
             }
         }
         .onAppear {
             isUnlocked = !isEnabled
         }
     }

    private func unlockView() {
        guard requestBiometricAuth, !isAuthenticating else { return }
        isAuthenticating = true

        let reason = "Unlock the View"
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
            DispatchQueue.main.async {
                self.isAuthenticating = false
                if success {
                    self.isUnlocked = true
                    self.noBiometricAccess = false
                } else {
                    if let laError = authenticationError as NSError?, laError.code == LAError.userCancel.rawValue {
                        // User cancelled; prepare for manual retry but don't auto-retry
                        self.showFaceIDRetryOption = true
                    } else {
                        // Handle other authentication errors
                        print("Authentication failed: \(authenticationError?.localizedDescription ?? "Unknown error")")
                    }
                }
                // Reset requestBiometricAuth only on success or non-cancellation error
                self.requestBiometricAuth = false
            }
        }
    }

    private func handlePhaseChange(to newPhase: ScenePhase) {
          if newPhase == .active {
              if isEnabled && !isUnlocked {
                  unlockView()
              }
          } else if newPhase != .active && lockWhenAppGoesBackground {
              isUnlocked = false
              pin = ""
          }
      }
    
    private var isBiometricAvailable: Bool {
        var error: NSError?
        let isAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if let laError = error as NSError? {
            switch laError.code {
            case LAError.biometryNotAvailable.rawValue:
                print("Biometry not available")
            case LAError.biometryNotEnrolled.rawValue:
                print("Biometry is not enrolled")
            case LAError.biometryLockout.rawValue:
                print("Biometry is locked out")
            default:
                print("Other authentication error: \(laError.localizedDescription)")
            }
        }
        
        return isAvailable
    }
    
    private func authenticateWithBiometrics() {
        let reason = "Authenticate to unlock"
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
            DispatchQueue.main.async {
                if success {
                    self.isUnlocked = true
                } else {
                    // Handle failure or cancellation
                    self.showFaceIDRetryOption = true
                }
            }
        }
    }
    
    // Numberpad Pin View
    @ViewBuilder
    private func NumberPadPinView() -> some View {
        VStack(spacing: 15) {
            Text("Enter Pin")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity)
                .overlay {
                    if lockType == .both && isBiometricAvailable {
                        Button {
                            pin = ""
                            noBiometricAccess = false
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.title3)
                                .contentShape(.rect)
                        }
                        .hSpacing(.leading)
                        .tint(.black)
                        .padding(.leading)
                    }
                }
             
            HStack(spacing: 10) {
                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 10)
                        .background(.ultraThinMaterial)
                        .frame(width: 50, height: 55)
                        .overlay {
                            if pin.count > index {
                                let index = pin.index(pin.startIndex, offsetBy: index)
                                let string = String(pin[index])
                                
                                Text(string)
                                    .font(.title).bold()
                                    .foregroundStyle(.white)
                            }
                        }
                }
            }
            .keyframeAnimator(initialValue: CGFloat.zero, trigger: animateField, content: { content, value in
                content
                    .offset(x: value)
            }, keyframes: { _ in
                KeyframeTrack {
                    CubicKeyframe(30, duration: 0.07)
                    CubicKeyframe(-30, duration: 0.07)
                    CubicKeyframe(20, duration: 0.07)
                    CubicKeyframe(-20, duration: 0.07)
                    CubicKeyframe(0, duration: 0.07)
                }
            })
            .padding(.top, 15)
            .overlay(alignment: .bottomTrailing) {
                Button("Forgot Pin?", action: forgotPin)
                    .foregroundStyle(.black)
                    .offset(y: 40)
            }
            .frame(maxWidth: .infinity)
            
            GeometryReader { _ in
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                    ForEach(1...9, id: \.self) { number in
                        Button("\(number)") {
                            if pin.count < 4 {
                                pin.append("\(number)")
                            }
                        }
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .contentShape(.rect)
                        .tint(.black)
                    }
                    
                    Button {
                        if !pin.isEmpty {
                            pin.removeLast()
                        }
                    } label: {
                        Image(systemName: "delete.backward")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .contentShape(.rect)
                            .tint(.black)
                    }
                    
                    Button {
                        if pin.count < 4 {
                            pin.append("0")
                        }
                    } label: {
                        Text("0")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .contentShape(.rect)
                            .tint(.black)
                    }
                    
                    Button {
                        authenticateWithBiometrics()
                    } label: {
                        Image(systemName: "faceid")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .contentShape(.rect)
                            .tint(.black)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .onChange(of: pin) { oldValue, newValue in
                if newValue.count == 4 {
                    // Validate Pin
                    if lockPin == pin {
                        withAnimation(.snappy, completionCriteria: .logicallyComplete) {
                            isUnlocked = true
                            noBiometricAccess = !isBiometricAvailable
                        } completion: {
                            pin = ""
                        }
                    } else {
                        pin = ""
                        animateField.toggle()
                    }
                }
            }
        }
        .padding()
    }
    
    // Lock Type
    enum LockType: String {
        case biometric = "Bio Metric Auth"
        case number = "Custom Number Lock"
        case both = "First preference will be biometric, and if it's not available, it will go for number lock."
    }
}

#Preview {
    LockView(lockType: .both, lockPin: "", isEnabled: true) {
        EmptyView()
    }
}
