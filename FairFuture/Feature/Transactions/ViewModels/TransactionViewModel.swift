
import Foundation
import SwiftData
import Combine

// MARK: - AddTransactionViewModel

@MainActor
final class AddTransactionViewModel: ObservableObject {

    @Published var amount: String = ""
    @Published var notes: String = ""
    @Published var paymentMethod: PaymentMethod = .manual
    @Published var date: Date = .now
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showUPISheet = false
    @Published var upiId: String = ""
    @Published var upiReceiver: String = ""

    /// false = "Set Aside / Accumulate"  |  true = "Paid Now"
    @Published var isPaid: Bool = true

    private let service: DonationServiceProtocol
    private let upiService: UPIServiceProtocol

    init(
        service: DonationServiceProtocol? = nil,
        upiService: UPIServiceProtocol? = nil
    ) {
        self.service = service ?? DonationService.shared
        self.upiService = upiService ?? UPIService.shared
    }
    
    var parsedAmount: Double? {
        Double(amount.trimmingCharacters(in: .whitespaces))
    }

    var isValid: Bool {
        guard let a = parsedAmount else { return false }
        return a > 0
    }

    func save(to category: DonationCategory, context: ModelContext) -> Bool {
        guard let a = parsedAmount, isValid else {
            errorMessage = "Please enter a valid amount."
            return false
        }
        isLoading = true
        defer { isLoading = false }
        do {
            try service.addTransaction(
                to: category,
                amount: a,
                date: date,
                notes: notes.isEmpty ? nil : notes,
                paymentMethod: paymentMethod,
                isPaid: isPaid,
                context: context
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func openUPIPayment(amount: Double, receiver: String, upiId: String) {
        let success = upiService.openUPIPayment(
            amount: amount, receiver: receiver, upiId: upiId,
            note: notes.isEmpty ? "Donation" : notes
        )
        if !success {
            errorMessage = "No UPI app found. Make sure Google Pay, PhonePe, or Paytm is installed and LSApplicationQueriesSchemes is set in Info.plist."
        }
    }

    func openInApp(_ app: UPIApp, amount: Double, receiver: String, upiId: String) {
        let success = upiService.openInApp(
            app, amount: amount, receiver: receiver, upiId: upiId,
            note: notes.isEmpty ? "Donation" : notes
        )
        if !success {
            errorMessage = "\(app.name) could not be opened. Check that it is installed and that '\(app.detectionScheme)' is in LSApplicationQueriesSchemes in Info.plist."
        }
    }

    /// Refreshes the list of installed UPI apps (clears cache and re-checks).
    /// Call this from .onAppear so canOpenURL runs once, not on every render.
    func refreshUPIApps() {
        (upiService as? UPIService)?.refreshAvailableApps()
    }

    var availableUPIApps: [UPIApp] {
        upiService.availableUPIApps()
    }

    func reset() {
        amount = ""; notes = ""; paymentMethod = .manual
        date = .now; errorMessage = nil; upiId = ""; upiReceiver = ""
        isPaid = true
    }
}

// MARK: - AddCategoryViewModel

@MainActor
final class AddCategoryViewModel: ObservableObject {

    @Published var name: String = ""
    @Published var selectedType: DonationType = .sadaqa
    @Published var totalAmount: String = ""
    @Published var notes: String = ""
    @Published var errorMessage: String?

    private let service: DonationServiceProtocol

    init(service: DonationServiceProtocol? = nil) {
        self.service = service ?? DonationService.shared
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func save(context: ModelContext) -> Bool {
        guard isValid else { errorMessage = "Please enter a category name."; return false }
        let amount = Double(totalAmount) ?? 0
        do {
            try service.createCategory(
                name: name.trimmingCharacters(in: .whitespaces),
                type: selectedType,
                totalAmount: amount,
                notes: notes.isEmpty ? nil : notes,
                context: context
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
