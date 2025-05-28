import Foundation
import CoreData
import SwiftUI

class TransactionViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    @Published var transactions: [Transaction] = []
    @Published var categories: [Category] = []
    @Published var accounts: [Account] = []
    @Published var tags: [Tag] = []
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchTransactions()
        fetchCategories()
        fetchAccounts()
        fetchTags()
    }
    
    // MARK: - Fetch Methods
    
    func fetchTransactions() {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        
        do {
            transactions = try viewContext.fetch(request)
        } catch {
            print("Error fetching transactions: \(error)")
        }
    }
    
    func fetchCategories() {
        let request = NSFetchRequest<Category>(entityName: "Category")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        
        do {
            categories = try viewContext.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
        }
    }
    
    func fetchAccounts() {
        let request = NSFetchRequest<Account>(entityName: "Account")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Account.name, ascending: true)]
        
        do {
            accounts = try viewContext.fetch(request)
        } catch {
            print("Error fetching accounts: \(error)")
        }
    }
    
    func fetchTags() {
        let request = NSFetchRequest<Tag>(entityName: "Tag")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
        
        do {
            tags = try viewContext.fetch(request)
        } catch {
            print("Error fetching tags: \(error)")
        }
    }
    
    // MARK: - CRUD Operations
    
    func addTransaction(title: String, amount: Double, type: Transaction.TransactionType, date: Date, category: Category, account: Account, notes: String? = nil, tags: Set<Tag> = []) {
        let transaction = Transaction(context: viewContext)
        transaction.title = title
        transaction.amount = amount
        transaction.type = type.rawValue
        transaction.date = date
        transaction.category = category
        transaction.account = account
        transaction.notes = notes
        
        tags.forEach { tag in
            transaction.addToTags(tag)
        }
        
        saveContext()
        fetchTransactions()
    }
    
    func updateTransaction(_ transaction: Transaction, title: String, amount: Double, type: Transaction.TransactionType, date: Date, category: Category, account: Account, notes: String? = nil, tags: Set<Tag> = []) {
        transaction.title = title
        transaction.amount = amount
        transaction.type = type.rawValue
        transaction.date = date
        transaction.category = category
        transaction.account = account
        transaction.notes = notes
        
        // Remove all existing tags
        if let existingTags = transaction.tags as? Set<Tag> {
            existingTags.forEach { tag in
                transaction.removeFromTags(tag)
            }
        }
        
        // Add new tags
        tags.forEach { tag in
            transaction.addToTags(tag)
        }
        
        saveContext()
        fetchTransactions()
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        viewContext.delete(transaction)
        saveContext()
        fetchTransactions()
    }
    
    // MARK: - Category Management
    
    func addCategory(name: String, type: String, color: String? = nil, icon: String? = nil) {
        let category = Category(context: viewContext)
        category.name = name
        category.type = type
        category.color = color
        category.icon = icon
        
        saveContext()
        fetchCategories()
    }
    
    // MARK: - Account Management
    
    func addAccount(name: String, type: String, initialBalance: Double = 0.0) {
        let account = Account(context: viewContext)
        account.name = name
        account.type = type
        account.initialBalance = initialBalance
        
        saveContext()
        fetchAccounts()
    }
    
    // MARK: - Tag Management
    
    func addTag(name: String, color: String? = nil) {
        let tag = Tag(context: viewContext)
        tag.name = name
        tag.color = color
        
        saveContext()
        fetchTags()
    }
    
    // MARK: - Helper Methods
    
    private func saveContext() {
        do {
            print("Attempting to save context...")
            try viewContext.save()
            print("Context saved successfully")
        } catch {
            print("Error saving context: \(error)")
            print("Detailed error: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("NSError details - Domain: \(nsError.domain), Code: \(nsError.code)")
                print("User info: \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Statistics and Analytics
    
    func monthlyExpenses(for month: Date = Date()) -> Double {
        return transactions
            .filter { $0.type == Transaction.TransactionType.expense.rawValue }
            .filter { Calendar.current.isDate($0.wrappedDate, equalTo: month, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }
    
    func monthlyIncome(for month: Date = Date()) -> Double {
        return transactions
            .filter { $0.type == Transaction.TransactionType.income.rawValue }
            .filter { Calendar.current.isDate($0.wrappedDate, equalTo: month, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }
    
    func expensesByCategory(for month: Date = Date()) -> [(Category, Double)] {
        let monthlyTransactions = transactions.filter {
            $0.type == Transaction.TransactionType.expense.rawValue &&
            Calendar.current.isDate($0.wrappedDate, equalTo: month, toGranularity: .month)
        }
        
        var categoryTotals: [Category: Double] = [:]
        
        for transaction in monthlyTransactions {
            let category = transaction.wrappedCategory
            categoryTotals[category, default: 0] += transaction.amount
        }
        
        return categoryTotals.sorted { $0.value > $1.value }
    }
} 