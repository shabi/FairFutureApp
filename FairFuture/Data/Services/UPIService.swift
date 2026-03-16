import Foundation
import UIKit
import SwiftUI

// MARK: - UPIServiceProtocol

protocol UPIServiceProtocol {
    func openInApp(_ app: UPIApp, amount: Double, receiver: String, upiId: String, note: String?) -> Bool
    func openUPIPayment(amount: Double, receiver: String, upiId: String, note: String?) -> Bool
    func generateUPILink(amount: Double, receiver: String, upiId: String, note: String?) -> URL?
    func isUPIAvailable() -> Bool
    func availableUPIApps() -> [UPIApp]
}

// MARK: - UPIApp

struct UPIApp: Identifiable {
    let id: String
    let name: String
    let detectionScheme: String
    let icon: String
    let brandColor: Color
}

extension UPIApp {
    static let all: [UPIApp] = [
        UPIApp(id: "gpay",    name: "Google Pay", detectionScheme: "tez",      icon: "g.circle.fill",                    brandColor: Color(hex: "#1A73E8")),
        UPIApp(id: "phonepe", name: "PhonePe",    detectionScheme: "phonepe",  icon: "p.circle.fill",                    brandColor: Color(hex: "#5F259F")),
        UPIApp(id: "paytm",   name: "Paytm",      detectionScheme: "paytmmp",  icon: "indianrupeesign.circle.fill",       brandColor: Color(hex: "#00BAF2")),
        UPIApp(id: "bhim",    name: "BHIM",        detectionScheme: "bhim",     icon: "b.circle.fill",                    brandColor: Color(hex: "#00A3E0")),
    ]
}

// MARK: - UPIService

final class UPIService: UPIServiceProtocol {
    static let shared = UPIService()

    // Cache available apps — re-checked only when explicitly refreshed
    // Avoids canOpenURL being called on every render
    private var _cachedApps: [UPIApp]? = nil

    func refreshAvailableApps() {
        _cachedApps = UPIApp.all.filter { canOpen(scheme: $0.detectionScheme) }
    }

    // MARK: - URL Builders

    /// Standard NPCI UPI deep link — works for PhonePe, Paytm, BHIM, and generic upi:// handlers
    func generateUPILink(
        amount: Double,
        receiver: String,
        upiId: String,
        note: String? = nil
    ) -> URL? {
        buildURL(
            scheme: "upi",
            host: "pay",
            pa: upiId,
            pn: receiver,
            am: amount,
            tn: note ?? "Donation"
        )
    }

    /// Google Pay deep link — uses tez://upi/pay format
    /// GPay REQUIRES this exact scheme; upi:// does NOT open GPay
    private func generateGPayLink(
        amount: Double,
        receiver: String,
        upiId: String,
        note: String? = nil
    ) -> URL? {
        buildURL(
            scheme: "tez",
            host: "upi",
            path: "/pay",
            pa: upiId,
            pn: receiver,
            am: amount,
            tn: note ?? "Donation"
        )
    }

    /// Central URL builder — always produces a valid percent-encoded URL
    /// Includes optional NPCI-spec fields for better bank compatibility
    private func buildURL(
        scheme: String,
        host: String,
        path: String = "",
        pa: String,
        pn: String,
        am: Double,
        tn: String
    ) -> URL? {
        let amStr  = String(format: "%.2f", am)
        let pnEnc  = pn.upiEncoded
        let tnEnc  = tn.upiEncoded
        let paEnc  = pa.upiEncoded
        // tr = transaction reference (unique per request — helps banks track)
        // mc = merchant category code (0000 = generic)
        // mode = 00 = default UPI collect/push
        let tr = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(20)
        let urlStr = "\(scheme)://\(host)\(path)?pa=\(paEnc)&pn=\(pnEnc)&am=\(amStr)&cu=INR&tn=\(tnEnc)&tr=\(tr)&mc=0000&mode=00"
        return URL(string: urlStr)
    }

    // MARK: - Open Payment

    /// Opens the specified UPI app directly with the payment pre-filled.
    @discardableResult
    func openInApp(
        _ app: UPIApp,
        amount: Double,
        receiver: String,
        upiId: String,
        note: String? = nil
    ) -> Bool {
        let url: URL?
        switch app.id {
        case "gpay":
            url = generateGPayLink(amount: amount, receiver: receiver, upiId: upiId, note: note)
        default:
            url = generateUPILink(amount: amount, receiver: receiver, upiId: upiId, note: note)
        }

        guard let url else {
            print("❌ Failed to build URL for \(app.name)")
            return false
        }

        print("📲 [\(app.name)] Opening: \(url.absoluteString)")

        guard UIApplication.shared.canOpenURL(url) else {
            print("❌ canOpenURL = false for \(app.name). Scheme '\(app.detectionScheme)' missing from LSApplicationQueriesSchemes?")
            return false
        }

        UIApplication.shared.open(url, options: [:]) { success in
            print(success ? "✅ \(app.name) opened" : "❌ \(app.name) failed to open")
        }
        return true
    }

    /// Auto-picks the best available app and opens it.
    @discardableResult
    func openUPIPayment(
        amount: Double,
        receiver: String,
        upiId: String,
        note: String? = nil
    ) -> Bool {
        guard let best = availableUPIApps().first else {
            print("❌ No UPI apps found on this device")
            return false
        }
        return openInApp(best, amount: amount, receiver: receiver, upiId: upiId, note: note)
    }

    // MARK: - Availability

    func isUPIAvailable() -> Bool { !availableUPIApps().isEmpty }

    /// Returns installed UPI apps from cache. Builds cache on first call.
    func availableUPIApps() -> [UPIApp] {
        if let cached = _cachedApps { return cached }
        refreshAvailableApps()
        return _cachedApps ?? []
    }

    private func canOpen(scheme: String) -> Bool {
        guard let url = URL(string: "\(scheme)://") else { return false }
        let result = UIApplication.shared.canOpenURL(url)
        print("🔍 canOpenURL(\(scheme)://) = \(result)")
        return result
    }
}

// MARK: - String encoding helper

private extension String {
    /// Percent-encodes a string for use in a UPI query parameter value.
    var upiEncoded: String {
        // Use urlQueryAllowed but also encode & and = which could break the query
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&=+")
        return addingPercentEncoding(withAllowedCharacters: allowed) ?? self
    }
}

// MARK: - Preset UPI Recipients

struct UPIRecipient: Identifiable {
    let id = UUID()
    let name: String
    let upiId: String
    let description: String
}

extension UPIRecipient {
    static let presets: [UPIRecipient] = [
        UPIRecipient(name: "Islamic Relief India", upiId: "islamicrelief@axl",  description: "Global humanitarian aid"),
        UPIRecipient(name: "Local Masjid Fund",    upiId: "masjid@upi",         description: "Community mosque"),
        UPIRecipient(name: "Orphan Care Trust",    upiId: "orphancare@upi",     description: "Support for orphans"),
    ]
}
