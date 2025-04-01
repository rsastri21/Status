//
//  ContentViewModel.swift
//  Status
//
//  Created by Rohan Sastri on 3/31/25.
//

import Observation
import Foundation

@Observable
class ContentViewModel {
    var showingSignOutConfirmation = false
    var showProgressView = false
    var error: Authentication.AuthenticationError?
    
    func signOut(completion: @escaping (Bool) -> Void) {
        self.showProgressView = true
        guard let authToken = KeychainStorage.getAuthToken() else {
            self.error = .unsuccessfulSignOut
            return completion(false)
        }
        
        let url = URL(string: "https://8k51p4xaai.execute-api.us-east-1.amazonaws.com/api/auth/sign-out")!
        var request = URLRequest(url: url)
        
        request.setValue(authToken.authToken, forHTTPHeaderField: "auth-token")
        request.setValue(authToken.user, forHTTPHeaderField: "user")
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            self.showProgressView = false
            if error != nil {
                self.error = .unsuccessfulSignOut
                completion(true)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response.")
                self.error = .unsuccessfulSignOut
                return;
            }
            
            switch httpResponse.statusCode {
            case 400:
                self.error = .unsuccessfulSignOut
                completion(true)
            case 200:
                self.error = nil
                
                guard KeychainStorage.removeAuthToken() else {
                    print("Failed to remove auth token.")
                    self.error = .unsuccessfulSignOut
                    completion(true)
                    return
                }
                
                completion(false)
            default:
                self.error = .unsuccessfulSignOut
                completion(true)
            }
        }
        .resume()
    }
}
