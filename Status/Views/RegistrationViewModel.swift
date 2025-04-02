//
//  RegistrationViewModel.swift
//  Status
//
//  Created by Rohan Sastri on 4/1/25.
//

import Observation
import Foundation

@Observable
class RegistrationViewModel {
    enum RegistrationStatus {
        case idle
        case inflight
        case success
        case failure
    }
    
    var registration = Registration()
    var status: RegistrationStatus = .idle
    
    var signUpDisabled: Bool {
        registration.email.isEmpty || registration.password.isEmpty || registration.name.isEmpty || registration.username.isEmpty || registration.password.count < 8
    }
    
    func signUp() async {
        status = .inflight
        
        guard let encoded = try? JSONEncoder().encode(registration) else {
            print("Failed to encode registration data.")
            return
        }
        
        let url = URL(string: "https://8k51p4xaai.execute-api.us-east-1.amazonaws.com/api/auth/register")!
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.httpBody = encoded
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response.")
                status = .failure
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                status = .success
            case 400:
                status = .failure
            default:
                status = .failure
            }
        } catch {
            print("Failed to register: \(error.localizedDescription)")
            status = .failure
        }
    }
    
}
