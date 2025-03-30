//
//  AuthToken.swift
//  Status
//
//  Created by Rohan Sastri on 3/30/25.
//

import Foundation

struct AuthToken: Codable {
    let authToken: String
    let user: String
    var expiresAt: Date
    
    func encoded() -> String {
        let encoder = JSONEncoder()
        let authTokenData = try! encoder.encode(self)
        return String(data: authTokenData, encoding: .utf8)!
    }
    
    static func decode(_ authTokenString: String) -> AuthToken {
        let decoder = JSONDecoder()
        let jsonData = authTokenString.data(using: .utf8)!
        return try! decoder.decode(AuthToken.self, from: jsonData)
    }
}
