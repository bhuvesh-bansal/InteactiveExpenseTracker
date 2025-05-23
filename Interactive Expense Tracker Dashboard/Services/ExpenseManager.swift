import Foundation
import Combine

// MARK: - Delegate Protocol
protocol ExpenseManagerDelegate: AnyObject {
    func expenseManagerDidUpdate(_ manager: ExpenseManager)
}

class ExpenseManager: ObservableObject {
    static let shared = ExpenseManager()
    @Published private(set) var expenses: [Expense] = []
    @Published var selectedCategory: ExpenseCategory?
    
    // Add delegate for notifying changes
    weak var delegate: ExpenseManagerDelegate?
    
    private init() {
        // Populate with mock expenses
        expenses = MockData.generateMockExpenses()
    }
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        delegate?.expenseManagerDidUpdate(self)
    }
    
    func expenses(for category: ExpenseCategory?) -> [Expense] {
        guard let category = category else { return expenses }
        return expenses.filter { $0.category == category }
    }
    
    func expenses(in dateRange: ClosedRange<Date>) -> [Expense] {
        return expenses.filter { dateRange.contains($0.date) }
    }
    
    func total(for category: ExpenseCategory) -> Double {
        expenses.filter { $0.category == category }.reduce(0) { $0 + $1.amount }
    }
    
    func totalAllCategories() -> Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    func recentExpenses(limit: Int = 10) -> [Expense] {
        Array(expenses.sorted { $0.date > $1.date }.prefix(limit))
    }
}

// MARK: - Mock Data
struct MockData {
    static func generateMockExpenses() -> [Expense] {
        let categories = ExpenseCategory.allCases
        let descriptions = [
            "Grocery shopping",
            "Gas station",
            "Electricity bill",
            "Movie tickets",
            "Restaurant dinner",
            "Bus fare",
            "Water bill",
            "Concert tickets",
            "Coffee shop",
            "Taxi ride",
            "Internet bill",
            "Netflix subscription",
            "Lunch at work",
            "Train ticket",
            "Phone bill"
        ]
        
        return (0..<15).map { index in
            Expense(
                amount: Double.random(in: 5...500),
                description: descriptions[index],
                date: Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date(),
                category: categories[index % categories.count]
            )
        }
    }
} 