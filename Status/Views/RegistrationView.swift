//
//  RegistrationView.swift
//  Status
//
//  Created by Rohan Sastri on 4/1/25.
//

import SwiftUI

struct RegistrationView: View {
    
    @State private var registrationVM = RegistrationViewModel()
    @Binding var showingSignUp: Bool
    @Binding var credentials: Credentials
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(UIColor.secondarySystemBackground))
                        .stroke(.secondary.opacity(0.7), lineWidth: 2)
                        .frame(width: 120, height: 120)
                    Text("👋")
                        .font(.system(size: 64))
                }
                .padding()
                Section {
                    VStack {
                        TextField("Name", text: $registrationVM.registration.name)
                            .textContentType(.name)
                        TextField("Username", text: $registrationVM.registration.username)
                            .textContentType(.username)
                        TextField("Email", text: $registrationVM.registration.email)
                            .keyboardType(.emailAddress)
                    }
                } header: {
                    Text("Personal Information")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Section {
                    SecureField("Enter at least 8 characters", text: $registrationVM.registration.password)
                } header: {
                    Text("Password")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                Button {
                    Task {
                        await registrationVM.signUp(showingSignUp: $showingSignUp, credentials: $credentials)
                    }
                } label: {
                    HStack {
                        Text("Sign up")
                            .foregroundStyle(registrationVM.signUpDisabled ? .black : .white)
                            .padding(.vertical)
                        if registrationVM.status == .inflight {
                            ProgressView()
                        }
                    }
                    .frame(minWidth: 100, maxWidth: .infinity, minHeight: 54, maxHeight: 54)
                }
                .disabled(registrationVM.signUpDisabled)
                .background(.cyan)
                .cornerRadius(16)
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding()
            .navigationTitle("Sign Up")
            .textFieldStyle(RoundedTextFieldStyle())
            .toolbar {
                Button {
                    UIApplication.shared.endEditing()
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
            }
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .alert("Registration failed", isPresented: $registrationVM.showError, presenting: registrationVM.error) { _ in
                Button {
                    registrationVM.status = .idle
                    registrationVM.error = nil
                } label: {
                    Text("OK")
                }
            } message: { error in
                Text(error.localizedDescription)
            }
        }
    }
}

#Preview {
    RegistrationView(showingSignUp: .constant(true), credentials: .constant(Credentials()))
}
