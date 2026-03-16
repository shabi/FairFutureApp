import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("daily_reminder_enabled") private var dailyReminderEnabled = true
    @AppStorage("daily_reminder_hour")    private var dailyReminderHour   = 7
    @AppStorage("zakat_reminder_enabled") private var zakatReminderEnabled = true
    @AppStorage("fitra_reminder_enabled") private var fitraReminderEnabled = true
    @AppStorage("default_upi_id")         private var defaultUpiId        = ""
    @AppStorage("default_upi_name")       private var defaultUpiName      = ""

    @Environment(\.modelContext) private var context
    @Query(sort: \DonationCategory.createdDate) private var categories: [DonationCategory]

    @State private var showAbout = false
    @State private var showResetTransactionsConfirm = false
    @State private var showResetEverythingConfirm   = false
    @State private var showResetSuccess: ResetType? = nil

    private let service: DonationServiceProtocol = DonationService.shared

    enum ResetType: String, Identifiable {
        case transactions = "All transactions have been cleared. Category balances are reset to zero."
        case everything   = "All data has been wiped. The app is now fresh."
        var id: String { rawValue }
        var title: String {
            switch self {
            case .transactions: return "Transactions Cleared"
            case .everything:   return "App Reset Complete"
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                // Notifications
                Section {
                    Toggle("Daily Sadaqah Reminder", isOn: $dailyReminderEnabled)
                        .onChange(of: dailyReminderEnabled) { _, enabled in
                            Task {
                                if enabled {
                                    await NotificationService.shared.scheduleDailySadaqaReminder(
                                        at: dailyReminderHour, minute: 0
                                    )
                                } else {
                                    NotificationService.shared.cancelAllNotifications()
                                }
                            }
                        }

                    if dailyReminderEnabled {
                        Picker("Reminder Time", selection: $dailyReminderHour) {
                            ForEach([6, 7, 8, 9, 12, 18, 20], id: \.self) { hour in
                                Text(hourLabel(hour)).tag(hour)
                            }
                        }
                        .onChange(of: dailyReminderHour) { _, hour in
                            Task { await NotificationService.shared.scheduleDailySadaqaReminder(at: hour, minute: 0) }
                        }
                    }

                    Toggle("Zakat Yearly Reminder", isOn: $zakatReminderEnabled)
                    Toggle("Ramadan Fitra Reminder", isOn: $fitraReminderEnabled)
                } header: {
                    Label("Notifications", systemImage: "bell")
                }

                // UPI Defaults
                Section {
                    TextField("Your UPI ID", text: $defaultUpiId)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    TextField("Default Recipient Name", text: $defaultUpiName)
                } header: {
                    Label("Default UPI Settings", systemImage: "qrcode")
                } footer: {
                    Text("Used as the default recipient when making UPI payments.")
                }

                // ── RESET ─────────────────────────────────────────
                Section {
                    // Reset transactions only
                    Button(role: .destructive) {
                        showResetTransactionsConfirm = true
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "arrow.counterclockwise.circle")
                                    .foregroundStyle(.orange)
                                    .font(.system(size: 17))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Reset All Transactions")
                                    .foregroundStyle(.orange)
                                    .fontWeight(.medium)
                                Text("Keeps categories, clears payments & history")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // Reset everything
                    Button(role: .destructive) {
                        showResetEverythingConfirm = true
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "trash.circle")
                                    .foregroundStyle(.red)
                                    .font(.system(size: 17))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Reset Everything")
                                    .foregroundStyle(.red)
                                    .fontWeight(.medium)
                                Text("Deletes all categories and transactions")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Label("Data & Reset", systemImage: "externaldrive.badge.minus")
                } footer: {
                    Text("These actions are permanent and cannot be undone.")
                }
                // ── END RESET ──────────────────────────────────────

                // About
                Section {
                    Button { showAbout = true } label: {
                        HStack {
                            Label("About Fair Future", systemImage: "info.circle")
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.secondary).font(.caption)
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAbout) { aboutSheet }

            // ── Confirmation: Reset Transactions ──
            .confirmationDialog(
                "Reset All Transactions?",
                isPresented: $showResetTransactionsConfirm,
                titleVisibility: .visible
            ) {
                Button("Clear Transactions", role: .destructive) {
                    performResetTransactions()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete every payment record and reset all category balances to ₹0. Your categories will remain. This cannot be undone.")
            }

            // ── Confirmation: Reset Everything ──
            .confirmationDialog(
                "Reset Everything?",
                isPresented: $showResetEverythingConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete All Data", role: .destructive) {
                    performResetEverything()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all categories, transactions, and payment history. The app will return to a completely fresh state. This cannot be undone.")
            }

            // ── Success toast/alert ──
            .alert(showResetSuccess?.title ?? "", isPresented: .init(
                get: { showResetSuccess != nil },
                set: { if !$0 { showResetSuccess = nil } }
            )) {
                Button("OK") { showResetSuccess = nil }
            } message: {
                Text(showResetSuccess?.rawValue ?? "")
            }
        }
    }

    // MARK: - Reset Actions

    private func performResetTransactions() {
        do {
            try service.resetAllTransactions(categories: categories, context: context)
            // Wipe tracker history and notify the live DailyTrackerViewModel to clear itself
            NotificationCenter.default.post(name: .trackerDidReset, object: nil)
            showResetSuccess = .transactions
        } catch {
            print("Reset transactions error: \(error)")
        }
    }

    private func performResetEverything() {
        do {
            try service.resetEverything(categories: categories, context: context)
            // Wipe tracker history and notify the live DailyTrackerViewModel to clear itself
            NotificationCenter.default.post(name: .trackerDidReset, object: nil)
            showResetSuccess = .everything
        } catch {
            print("Reset everything error: \(error)")
        }
    }

    // MARK: Helpers

    private func hourLabel(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        var comps = DateComponents(); comps.hour = hour; comps.minute = 0
        let date = Calendar.current.date(from: comps) ?? .now
        return formatter.string(from: date)
    }

    private var aboutSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "hands.and.sparkles.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color(hex: "#2E7D6B"))

                VStack(spacing: 8) {
                    Text("Fair Future")
                        .font(.title.weight(.bold))
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text("A charity tracking app designed for Muslims to manage Zakat, Fitra, Khums, Sadaqah, and other religious donations with ease.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text("\"The best charity is that given when you are in need.\" — Prophet Muhammad ﷺ")
                    .font(.caption.italic())
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()
            }
            .padding(.top, 48)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {}
                }
            }
        }
    }
}
