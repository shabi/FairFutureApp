import Foundation
import SwiftData
import Combine

// MARK: - DashboardViewModel

@MainActor
final class DashboardViewModel: ObservableObject {

    @Published var showAddCategory = false
    @Published var showAddTransaction = false
    @Published var selectedCategory: DonationCategory?
    @Published var errorMessage: String?

    private let service: DonationServiceProtocol

    init(service: DonationServiceProtocol? = nil) {
        self.service = service ?? DonationService.shared
    }

    // MARK: Computed summaries

    func totalObligation(from categories: [DonationCategory]) -> Double {
        categories.reduce(0) { $0 + $1.totalAmount }
    }

    func totalPaid(from categories: [DonationCategory]) -> Double {
        categories.reduce(0) { $0 + $1.paidAmount }
    }

    func totalRemaining(from categories: [DonationCategory]) -> Double {
        categories.reduce(0) { $0 + $1.remainingAmount }
    }

    func overallProgress(from categories: [DonationCategory]) -> Double {
        let obligation = totalObligation(from: categories)
        guard obligation > 0 else { return 0 }
        return min(1, totalPaid(from: categories) / obligation)
    }

    // MARK: Monthly chart data

    struct MonthlyDataPoint: Identifiable {
        let id = UUID()
        let month: String
        let amount: Double
        let date: Date
    }
    
    func monthlyChartData(from categories: [DonationCategory]) -> [MonthlyDataPoint] {
        var grouped: [Date: Double] = [:]
        let calendar = Calendar.current

        for cat in categories {
            for tx in cat.transactions {
                let components = calendar.dateComponents([.year, .month], from: tx.date)
                if let monthStart = calendar.date(from: components) {
                    grouped[monthStart, default: 0] += tx.amount
                }
            }
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yy"

        return grouped
            .sorted { $0.key < $1.key }
            .suffix(12)
            .map { MonthlyDataPoint(month: formatter.string(from: $0.key), amount: $0.value, date: $0.key) }
    }

    // MARK: Actions

    func addCategory(name: String, type: DonationType, totalAmount: Double, context: ModelContext) {
        do {
            try service.createCategory(name: name, type: type, totalAmount: totalAmount, notes: nil, context: context)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteCategory(_ category: DonationCategory, context: ModelContext) {
        do {
            try service.deleteCategory(category, context: context)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
