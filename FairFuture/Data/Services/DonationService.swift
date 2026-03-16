import Foundation
import SwiftData

// MARK: - DonationServiceProtocol

protocol DonationServiceProtocol {
    func addTransaction(to category: DonationCategory, amount: Double, date: Date, notes: String?, paymentMethod: PaymentMethod, isPaid: Bool, context: ModelContext) throws
    func markAsPaid(_ transaction: DonationTransaction, category: DonationCategory, context: ModelContext) throws
    func createCategory(name: String, type: DonationType, totalAmount: Double, notes: String?, context: ModelContext) throws
    func deleteTransaction(_ transaction: DonationTransaction, from category: DonationCategory, context: ModelContext) throws
    func deleteCategory(_ category: DonationCategory, context: ModelContext) throws
    func resetAllTransactions(categories: [DonationCategory], context: ModelContext) throws
    func resetEverything(categories: [DonationCategory], context: ModelContext) throws
}

final class DonationService: DonationServiceProtocol {
    static let shared = DonationService()

    func addTransaction(
        to category: DonationCategory,
        amount: Double,
        date: Date,
        notes: String?,
        paymentMethod: PaymentMethod,
        isPaid: Bool,
        context: ModelContext
    ) throws {
        let tx = DonationTransaction(
            categoryId: category.id,
            amount: amount,
            date: date,
            notes: notes?.isEmpty == true ? nil : notes,
            paymentMethod: paymentMethod,
            isPaid: isPaid
        )
        context.insert(tx)
        category.transactions.append(tx)
        // Only count toward paidAmount when money is actually paid
        if isPaid { category.paidAmount += amount }
        try context.save()
    }

    /// Marks an accumulated (isPaid=false) transaction as actually paid.
    func markAsPaid(_ transaction: DonationTransaction, category: DonationCategory, context: ModelContext) throws {
        guard !transaction.isPaid else { return }
        transaction.isPaid = true
        category.paidAmount += transaction.amount
        try context.save()
    }

    func createCategory(
        name: String,
        type: DonationType,
        totalAmount: Double,
        notes: String?,
        context: ModelContext
    ) throws {
        let cat = DonationCategory(
            name: name,
            type: type,
            totalAmount: totalAmount,
            notes: notes?.isEmpty == true ? nil : notes
        )
        context.insert(cat)
        try context.save()
    }

    func deleteTransaction(
        _ transaction: DonationTransaction,
        from category: DonationCategory,
        context: ModelContext
    ) throws {
        if transaction.isPaid {
            category.paidAmount = max(0, category.paidAmount - transaction.amount)
        }
        category.transactions.removeAll { $0.id == transaction.id }
        context.delete(transaction)
        try context.save()
    }

    func deleteCategory(_ category: DonationCategory, context: ModelContext) throws {
        context.delete(category)
        try context.save()
    }

    // MARK: - Reset

    func resetAllTransactions(categories: [DonationCategory], context: ModelContext) throws {
        for category in categories {
            for tx in category.transactions { context.delete(tx) }
            category.transactions.removeAll()
            category.paidAmount = 0
        }
        try context.save()
    }

    func resetEverything(categories: [DonationCategory], context: ModelContext) throws {
        for category in categories { context.delete(category) }
        try context.save()
    }
}
