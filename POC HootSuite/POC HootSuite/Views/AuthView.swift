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
        VStack {

            if authVM.loggedIn {
                Text("Status code: \(authVM.authToken)")
                
                Button("Fetch Schedule post", action: {
                    viewModel.fetchScheduledPosts(authVM.authToken)
                })
                
                List(viewModel.scheduledPosts, id: \.self) { post in
                    Text(post)
                }                
            } else {
                Button("Authenticate with Hootsuite") {
                    viewModel.authenticate()
                }
            }
        }
    }
}

#Preview {
    AuthView()
}
