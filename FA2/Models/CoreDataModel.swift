import Foundation
import CoreData

// MARK: - Transaction Entity
extension Transaction {
    // Transaction Types
    enum TransactionType: String {
        case income
        case expense
    }
    
    // Computed properties
    var wrappedTitle: String {
        title ?? "Untitled Transaction"
    }
    
    var wrappedDescription: String {
        description ?? ""
    }
    
    var wrappedDate: Date {
        date ?? Date()
    }
    
    var wrappedCategory: Category {
        category ?? Category()
    }
    
    var wrappedAccount: Account {
        account ?? Account()
    }
    
    var wrappedTags: Set<Tag> {
        (tags as? Set<Tag>) ?? []
    }
}

// MARK: - Category Entity
extension Category {
    var wrappedName: String {
        name ?? "Uncategorized"
    }
    
    var wrappedTransactions: Set<Transaction> {
        (transactions as? Set<Transaction>) ?? []
    }
    
    var transactionsArray: [Transaction] {
        let set = wrappedTransactions
        return set.sorted { $0.wrappedDate > $1.wrappedDate }
    }
}

// MARK: - Account Entity
extension Account {
    var wrappedName: String {
        name ?? "Unknown Account"
    }
    
    var wrappedTransactions: Set<Transaction> {
        (transactions as? Set<Transaction>) ?? []
    }
    
    var balance: Double {
        let income = wrappedTransactions
            .filter { $0.type == Transaction.TransactionType.income.rawValue }
            .reduce(0) { $0 + $1.amount }
        
        let expenses = wrappedTransactions
            .filter { $0.type == Transaction.TransactionType.expense.rawValue }
            .reduce(0) { $0 + $1.amount }
        
        return income - expenses
    }
}

// MARK: - Budget Entity
extension Budget {
    var wrappedName: String {
        name ?? "Unnamed Budget"
    }
    
    var wrappedCategory: Category {
        category ?? Category()
    }
    
    var progress: Double {
        let spent = wrappedCategory.wrappedTransactions
            .filter { $0.date?.isInCurrentMonth ?? false }
            .reduce(0) { $0 + $1.amount }
        
        return (spent / amount) * 100
    }
}

// MARK: - FinancialGoal Entity
extension FinancialGoal {
    var wrappedTitle: String {
        title ?? "Unnamed Goal"
    }
    
    var wrappedDescription: String {
        description ?? ""
    }
    
    var progress: Double {
        (currentAmount / targetAmount) * 100
    }
    
    var remainingAmount: Double {
        targetAmount - currentAmount
    }
    
    var isCompleted: Bool {
        currentAmount >= targetAmount
    }
}

// MARK: - Tag Entity
extension Tag {
    var wrappedName: String {
        name ?? "Unnamed Tag"
    }
    
    var wrappedTransactions: Set<Transaction> {
        (transactions as? Set<Transaction>) ?? []
    }
}

// MARK: - Date Helper
extension Date {
    var isInCurrentMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
} 