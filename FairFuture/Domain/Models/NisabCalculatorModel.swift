import Foundation
import SwiftUI

// MARK: - NisabStandard
// Scholars differ on whether to use gold or silver nisab.
// Silver nisab is lower — more conservative/inclusive approach.

enum NisabStandard: String, CaseIterable, Identifiable, Codable {
    case gold   = "Gold (85g)"
    case silver = "Silver (595g)"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .gold:   return "Nisab = current value of 85g of gold. Most common in South Asia."
        case .silver: return "Nisab = current value of 595g of silver. More conservative threshold."
        }
    }

    var goldGrams:   Double { 85 }
    var silverGrams: Double { 595 }
}

// MARK: - AssetCategory

enum AssetCategory: String, CaseIterable, Identifiable {
    // Assets
    case cashAndBank        = "Cash & Bank Balance"
    case gold               = "Gold"
    case silver             = "Silver"
    case investments        = "Stocks & Investments"
    case businessInventory  = "Business Inventory"
    case moneOwed           = "Money Owed to You"
    case other              = "Other Assets"

    // Liabilities (subtracted)
    case debtsOwed          = "Debts You Owe"
    case billsDue           = "Bills Due This Month"
    case otherLiabilities   = "Other Liabilities"

    var id: String { rawValue }

    var isLiability: Bool {
        switch self {
        case .debtsOwed, .billsDue, .otherLiabilities: return true
        default: return false
        }
    }

    var icon: String {
        switch self {
        case .cashAndBank:        return "banknote"
        case .gold:               return "circle.fill"
        case .silver:             return "circle"
        case .investments:        return "chart.line.uptrend.xyaxis"
        case .businessInventory:  return "shippingbox"
        case .moneOwed:           return "person.badge.clock"
        case .other:              return "ellipsis.circle"
        case .debtsOwed:          return "arrow.down.circle"
        case .billsDue:           return "calendar.badge.minus"
        case .otherLiabilities:   return "minus.circle"
        }
    }

    var color: Color {
        isLiability ? .red.opacity(0.8) : Color(hex: "#2E7D6B")
    }

    var hint: String {
        switch self {
        case .cashAndBank:
            return "Include all cash at home, current accounts, savings accounts, and any mobile wallets."
        case .gold:
            return "Enter the current market value of all gold you own (jewellery, coins, bars). Gold worn daily for personal use may be excluded — consult your scholar."
        case .silver:
            return "Enter the current market value of all silver you own."
        case .investments:
            return "Include stocks at current market value, mutual funds, fixed deposits, provident fund balance."
        case .businessInventory:
            return "Enter the wholesale/cost value of goods you hold for sale if you run a business."
        case .moneOwed:
            return "Money genuinely owed to you and likely to be repaid within the year."
        case .other:
            return "Any other asset with monetary value not listed above."
        case .debtsOwed:
            return "Loans you must repay — bank loans, personal loans, credit card dues."
        case .billsDue:
            return "Regular bills, rent, utilities due within this month."
        case .otherLiabilities:
            return "Any other payments you owe that are due within the Zakat year."
        }
    }

    /// True if this category needs weight input (gold/silver in grams)
    var needsWeightInput: Bool {
        self == .gold || self == .silver
    }
}

// MARK: - NisabCalculatorState
// Persisted to UserDefaults as Codable. Allows users to save their
// asset values and come back without re-entering everything.

struct NisabCalculatorState: Codable {
    // Metal prices (per gram, INR)
    var goldPricePerGram:   Double = 7_200   // approximate 2025 rate
    var silverPricePerGram: Double = 88      // approximate 2025 rate
    var priceLastUpdated:   Date   = .now

    // Asset values (INR)
    var cashAndBank:        Double = 0
    var goldGrams:          Double = 0       // user enters grams, app calculates value
    var silverGrams:        Double = 0
    var investments:        Double = 0
    var businessInventory:  Double = 0
    var moneyOwed:          Double = 0
    var otherAssets:        Double = 0

    // Liabilities (INR)
    var debtsOwed:          Double = 0
    var billsDue:           Double = 0
    var otherLiabilities:   Double = 0

    // Settings
    var nisabStandard:      NisabStandard = .gold
    var fitraPerHead:       Double = 120     // INR per person
    var fitraMembers:       Int    = 1

    // MARK: Computed

    var goldValue:    Double { goldGrams   * goldPricePerGram  }
    var silverValue:  Double { silverGrams * silverPricePerGram }

    var totalAssets: Double {
        cashAndBank + goldValue + silverValue +
        investments + businessInventory + moneyOwed + otherAssets
    }

    var totalLiabilities: Double {
        debtsOwed + billsDue + otherLiabilities
    }

    var netWorth: Double {
        max(0, totalAssets - totalLiabilities)
    }

    // Nisab threshold in INR
    var nisabThreshold: Double {
        switch nisabStandard {
        case .gold:   return 85  * goldPricePerGram
        case .silver: return 595 * silverPricePerGram
        }
    }

    var isAboveNisab: Bool {
        netWorth >= nisabThreshold
    }

    // Zakat due = 2.5% of net worth (if above nisab)
    var zakatDue: Double {
        isAboveNisab ? netWorth * 0.025 : 0
    }

    // Fitra total
    var fitraTotal: Double {
        Double(fitraMembers) * fitraPerHead
    }

    // Khums = 20% of annual surplus (user enters surplus manually)
    // We don't calculate surplus automatically — too complex to generalise
}
