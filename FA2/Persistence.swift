//
//  Persistence.swift
//  FA2
//
//  Created by Květoslav Nezveda on 28.05.2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data for preview
        let sampleCategory = Category(context: viewContext)
        sampleCategory.name = "Groceries"
        sampleCategory.type = "expense"
        sampleCategory.color = "blue"
        sampleCategory.icon = "cart"
        
        let sampleAccount = Account(context: viewContext)
        sampleAccount.name = "Cash"
        sampleAccount.type = "cash"
        sampleAccount.initialBalance = 1000
        
        let sampleTransaction = Transaction(context: viewContext)
        sampleTransaction.title = "Weekly Groceries"
        sampleTransaction.amount = 89.99
        sampleTransaction.type = "expense"
        sampleTransaction.date = Date()
        sampleTransaction.category = sampleCategory
        sampleTransaction.account = sampleAccount
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FA2")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
