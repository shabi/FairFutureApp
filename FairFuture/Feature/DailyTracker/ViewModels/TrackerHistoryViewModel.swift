
import Combine
import Foundation
import SwiftData

// MARK: - Notification name for external resets

extension Notification.Name {
    static let trackerDidReset = Notification.Name("trackerDidReset")
}

// MARK: - DailyTrackerViewModel

@MainActor
final class DailyTrackerViewModel: ObservableObject {

    @Published var settings: DailyTrackerSettings
    @Published var dailyAmountInput: String = ""
    @Published var showConvertSheet = false

    /// When converting, which payment mode the user chose
    @Published var convertIsPaid: Bool = true

    private let key = "daily_tracker_settings"
    private let service: DonationServiceProtocol
    
    init(service: DonationServiceProtocol? = nil) {
        self.service = service ?? DonationService.shared
        if let data = UserDefaults.standard.data(forKey: "daily_tracker_settings"),
           let decoded = try? JSONDecoder().decode(DailyTrackerSettings.self, from: data) {
            settings = decoded
        } else {
            settings = DailyTrackerSettings()
        }
        dailyAmountInput = String(format: "%.0f", settings.dailyAmount)
        
        // Listen for resets triggered from SettingsView
        Task { @MainActor in
            for await _ in NotificationCenter.default.notifications(named: .trackerDidReset) {
                resetInMemory()
            }
        }
    }

    // MARK: Reset

    /// Wipes all in-memory tracker state and removes the UserDefaults entry.
    /// Called directly or via the trackerDidReset notification.
    func resetInMemory() {
        UserDefaults.standard.removeObject(forKey: key)
        settings = DailyTrackerSettings()
        dailyAmountInput = String(format: "%.0f", settings.dailyAmount)
    }

    // MARK: Computed

    var accumulatedAmount: Double { settings.accumulatedAmount }

    var daysSinceStart: Int {
        guard settings.isActive else { return 0 }
        return max(0, Calendar.current.dateComponents([.day], from: settings.startDate, to: .now).day ?? 0)
    }

    /// Total ever converted to transactions across all sessions
    var totalConverted: Double { settings.totalConverted }

    /// Sessions log for display
    var conversionHistory: [DailyTrackerSettings.ConversionSession] {
        settings.conversionHistory.sorted { $0.date > $1.date }
    }

    var hasHistory: Bool { !settings.conversionHistory.isEmpty }

    // MARK: Controls

    func startTracking() {
        settings.isActive = true
        settings.startDate = .now
        if let amount = Double(dailyAmountInput), amount > 0 {
            settings.dailyAmount = amount
        }
        persist()
    }

    /// Pause keeps the accumulated amount frozen — does NOT reset startDate.
    func pauseTracking() {
        settings.isActive = false
        // Snapshot the current accumulated amount so it survives the pause
        settings.pausedAccumulatedAmount = accumulatedAmount
        persist()
    }

    /// Resume from where we paused — resets startDate so we don't double-count.
    func resumeTracking() {
        settings.isActive = true
        settings.startDate = .now
        // Clear the paused snapshot so live accumulation takes over
        settings.pausedAccumulatedAmount = nil
        persist()
    }

    func updateDailyAmount() {
        guard let amount = Double(dailyAmountInput), amount > 0 else { return }
        settings.dailyAmount = amount
        persist()
    }

    // MARK: Convert

    /// Convert accumulated sadaqah to a transaction.
    /// isPaid=true  → records as paid immediately
    /// isPaid=false → records as set-aside (pending), user pays later
    func convertToTransaction(
        category: DonationCategory,
        context: ModelContext,
        isPaid: Bool
    ) throws {
        let amount = accumulatedAmount
        guard amount > 0 else { return }

        let days = daysSinceStart + 1
        let notes = isPaid
            ? "Daily sadaqah — \(days) day\(days == 1 ? "" : "s") × ₹\(String(format: "%.0f", settings.dailyAmount))"
            : "Set aside — \(days) day\(days == 1 ? "" : "s") × ₹\(String(format: "%.0f", settings.dailyAmount)) (pending payment)"

        try service.addTransaction(
            to: category,
            amount: amount,
            date: .now,
            notes: notes,
            paymentMethod: .manual,
            isPaid: isPaid,
            context: context
        )

        // Log this session
        let session = DailyTrackerSettings.ConversionSession(
            date: .now,
            amount: amount,
            days: days,
            categoryName: category.name,
            isPaid: isPaid
        )
        settings.conversionHistory.append(session)
        settings.totalConverted += amount

        // Reset tracker for next cycle
        settings.startDate = .now
        settings.pausedAccumulatedAmount = nil
        // Keep isActive as-is so tracker continues running
        persist()
    }

    // MARK: Persist

    private func persist() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}

// MARK: - TransactionHistoryViewModel

@MainActor
final class TransactionHistoryViewModel: ObservableObject {

    enum SortOption: String, CaseIterable {
        case dateDesc   = "Newest First"
        case dateAsc    = "Oldest First"
        case amountDesc = "Highest Amount"
        case amountAsc  = "Lowest Amount"
    }

    enum FilterOption: String, CaseIterable {
        case all     = "All"
        case paid    = "Paid"
        case pending = "Pending"
    }

    @Published var sortOption: SortOption = .dateDesc
    @Published var filterOption: FilterOption = .all
    @Published var selectedCategory: DonationCategory? = nil
    @Published var searchText: String = ""

    struct MonthGroup: Identifiable {
        let id: String
        let transactions: [(DonationTransaction, DonationCategory)]
        var paidTotal:    Double { transactions.filter { $0.0.isPaid  }.reduce(0) { $0 + $1.0.amount } }
        var pendingTotal: Double { transactions.filter { !$0.0.isPaid }.reduce(0) { $0 + $1.0.amount } }
        var total: Double { transactions.reduce(0) { $0 + $1.0.amount } }
    }

    func groupedTransactions(categories: [DonationCategory]) -> [MonthGroup] {
        var all: [(DonationTransaction, DonationCategory)] = []

        for cat in categories {
            if let filter = selectedCategory, filter.id != cat.id { continue }
            for tx in cat.transactions {
                // Status filter
                switch filterOption {
                case .paid:    if !tx.isPaid { continue }
                case .pending: if tx.isPaid  { continue }
                case .all: break
                }
                // Search filter
                if !searchText.isEmpty {
                    let matches = cat.name.localizedCaseInsensitiveContains(searchText)
                        || (tx.notes?.localizedCaseInsensitiveContains(searchText) == true)
                        || tx.paymentMethod.rawValue.localizedCaseInsensitiveContains(searchText)
                    if !matches { continue }
                }
                all.append((tx, cat))
            }
        }

        let sorted: [(DonationTransaction, DonationCategory)]
        switch sortOption {
        case .dateDesc:   sorted = all.sorted { $0.0.date > $1.0.date }
        case .dateAsc:    sorted = all.sorted { $0.0.date < $1.0.date }
        case .amountDesc: sorted = all.sorted { $0.0.amount > $1.0.amount }
        case .amountAsc:  sorted = all.sorted { $0.0.amount < $1.0.amount }
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        _ = Calendar.current
        var grouped: [(String, [(DonationTransaction, DonationCategory)])] = []

        for pair in sorted {
            let key = formatter.string(from: pair.0.date)
            if let idx = grouped.firstIndex(where: { $0.0 == key }) {
                grouped[idx].1.append(pair)
            } else {
                grouped.append((key, [pair]))
            }
        }

        return grouped.map { MonthGroup(id: $0.0, transactions: $0.1) }
    }
}
