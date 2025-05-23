import Foundation

enum ExpenseCategory: String, CaseIterable, Codable {
    case food = "Food"
    case transport = "Transport"
    case utilities = "Utilities"
    case entertainment = "Entertainment"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .utilities: return "bolt.fill"
        case .entertainment: return "tv.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .food: return "systemGreen"
        case .transport: return "systemBlue"
        case .utilities: return "systemOrange"
        case .entertainment: return "systemPurple"
        case .other: return "systemGray"
        }
    }
} 