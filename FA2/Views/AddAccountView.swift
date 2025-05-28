import SwiftUI

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    
    @State private var name = ""
    @State private var type = "checking"
    @State private var initialBalance = ""
    
    private let accountTypes = ["checking", "savings", "cash", "credit", "investment"]
    
    private var isFormValid: Bool {
        !name.isEmpty && !initialBalance.isEmpty && Double(initialBalance) != nil
    }
    
    var body: some View {
        VStack {
            Form {
                GroupBox("Account Information") {
                    TextField("Account Name", text: $name)
                    
                    Picker("Account Type", selection: $type) {
                        ForEach(accountTypes, id: \.self) { type in
                            Text(type.capitalized)
                                .tag(type)
                        }
                    }
                    
                    TextField("Initial Balance", text: $initialBalance)
                        .decimalTextField()
                }
            }
            .formStyle(.grouped)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Save") {
                    saveAccount()
                }
                .disabled(!isFormValid)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 400, height: 300)
    }
    
    private func saveAccount() {
        guard let initialBalance = Double(initialBalance) else { return }
        
        viewModel.addAccount(
            name: name,
            type: type,
            initialBalance: initialBalance
        )
        dismiss()
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return AddAccountView(viewModel: TransactionViewModel(context: context))
} 