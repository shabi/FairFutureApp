import Foundation
import SwiftData
import Combine
import SwiftUI

// MARK: - NisabCalculatorViewModel

@MainActor
final class NisabCalculatorViewModel: ObservableObject {

    @Published var state: NisabCalculatorState
    @Published var isLoadingPrices  = false
    @Published var priceError:    String? = nil
    @Published var showResult      = false
    @Published var showFitraSheet  = false
    @Published var showZakatSheet  = false

    // Step tracking for the guided flow
    @Published var currentStep: Step = .metalPrices

    enum Step: Int, CaseIterable {
        case metalPrices   = 0
        case assets        = 1
        case liabilities   = 2
        case result        = 3

        var title: String {
            switch self {
            case .metalPrices:  return "Metal Prices"
            case .assets:       return "Your Assets"
            case .liabilities:  return "Your Liabilities"
            case .result:       return "Your Zakat"
            }
        }

        var subtitle: String {
            switch self {
            case .metalPrices:  return "Set gold & silver rates for accurate Nisab"
            case .assets:       return "Enter everything you own that has value"
            case .liabilities:  return "Subtract what you genuinely owe"
            case .result:       return "Your obligation for this Zakat year"
            }
        }

        var icon: String {
            switch self {
            case .metalPrices:  return "circle.fill"
            case .assets:       return "plus.circle"
            case .liabilities:  return "minus.circle"
            case .result:       return "checkmark.seal"
            }
        }
    }

    private let storageKey = "nisab_calculator_state"
    private let service: DonationServiceProtocol

    init(service: DonationServiceProtocol? = nil) {
        self.service = service ?? DonationService.shared
        if let data = UserDefaults.standard.data(forKey: "nisab_calculator_state"),
           let decoded = try? JSONDecoder().decode(NisabCalculatorState.self, from: data) {
            state = decoded
        } else {
            state = NisabCalculatorState()
        }
    }

    // MARK: - Navigation

    func next() {
        let all = Step.allCases
        if let idx = all.firstIndex(of: currentStep),
           idx + 1 < all.count {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                currentStep = all[idx + 1]
            }
        }
    }

    func back() {
        let all = Step.allCases
        if let idx = all.firstIndex(of: currentStep), idx > 0 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                currentStep = all[idx - 1]
            }
        }
    }

    func goToStep(_ step: Step) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            currentStep = step
        }
    }

    // MARK: - Price Fetching
    // Attempts to fetch live gold/silver prices from a free public API.
    // Falls back gracefully to the stored/default price if the fetch fails
    // (no internet, API down, etc.) — the user can also set prices manually.

    func fetchLivePrices() async {
        isLoadingPrices = true
        priceError = nil

        do {
            // metals-api.com free tier — returns USD prices
            // We fetch USD then convert using a simple USD→INR rate
            // In production use a more reliable source
            let url = URL(string: "https://api.metals.live/v1/spot/gold,silver")!
            let (data, _) = try await URLSession.shared.data(from: url)

            struct MetalPrice: Decodable {
                let gold:   Double?
                let silver: Double?
            }

            // Response is an array of objects: [{"gold": 2300.5}, {"silver": 27.4}]
            struct Entry: Decodable {
                let gold:   Double?
                let silver: Double?
            }
            let entries = try JSONDecoder().decode([Entry].self, from: data)
            var goldUSD: Double?
            var silverUSD: Double?
            for e in entries {
                if let g = e.gold   { goldUSD   = g }
                if let s = e.silver { silverUSD  = s }
            }

            // Convert troy oz (31.1g) USD price → per gram INR
            // Using approximate USD/INR = 83.5
            let usdInr: Double = 83.5
            if let gOz = goldUSD {
                state.goldPricePerGram   = (gOz / 31.1035) * usdInr
            }
            if let sOz = silverUSD {
                state.silverPricePerGram = (sOz / 31.1035) * usdInr
            }
            state.priceLastUpdated = .now
            persist()

        } catch {
            priceError = "Could not fetch live prices. Using stored rates — you can edit them manually."
        }

        isLoadingPrices = false
    }

    // MARK: - Persist

    func persist() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func resetCalculator() {
        state = NisabCalculatorState()
        currentStep = .metalPrices
        persist()
    }

    // MARK: - Create Categories from Result

    func createZakatCategory(context: ModelContext) throws {
        guard state.zakatDue > 0 else { return }
        let year = Calendar.current.component(.year, from: .now)
        try service.createCategory(
            name: "Zakat \(year)H",
            type: .zakat,
            totalAmount: state.zakatDue,
            notes: "Calculated via Nisab Calculator. Net worth: \(state.netWorth.formatted), Nisab threshold: \(state.nisabThreshold.formatted)",
            context: context
        )
    }

    func createFitraCategory(context: ModelContext) throws {
        guard state.fitraTotal > 0 else { return }
        let year = Calendar.current.component(.year, from: .now)
        try service.createCategory(
            name: "Fitra \(year)",
            type: .fitra,
            totalAmount: state.fitraTotal,
            notes: "\(state.fitraMembers) member\(state.fitraMembers == 1 ? "" : "s") × \(state.fitraPerHead.formatted) per head",
            context: context
        )
    }

    // MARK: - Convenience formatted strings

    var nisabThresholdFormatted: String { state.nisabThreshold.formatted }
    var netWorthFormatted:       String { state.netWorth.formatted }
    var zakatDueFormatted:       String { state.zakatDue.formatted }
    var fitraTotalFormatted:     String { state.fitraTotal.formatted }

    var progressPercent: Double {
        guard state.nisabThreshold > 0 else { return 0 }
        return min(1, state.netWorth / state.nisabThreshold)
    }

    var priceAgeDescription: String {
        let mins = Int(-state.priceLastUpdated.timeIntervalSinceNow / 60)
        if mins < 2   { return "Just updated" }
        if mins < 60  { return "\(mins) minutes ago" }
        let hrs = mins / 60
        if hrs < 24   { return "\(hrs)h ago" }
        return state.priceLastUpdated.displayDate
    }
}
