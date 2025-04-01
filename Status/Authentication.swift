//
//  Authentication.swift
//  Status
//
//  Created by Rohan Sastri on 3/30/25.
//

import SwiftUI
import Observation
import LocalAuthentication

@Observable class Authentication {
    var isValidated: Bool = KeychainStorage.hasStoredAuthToken()
    var isAuthorized: Bool = false
    
    enum BiometricType {
        case none
        case face
        case touch
    }
    
    enum AuthenticationError: Error, LocalizedError, Identifiable {
        case invalidCredentials
        case deniedAccess
        case noFaceIdEnrolled
        case noFingerprintEnrolled
        case biometricError
        case credentialsNotSaved
        case noAccountFound
        case unsuccessfulSignIn
        case unsuccessfulSignOut
        
        var id: String {
            self.localizedDescription
        }
        
        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return NSLocalizedString("Username or password is incorrect. Please try again.", comment: "")
            case .deniedAccess:
                return NSLocalizedString("You have denied biometric access. Please go to Settings > Apps > Status and turn on Face ID or Touch ID.", comment: "")
            case .noFaceIdEnrolled:
                return NSLocalizedString("You have not set up Face ID yet.", comment: "")
            case .noFingerprintEnrolled:
                return NSLocalizedString("You have not set up Touch ID yet.", comment: "")
            case .biometricError:
                return NSLocalizedString("Your face or fingerprint was not recognized.", comment: "")
            case .credentialsNotSaved:
                return NSLocalizedString("Your credentials have not been saved. Do you want to save them after the next successful login?", comment: "")
            case .noAccountFound:
                return NSLocalizedString("No account found. Please sign-up first.", comment: "")
            case .unsuccessfulSignIn:
                return NSLocalizedString("Could not process your request. Try again later.", comment: "")
            case .unsuccessfulSignOut:
                return NSLocalizedString("Could not sign out. Try again later.", comment: "")
            }
        }
    }
    
    func updateValidation(success: Bool) {
        withAnimation {
            isValidated = success
        }
    }
    
    func biometricType() -> BiometricType {
        let authContext = LAContext()
        let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        switch authContext.biometryType {
        case .touchID:
            return .touch
        case .faceID:
            return .face
        case .none:
            return .none
        default:
            return .none
        }
    }
    
    func requestBiometricUnlock(completion: @escaping (Result<Credentials, AuthenticationError>) -> Void) {
        let credentials = KeychainStorage.getCredentials()
        
        guard let credentials = credentials else {
            completion(.failure(.credentialsNotSaved))
            return
        }
        
        let context = LAContext()
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if let error = error {
            switch error.code {
            case -6:
                completion(.failure(.deniedAccess))
            case -7:
                if context.biometryType == .faceID {
                    completion(.failure(.noFaceIdEnrolled))
                } else {
                    completion(.failure(.noFingerprintEnrolled))
                }
            default:
                completion(.failure(.biometricError))
            }
            return
        }
        if canEvaluate && context.biometryType != .none {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Need to access credentials") { success, error in
                DispatchQueue.main.async {
                    if error != nil {
                        completion(.failure(.biometricError))
                    } else {
                        completion(.success(credentials))
                    }
                }
            }
        }
    }
}
