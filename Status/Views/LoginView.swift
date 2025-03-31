//
//  LoginView.swift
//  Status
//
//  Created by Rohan Sastri on 3/30/25.
//

import SwiftUI

struct LoginView: View {
    
    @Environment(Authentication.self) private var authentication
    @State private var loginVM = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.shutter.button")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.cyan)
                .font(.system(size: 100, weight: .medium))
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
            Text("Status")
                .font(.system(size: 64, weight: .semibold))
            VStack {
                TextField("Username", text: $loginVM.credentials.username)
                    .keyboardType(.emailAddress)
                SecureField("Password", text: $loginVM.credentials.password)
            }
            if loginVM.showProgressView {
                ProgressView()
            }
            VStack {
                Button {
                    loginVM.login { success in
                        authentication.updateValidation(success: success)
                    }
                } label: {
                    Text("Sign in")
                        .foregroundStyle(.primary)
                        .padding(.vertical)
                        .frame(minWidth: 100, maxWidth: .infinity, minHeight: 40)
                }
                .disabled(loginVM.loginDisabled)
                .background(.cyan)
                .cornerRadius(16)
                
                if authentication.biometricType() != .none {
                    Button {
                        authentication.requestBiometricUnlock { (result: Result<Credentials, Authentication.AuthenticationError>) in
                            switch result {
                            case .success(let credentials):
                                loginVM.credentials = credentials
                                loginVM.login { success in
                                    authentication.updateValidation(success: success)
                                }
                            case .failure(let error):
                                loginVM.error = error
                            }
                        }
                    } label: {
                        if authentication.biometricType() == .face {
                            Text("Sign in with Face ID")
                                .foregroundStyle(.primary)
                                .padding(.vertical)
                            Image(systemName: "faceid")
                                .resizable()
                                .frame(width: 24, height: 24)
                        } else {
                            Text("Sign in with Touch ID")
                                .foregroundStyle(.primary)
                                .padding(.vertical)
                            Image(systemName: "touchid")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                }
            }
        }
        .padding()
        .textFieldStyle(RoundedTextFieldStyle())
        .disabled(loginVM.showProgressView)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(item: $loginVM.error) { error in
            if error == .credentialsNotSaved {
                return Alert(title: Text("Credentials Not Saved"),
                             message: Text(error.localizedDescription),
                             primaryButton: .default(Text("OK"), action: {
                                loginVM.storeCredentialsNext = true
                             }),
                             secondaryButton: .cancel())
            } else {
                return Alert(title: Text("Invalid Login"), message: Text(error.localizedDescription))
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(Authentication())
}
