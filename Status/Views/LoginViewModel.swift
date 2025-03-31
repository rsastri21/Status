//
//  LoginViewModel.swift
//  Status
//
//  Created by Rohan Sastri on 3/30/25.
//

import Observation
import Foundation

@Observable
class LoginViewModel {
    var credentials = Credentials()
    var showProgressView: Bool = false
    var error: Authentication.AuthenticationError?
    var storeCredentialsNext: Bool = false
    
    var loginDisabled: Bool {
        credentials.username.isEmpty || credentials.password.isEmpty
    }
    
    func login(completion: @escaping (Bool) -> Void) {
        self.showProgressView = true
        guard let encodedCredentials = try? JSONEncoder().encode(credentials) else {
            print("Failed to encode credentials.")
            return
        }
        
        let url = URL(string: "https://8k51p4xaai.execute-api.us-east-1.amazonaws.com/api/auth/sign-in")!
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = encodedCredentials
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            self.showProgressView = false
            if error != nil {
                self.error = .unsuccessfulSignIn
                completion(false)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response.")
                completion(false)
                return
            }
            
            switch httpResponse.statusCode {
            case 404:
                self.error = .noAccountFound
                completion(false)
            case 401:
                self.error = .invalidCredentials
                completion(false)
            case 400:
                self.error = .unsuccessfulSignIn
                completion(false)
            case 200:
                guard let data = data else {
                    self.error = .unsuccessfulSignIn
                    completion(false)
                    return
                }
                
                // Save session token info
                guard let signInResponse = SignInResponse.decode(data) else {
                    self.error = .unsuccessfulSignIn
                    completion(false)
                    return
                }
                
                let authToken = AuthToken(authToken: signInResponse.authToken, user: self.credentials.username, expiresAt: signInResponse.expiresAt)
                let _ = KeychainStorage.saveAuthToken(authToken)
                
                completion(true)
            default:
                self.error = .unsuccessfulSignIn
            }
        }
    }
}
