import SwiftUI

struct TransactionListView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var showingAddTransaction = false
    @State private var searchText = ""
    @State private var selectedFilter: TransactionFilter = .all
    
    enum TransactionFilter {
        case all, income, expense
    }
    
    private var filteredTransactions: [Transaction] {
        var transactions = viewModel.transactions
        
        // Apply search filter
        if !searchText.isEmpty {
            transactions = transactions.filter {
                $0.wrappedTitle.localizedCaseInsensitiveContains(searchText) ||
                $0.wrappedCategory.wrappedName.localizedCaseInsensitiveContains(searchText) ||
                $0.wrappedAccount.wrappedName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply type filter
        switch selectedFilter {
        case .income:
            transactions = transactions.filter { $0.type == Transaction.TransactionType.income.rawValue }
        case .expense:
            transactions = transactions.filter { $0.type == Transaction.TransactionType.expense.rawValue }
        case .all:
            break
        }
        
        return transactions
    }
    
    var body: some View {
        #if os(macOS)
        HSplitView {
            sidebarContent
                .frame(minWidth: 250, maxWidth: 300)
            mainContent
        }
        .toolbar {
            ToolbarItem {
                Button {
                    showingAddTransaction = true
                } label: {
                    Label("Add Transaction", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView(viewModel: viewModel)
        }
        #else
        NavigationView {
            List {
                sidebarContent
                mainContent
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTransaction = true
                    } label: {
                        Label("Add Transaction", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(viewModel: viewModel)
            }
        }
        #endif
    }
    
    private var sidebarContent: some View {
        List {
            // Monthly Summary Section
            GroupBox("Monthly Summary") {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Income")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.2f Kč", viewModel.monthlyIncome()))
                            .foregroundColor(.green)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Expenses")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "-%.2f Kč", viewModel.monthlyExpenses()))
                            .foregroundColor(.red)
                    }
                }
            }
            
            // Filter Section
            GroupBox("Filter") {
                Picker("Transaction Type", selection: $selectedFilter) {
                    Text("All").tag(TransactionFilter.all)
                    Text("Income").tag(TransactionFilter.income)
                    Text("Expenses").tag(TransactionFilter.expense)
                }
                .pickerStyle(.segmented)
                
                TextField("Search transactions...", text: $searchText)
            }
        }
        .adaptiveListStyle(.sidebar)
    }
    
    private var mainContent: some View {
        List {
            // Transactions Section
            GroupBox("Transactions") {
                ForEach(filteredTransactions, id: \.self) { transaction in
                    TransactionRowView(transaction: transaction)
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.deleteTransaction(transaction)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .adaptiveListStyle(.main)
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    private var formattedAmount: String {
        let isExpense = transaction.type == Transaction.TransactionType.expense.rawValue
        return String(format: isExpense ? "-%.2f Kč" : "%.2f Kč", transaction.amount)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.wrappedTitle)
                    .font(.headline)
                Text(transaction.wrappedCategory.wrappedName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(formattedAmount)
                    .foregroundColor(transaction.type == Transaction.TransactionType.income.rawValue ? .green : .red)
                Text(transaction.wrappedDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return TransactionListView(viewModel: TransactionViewModel(context: context))
} 