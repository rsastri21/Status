//
//  StatusApp.swift
//  Status
//
//  Created by Rohan Sastri on 3/30/25.
//

import SwiftUI

@main
struct StatusApp: App {
    
    @State private var authentication = Authentication()
    
    var body: some Scene {
        WindowGroup {
            if authentication.isValidated {
                ContentView()
                    .environment(authentication)
            } else {
                LoginView()
                    .environment(authentication)
            }
        }
    }
}
