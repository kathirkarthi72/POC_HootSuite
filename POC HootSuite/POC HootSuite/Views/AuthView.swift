//
//  AuthView.swift
//  POC HootSuite
//
//  Created by Kathiresan on 03/01/25.
//

import SwiftUI

//https://chatgpt.com/share/6769186d-d640-800e-9c06-4fa1027102e6

class AuthVM: ObservableObject {
    @AppStorage("authCode") var authToken: String = ""
    @AppStorage("loggedIn") var loggedIn: Bool = false

}

struct AuthView: View {
    @EnvironmentObject var authVM: AuthVM
    @ObservedObject private var viewModel = HootsuiteViewModel()

    var body: some View {
        NavigationView(content: {
            VStack(alignment: .center, spacing: 10, content: {
                
                if authVM.loggedIn {
                    List(content: {
                        
                        VStack(alignment: .leading, spacing: 10, content: {
                            Text("Found")
                            Text("Status code: \(authVM.authToken)")
                        })
                        
                        VStack(alignment: .leading, spacing: 10, content: {
                            Text("1.")
                            
                            Button("Apply Access Token", action: {
                                self.viewModel.accessToken = authVM.authToken
                                self.viewModel.service.accessToken = authVM.authToken
                                print("Applied")
                            })
                        })
                        
                        VStack(alignment: .leading, spacing: 10, content: {
                            Text("2.")
                            
                            Button("Fetch Organization", action: {
                                Task {
                                    await self.viewModel.fetchOrganization()
                                }
                            })
                        })
                        
                        VStack(alignment: .leading, spacing: 10, content: {
                            Text("3.")
                            
                            Button("Fetch Member", action: {
                                self.viewModel.fetchMember()
                            })
                        })
                        
                        
                        VStack(alignment: .leading, spacing: 10, content: {
                            Text("4.")
                            
                            Button("Fetch Schedule post", action: {
                                viewModel.fetchScheduledPosts()
                            })
                        })
                        
                        if !viewModel.scheduledPosts.isEmpty {
                            Section("Posts", content: {
                                ForEach(viewModel.scheduledPosts, id: \.self) { post in
                                    Text(post)
                                }
                            })
                        }
                        
                        Section("Post", content: {
                            HootsuitePostView()
                        })
                        
                    })
                    
                } else {
                    Button("Authenticate with Hootsuite") {
                        
                        Task {
                            do {
                                if let token = try await viewModel.authenticate() {
                                    DispatchQueue.main.async {
                                        self.authVM.authToken = token
                                        self.authVM.loggedIn = true
                                    }
                                }
                            } catch {
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            })
            .navigationTitle("Welcome")
            
            .toolbar(content: {
                Button("Logout", action: {
                    authVM.authToken = ""
                    authVM.loggedIn = false
                })
            })
        })
       
    }
}

#Preview {
    AuthView()
}
