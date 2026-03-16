import Foundation
import SwiftData

// MARK: - DonationCategory

@Model
final class DonationCategory {
    @Attribute(.unique) var id: UUID
    var name: String
    var typeRaw: String
    var totalAmount: Double
    var paidAmount: Double
    var createdDate: Date
    var notes: String?

    @Relationship(deleteRule: .cascade)
    var transactions: [DonationTransaction] = []

    init(
        id: UUID = UUID(),
        name: String,
        type: DonationType,
        totalAmount: Double = 0,
        paidAmount: Double = 0,
        notes: String? = nil,
        createdDate: Date = .now
    ) {
        self.id = id
        self.name = name
        self.typeRaw = type.rawValue
        self.totalAmount = totalAmount
        self.paidAmount = paidAmount
        self.notes = notes
        self.createdDate = createdDate
    }

    var type: DonationType {
        get { DonationType(rawValue: typeRaw) ?? .custom }
        set { typeRaw = newValue.rawValue }
    }

    var remainingAmount: Double {
        max(0, totalAmount - paidAmount)
    }

    // Single pass over transactions — avoids traversing the array
    // separately for each computed property during a render.
    struct TransactionStats {
        let paidTotal: Double
        let unpaidTotal: Double
        var hasPending: Bool { unpaidTotal > 0 }
    }

    var transactionStats: TransactionStats {
        var paid = 0.0; var unpaid = 0.0
        for tx in transactions {
            if tx.isPaid { paid += tx.amount } else { unpaid += tx.amount }
        }
        return TransactionStats(paidTotal: paid, unpaidTotal: unpaid)
    }

    var accumulatedUnpaidAmount: Double { transactionStats.unpaidTotal }
    var confirmedPaidAmount: Double     { transactionStats.paidTotal }

    var completionPercent: Double {
        guard totalAmount > 0 else { return paidAmount > 0 ? 1 : 0 }
        return min(1, paidAmount / totalAmount)
    }

    var isFullyPaid: Bool      { remainingAmount <= 0 }
    var hasPendingAmount: Bool { accumulatedUnpaidAmount > 0 }
}

// MARK: - DonationTransaction

@Model
final class DonationTransaction {
    @Attribute(.unique) var id: UUID
    var categoryId: UUID
    var amount: Double
    var date: Date
    var notes: String?
    var paymentMethodRaw: String

    /// false = just accumulated/intended (not yet paid)
    /// true  = actually paid / settled
    var isPaid: Bool

    init(
        id: UUID = UUID(),
        categoryId: UUID,
        amount: Double,
        date: Date = .now,
        notes: String? = nil,
        paymentMethod: PaymentMethod = .manual,
        isPaid: Bool = true
    ) {
        self.id = id
        self.categoryId = categoryId
        self.amount = amount
        self.date = date
        self.notes = notes
        self.paymentMethodRaw = paymentMethod.rawValue
        self.isPaid = isPaid
    }

    var paymentMethod: PaymentMethod {
        get { PaymentMethod(rawValue: paymentMethodRaw) ?? .manual }
        set { paymentMethodRaw = newValue.rawValue }
    }
}

// MARK: - DailyTrackerSettings  (lightweight UserDefaults-backed, not SwiftData)

struct DailyTrackerSettings: Codable {
    var dailyAmount: Double = 10
    var startDate: Date = .now
    var isActive: Bool = false

    /// Frozen balance when paused — nil while actively running
    var pausedAccumulatedAmount: Double? = nil

    /// Lifetime total ever converted to transactions
    var totalConverted: Double = 0

    /// Log of past conversion sessions
    var conversionHistory: [ConversionSession] = []

    var accumulatedAmount: Double {
        if let paused = pausedAccumulatedAmount { return paused }
        guard isActive, dailyAmount > 0 else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: startDate, to: .now).day ?? 0
        return Double(max(0, days + 1)) * dailyAmount
    }

    struct ConversionSession: Codable, Identifiable {
        let id: UUID
        let date: Date
        let amount: Double
        let days: Int
        let categoryName: String
        let isPaid: Bool

        init(id: UUID = UUID(), date: Date, amount: Double, days: Int, categoryName: String, isPaid: Bool) {
            self.id = id; self.date = date; self.amount = amount
            self.days = days; self.categoryName = categoryName; self.isPaid = isPaid
        }
    }
}
