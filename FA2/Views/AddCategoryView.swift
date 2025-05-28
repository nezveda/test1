import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    
    @State private var name = ""
    @State private var type = "expense"
    @State private var color = "blue"
    @State private var icon = "tag"
    
    private let types = ["expense", "income", "both"]
    private let colors = ["blue", "red", "green", "yellow", "purple", "orange"]
    private let icons = ["tag", "cart", "car", "house", "fork.knife", "gift", "medical", "airplane", "tram", "creditcard"]
    
    private var isFormValid: Bool {
        !name.isEmpty
    }
    
    var body: some View {
        VStack {
            Form {
                GroupBox("Basic Information") {
                    TextField("Category Name", text: $name)
                    
                    Picker("Type", selection: $type) {
                        Text("Expense").tag("expense")
                        Text("Income").tag("income")
                        Text("Both").tag("both")
                    }
                }
                
                GroupBox("Appearance") {
                    Picker("Color", selection: $color) {
                        ForEach(colors, id: \.self) { color in
                            HStack {
                                Circle()
                                    .fill(Color(color))
                                    .frame(width: 20, height: 20)
                                Text(color.capitalized)
                            }
                            .tag(color)
                        }
                    }
                    
                    Picker("Icon", selection: $icon) {
                        ForEach(icons, id: \.self) { icon in
                            Label(icon.capitalized, systemImage: icon)
                                .tag(icon)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Save") {
                    saveCategory()
                }
                .disabled(!isFormValid)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 400, height: 500)
    }
    
    private func saveCategory() {
        viewModel.addCategory(
            name: name,
            type: type,
            color: color,
            icon: icon
        )
        dismiss()
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return AddCategoryView(viewModel: TransactionViewModel(context: context))
} 