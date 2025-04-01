//
//  KeychainStorage.swift
//  Status
//
//  Created by Rohan Sastri on 3/30/25.
//

import Foundation
import KeychainSwift

enum KeychainStorage {
    static let credentialsKey = "credentials"
    static let authTokenKey = "authToken"
    
    static let keychain = KeychainSwift()
    
    static func getCredentials() -> Credentials? {
        if let credentials = keychain.get(credentialsKey) {
            return Credentials.decode(credentials)
        } else {
            return nil
        }
    }
    
    static func saveCredentials(_ credentials: Credentials) -> Bool {
        if keychain.set(credentials.encoded(), forKey: credentialsKey) {
            return true
        } else {
            return false
        }
    }
    
    static func getAuthToken() -> AuthToken? {
        if let authToken = keychain.get(authTokenKey) {
            return AuthToken.decode(authToken)
        } else {
            return nil
        }
    }
    
    static func saveAuthToken(_ authToken: AuthToken) -> Bool {
        if keychain.set(authToken.encoded(), forKey: authTokenKey) {
            return true
        } else {
            return false
        }
    }
    
    static func removeAuthToken() -> Bool {
        if keychain.delete(authTokenKey) {
            return true
        } else {
            return false
        }
    }
    
    static func hasStoredAuthToken() -> Bool {
        if var authToken = getAuthToken() {
            if Date() < authToken.expiresAt {
                // Refresh token if it's within 7 days of expiry
                if Date() >= authToken.expiresAt.addingTimeInterval(-7 * 24 * 60 * 60) {
                    authToken.expiresAt = Date().addingTimeInterval(14 * 24 * 60 * 60)
                }
                let _ = saveAuthToken(authToken)
                return true
            }
            let _ = removeAuthToken()
        }
        return false
    }
}
