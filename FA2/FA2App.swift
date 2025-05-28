//
//  FA2App.swift
//  FA2
//
//  Created by Květoslav Nezveda on 28.05.2025.
//

import SwiftUI

@main
struct FA2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
