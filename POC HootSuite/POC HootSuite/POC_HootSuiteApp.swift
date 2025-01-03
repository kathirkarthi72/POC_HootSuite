//
//  POC_HootSuiteApp.swift
//  POC HootSuite
//
//  Created by Kathiresan on 03/01/25.
//

import SwiftUI
import SwiftData

@main
struct POC_HootSuiteApp: App {
    
    @StateObject var authVM = AuthVM()
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        
        WindowGroup {
            AuthView()
                .environmentObject(authVM)
//            ContentView()
        }
//        .modelContainer(sharedModelContainer)
    }
}
