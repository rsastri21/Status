//
//  SignInResponse.swift
//  Status
//
//  Created by Rohan Sastri on 3/30/25.
//

import Foundation

struct SignInResponse: Codable {
    let message: String
    let authToken: String
    let expiresAt: Date
    
    static func decode(_ signInResponse: Data) -> SignInResponse? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return try? decoder.decode(SignInResponse.self, from: signInResponse)
    }
}
