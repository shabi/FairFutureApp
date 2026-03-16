import Foundation
import SwiftData

// MARK: - PersistenceController

final class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    init(inMemory: Bool = false) {
        let schema = Schema([DonationCategory.self, DonationTransaction.self])

        if inMemory {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                container = try ModelContainer(for: schema, configurations: config)
            } catch {
                fatalError("Failed to create in-memory ModelContainer: \(error)")
            }
            return
        }

        // SwiftData automatically migrates additive changes (new columns with defaults)
        // without needing an explicit migration plan.
        let config = ModelConfiguration(schema: schema)
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            // Store is corrupted or unrecoverable — wipe and start fresh.
            print("⚠️ ModelContainer load failed (\(error)). Wiping store and recreating.")
            PersistenceController.deleteStoreFiles()
            do {
                container = try ModelContainer(
                    for: schema,
                    configurations: ModelConfiguration(schema: schema)
                )
            } catch {
                fatalError("Failed to create ModelContainer even after store reset: \(error)")
            }
        }
    }

    private static func deleteStoreFiles() {
        guard let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first else { return }
        let base = appSupport.appendingPathComponent("default.store")
        for suffix in ["", "-shm", "-wal"] {
            let url = base.deletingPathExtension().appendingPathExtension("store\(suffix)")
            try? FileManager.default.removeItem(at: url)
        }
    }

    // MARK: Preview container with seed data

    @MainActor
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.mainContext

        let zakat  = DonationCategory(name: "Zakat 1446H",     type: .zakat,  totalAmount: 18500, paidAmount: 12000)
        let fitra  = DonationCategory(name: "Zakat al-Fitr",   type: .fitra,  totalAmount: 350,   paidAmount: 350)
        let khums  = DonationCategory(name: "Khums 1446H",     type: .khums,  totalAmount: 8200,  paidAmount: 3000)
        let sadaqa = DonationCategory(name: "General Sadaqah", type: .sadaqa, totalAmount: 5000,  paidAmount: 2100)

        [zakat, fitra, khums, sadaqa].forEach { ctx.insert($0) }

        let cal = Calendar.current
        let txData: [(DonationCategory, Double, Date, PaymentMethod, String?, Bool)] = [
            (zakat,  5000, cal.date(byAdding: .month, value: -2,  to: .now)!, .upi,          "First installment",   true),
            (zakat,  4000, cal.date(byAdding: .month, value: -1,  to: .now)!, .bankTransfer, nil,                   true),
            (zakat,  3000, cal.date(byAdding: .day,   value: -10, to: .now)!, .upi,          "Second installment",  true),
            (zakat,  1500, cal.date(byAdding: .day,   value: -2,  to: .now)!, .manual,       "Set aside for later", false),
            (fitra,   350, cal.date(byAdding: .month, value: -1,  to: .now)!, .cash,         "Eid al-Fitr",         true),
            (khums,  3000, cal.date(byAdding: .month, value: -3,  to: .now)!, .bankTransfer, nil,                   true),
            (sadaqa,  500, cal.date(byAdding: .day,   value: -5,  to: .now)!, .cash,         "Local masjid",        true),
            (sadaqa,  800, cal.date(byAdding: .day,   value: -15, to: .now)!, .upi,          nil,                   true),
            (sadaqa,  800, cal.date(byAdding: .month, value: -1,  to: .now)!, .manual,       "Food drive",          true),
            (sadaqa,  600, cal.date(byAdding: .day,   value: -1,  to: .now)!, .manual,       "Pending payment",     false),
        ]

        for (cat, amount, date, method, notes, isPaid) in txData {
            let tx = DonationTransaction(
                categoryId: cat.id, amount: amount, date: date,
                notes: notes, paymentMethod: method, isPaid: isPaid
            )
            ctx.insert(tx)
            cat.transactions.append(tx)
        }

        try? ctx.save()
        return controller
    }()
}
