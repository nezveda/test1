import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    
    @State private var title = ""
    @State private var amount = ""
    @State private var type: Transaction.TransactionType = .expense
    @State private var date = Date()
    @State private var selectedCategory: Category?
    @State private var selectedAccount: Account?
    @State private var notes = ""
    @State private var selectedTags: Set<Tag> = []
    
    @State private var showingAddCategory = false
    @State private var showingAddAccount = false
    
    private var isFormValid: Bool {
        !title.isEmpty &&
        !amount.isEmpty &&
        Double(amount) != nil &&
        selectedCategory != nil &&
        selectedAccount != nil
    }
    
    var body: some View {
        VStack {
            Form {
                GroupBox("Basic Information") {
                    TextField("Title", text: $title)
                    
                    TextField("Amount", text: $amount)
                        .decimalTextField()
                    
                    Picker("Type", selection: $type) {
                        Text("Expense").tag(Transaction.TransactionType.expense)
                        Text("Income").tag(Transaction.TransactionType.income)
                    }
                    .pickerStyle(.segmented)
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                }
                
                GroupBox("Category") {
                    if viewModel.categories.isEmpty {
                        Button("Add Category") {
                            showingAddCategory = true
                        }
                    } else {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(viewModel.categories, id: \.self) { category in
                                Text(category.wrappedName).tag(Optional(category))
                            }
                        }
                    }
                }
                
                GroupBox("Account") {
                    if viewModel.accounts.isEmpty {
                        Button("Add Account") {
                            showingAddAccount = true
                        }
                    } else {
                        Picker("Account", selection: $selectedAccount) {
                            ForEach(viewModel.accounts, id: \.self) { account in
                                Text(account.wrappedName).tag(Optional(account))
                            }
                        }
                    }
                }
                
                GroupBox("Tags") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.tags, id: \.self) { tag in
                                TagView(tag: tag, isSelected: selectedTags.contains(tag)) {
                                    if selectedTags.contains(tag) {
                                        selectedTags.remove(tag)
                                    } else {
                                        selectedTags.insert(tag)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                GroupBox("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .adaptiveFormStyle()
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Save") {
                    saveTransaction()
                }
                .disabled(!isFormValid)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        #if os(macOS)
        .frame(width: 500, height: 700)
        #endif
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView(viewModel: viewModel)
        }
    }
    
    private func saveTransaction() {
        print("Attempting to save transaction...")
        print("Title: \(title)")
        print("Amount string: \(amount)")
        print("Type: \(type)")
        print("Date: \(date)")
        print("Selected category: \(String(describing: selectedCategory?.wrappedName))")
        print("Selected account: \(String(describing: selectedAccount?.wrappedName))")
        print("Notes: \(notes)")
        print("Selected tags count: \(selectedTags.count)")
        
        guard let amount = Double(amount),
              let category = selectedCategory,
              let account = selectedAccount else {
            print("Failed to save - missing required data:")
            if Double(amount) == nil { print("- Invalid amount format") }
            if selectedCategory == nil { print("- No category selected") }
            if selectedAccount == nil { print("- No account selected") }
            return
        }
        
        print("All required data present, calling viewModel.addTransaction...")
        
        viewModel.addTransaction(
            title: title,
            amount: amount,
            type: type,
            date: date,
            category: category,
            account: account,
            notes: notes.isEmpty ? nil : notes,
            tags: selectedTags
        )
        
        dismiss()
    }
}

struct TagView: View {
    let tag: Tag
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag.wrappedName)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return AddTransactionView(viewModel: TransactionViewModel(context: context))
} 