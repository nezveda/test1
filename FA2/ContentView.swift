//
//  ContentView.swift
//  FA2
//
//  Created by Květoslav Nezveda on 28.05.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TransactionListView(viewModel: TransactionViewModel(context: viewContext))
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
