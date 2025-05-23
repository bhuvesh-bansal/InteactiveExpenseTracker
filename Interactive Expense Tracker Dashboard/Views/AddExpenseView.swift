import SwiftUI

struct AddExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var expenseManager: ExpenseManager
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var date = Date()
    @State private var category: ExpenseCategory = .other
    
    var onSave: (Expense) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Amount")) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Description")) {
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveExpense()
                }
                .disabled(amount.isEmpty || description.isEmpty)
            )
        }
    }
    
    private func saveExpense() {
        guard let amountDouble = Double(amount) else { return }
        
        let expense = Expense(
            amount: amountDouble,
            description: description,
            date: date,
            category: category
        )
        
        onSave(expense)
        presentationMode.wrappedValue.dismiss()
    }
} 