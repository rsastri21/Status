//
//  ContentView.swift
//  Status
//
//  Created by Rohan Sastri on 3/30/25.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(Authentication.self) private var authentication
    @State private var contentVM = ContentViewModel()
    
    var body: some View {
        TabView {
            NavigationStack {
                Text("Home View")
                    .navigationTitle("Status")
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            Button {
                                contentVM.showingSignOutConfirmation = true
                            } label: {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                            }
                            .confirmationDialog("", isPresented: $contentVM.showingSignOutConfirmation, titleVisibility: .hidden) {
                                Button("Sign out", role: .destructive) {
                                    contentVM.signOut { success in
                                        authentication.updateValidation(success: success)
                                    }
                                }
                                Button("Cancel", role: .cancel) {}
                            }
                        }
                        ToolbarItemGroup(placement: .topBarLeading) {
                            if contentVM.showProgressView {
                                ProgressView()
                            }
                        }
                    }
                    .alert(item: $contentVM.error) { error in
                        Alert(title: Text("Failed sign out"),
                              message: Text(error.localizedDescription),
                              dismissButton: .default(Text("OK")))
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            Text("Camera View")
                .tabItem {
                    Label("Post", systemImage: "camera.shutter.button")
                }
            NavigationStack {
                Text("Profile View")
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle.fill")
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(Authentication())
}
