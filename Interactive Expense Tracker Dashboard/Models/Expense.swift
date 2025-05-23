import Foundation

struct Expense: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let description: String
    let date: Date
    let category: ExpenseCategory
    
    init(id: UUID = UUID(), amount: Double, description: String, date: Date = Date(), category: ExpenseCategory) {
        self.id = id
        self.amount = amount
        self.description = description
        self.date = date
        self.category = category
    }
} 