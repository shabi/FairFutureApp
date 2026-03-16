import SwiftUI
import SwiftData

struct DailyTrackerView: View {
    @Query(filter: #Predicate<DonationCategory> { $0.typeRaw == "Sadaqah" })
    private var sadaqaCategories: [DonationCategory]

    @Query(sort: \DonationCategory.createdDate)
    private var allCategories: [DonationCategory]

    @Environment(\.modelContext) private var context
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = DailyTrackerViewModel()

    @State private var showConvertPicker = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var showNoCategoryAlert = false
    /// Single source of truth — non-nil means pay-mode sheet is open for this category
    @State private var categoryForPayMode: DonationCategory?

    private var targetCategories: [DonationCategory] {
        sadaqaCategories.isEmpty ? allCategories : sadaqaCategories
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    accumulatorCard
                    configCard
                    if vm.hasHistory { historyCard }
                    howItWorks
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .contentShape(Rectangle())
            .onTapGesture { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
            .navigationTitle("Daily Tracker")
            .navigationBarTitleDisplayMode(.large)
            .scrollDismissesKeyboard(.immediately)
            .alert("Done!", isPresented: .init(
                get: { successMessage != nil },
                set: { if !$0 { successMessage = nil } }
            )) {
                Button("OK") { successMessage = nil }
            } message: { Text(successMessage ?? "") }
            .alert("Error", isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
            .alert("No Category Found", isPresented: $showNoCategoryAlert) {
                Button("Go to Dashboard") {
                    appState.selectedTab = .dashboard
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You need at least one donation category before converting your tracker balance.\n\nGo to the Dashboard and tap + to create one.")
            }
            .sheet(isPresented: $showConvertPicker) { categoryPickerSheet }
            .sheet(item: $categoryForPayMode) { cat in
                payModeSheet(for: cat)
            }
        }
    }

    // MARK: Accumulator Card

    private var accumulatorCard: some View {
        VStack(spacing: 20) {
            ZStack {
                if vm.settings.isActive {
                    Circle()
                        .fill(Color(hex: "#B5452E").opacity(0.06))
                        .frame(width: 110, height: 110)
                }
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#B5452E").opacity(0.18), Color(hex: "#B5452E").opacity(0.06)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                Image(systemName: vm.settings.isActive ? "heart.fill" : "heart")
                    .font(.system(size: 38))
                    .foregroundStyle(Color(hex: "#B5452E"))
            }
            .animation(.easeInOut(duration: 0.4), value: vm.settings.isActive)

            VStack(spacing: 4) {
                Text(
                    vm.settings.isActive ? "Accumulating Daily"
                    : vm.settings.pausedAccumulatedAmount != nil ? "Paused — Saved Up"
                    : "Tracker Inactive"
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                Text(vm.accumulatedAmount.formatted)
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(vm.settings.isActive ? Color(hex: "#2E7D6B") : .orange)
                    .contentTransition(.numericText())
                    .animation(.spring(), value: vm.accumulatedAmount)

                if vm.settings.isActive {
                    Label(
                        "\(vm.daysSinceStart + 1) day\(vm.daysSinceStart == 0 ? "" : "s") of giving",
                        systemImage: "calendar"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } else if vm.settings.pausedAccumulatedAmount != nil {
                    Label("Paused — tap Resume to continue", systemImage: "pause.circle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            if vm.totalConverted > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "trophy").font(.caption).foregroundStyle(.yellow)
                    Text("Lifetime converted: \(vm.totalConverted.formatted)")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color(.secondarySystemBackground))
                .clipShape(Capsule())
            }

            if vm.settings.isActive {
                activeButtons
            } else {
                inactiveButtons
            }
        }
        .padding(20)
        .cardStyle()
    }

    private var activeButtons: some View {
        VStack(spacing: 10) {
            Button { pickCategoryThenConvert() } label: {
                Label("Convert to Donation", systemImage: "arrow.triangle.2.circlepath")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "#2E7D6B"))
            .disabled(vm.accumulatedAmount <= 0)

            Button { withAnimation { vm.pauseTracking() } } label: {
                Label("Pause", systemImage: "pause.circle")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            .tint(.orange)
        }
    }

    private var inactiveButtons: some View {
        VStack(spacing: 10) {
            if vm.settings.pausedAccumulatedAmount != nil {
                Button { withAnimation { vm.resumeTracking() } } label: {
                    Label("Resume Tracker", systemImage: "play.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)

                Button { pickCategoryThenConvert() } label: {
                    Label("Convert Saved Amount Now", systemImage: "arrow.triangle.2.circlepath")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .tint(Color(hex: "#2E7D6B"))
                .disabled(vm.accumulatedAmount <= 0)

            } else {
                Button { vm.startTracking() } label: {
                    Label("Start Daily Tracker", systemImage: "play.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "#2E7D6B"))
            }
        }
    }

    // MARK: Config Card

    private var configCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            CategoryHeaderView("Daily Amount", subtitle: "Accumulates automatically every day")

            HStack {
                Text("₹").foregroundStyle(.secondary).font(.title3)
                TextField("10", text: $vm.dailyAmountInput)
                    .keyboardType(.decimalPad)
                    .font(.title2.weight(.semibold))
                    .onChange(of: vm.dailyAmountInput) { _, _ in vm.updateDailyAmount() }
                Spacer()
                Text("per day").font(.subheadline).foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            let daily = Double(vm.dailyAmountInput) ?? 0
            if daily > 0 {
                HStack(spacing: 0) {
                    projectionCell(label: "Weekly",  amount: daily * 7)
                    Divider().frame(height: 30)
                    projectionCell(label: "Monthly", amount: daily * 30)
                    Divider().frame(height: 30)
                    projectionCell(label: "Yearly",  amount: daily * 365)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .cardStyle()
    }

    private func projectionCell(label: String, amount: Double) -> some View {
        VStack(spacing: 2) {
            Text(amount.shortFormatted).font(.subheadline.weight(.bold)).foregroundStyle(Color(hex: "#2E7D6B"))
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: History Card

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            CategoryHeaderView("Conversion History", subtitle: "\(vm.conversionHistory.count) sessions")

            VStack(spacing: 0) {
                ForEach(Array(vm.conversionHistory.enumerated()), id: \.element.id) { idx, session in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 9)
                                .fill(session.isPaid ? Color(hex: "#2E7D6B").opacity(0.12) : Color.orange.opacity(0.12))
                                .frame(width: 38, height: 38)
                            Image(systemName: session.isPaid ? "checkmark.circle.fill" : "clock.badge.plus")
                                .font(.system(size: 15))
                                .foregroundStyle(session.isPaid ? Color(hex: "#2E7D6B") : .orange)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.categoryName).font(.caption.weight(.medium)).lineLimit(1)
                            Text("\(session.days) day\(session.days == 1 ? "" : "s") · \(session.date.displayDate)")
                                .font(.caption2).foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(session.amount.formatted)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(session.isPaid ? Color(hex: "#2E7D6B") : .orange)
                            Text(session.isPaid ? "Paid" : "Set Aside")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(session.isPaid ? .green : .orange)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)

                    if idx < vm.conversionHistory.count - 1 {
                        Divider().padding(.leading, 64)
                    }
                }
            }
            .cardStyle()
        }
    }

    // MARK: How It Works

    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 12) {
            CategoryHeaderView("How It Works")
            ForEach([
                ("Set a daily amount",        "₹10/day builds up quietly in the background.",             "sun.max"),
                ("Accumulates automatically", "Each passing day adds to your total.",                     "clock.arrow.circlepath"),
                ("Pause anytime",             "Balance is preserved. Resume whenever you're ready.",      "pause.circle"),
                ("Convert when ready",        "Choose Pay Now or Set Aside — fully at your own pace.",    "arrow.triangle.2.circlepath"),
            ], id: \.0) { title, detail, icon in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle().fill(Color(hex: "#2E7D6B").opacity(0.10)).frame(width: 36, height: 36)
                        Image(systemName: icon).font(.system(size: 14)).foregroundStyle(Color(hex: "#2E7D6B"))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title).font(.subheadline.weight(.medium))
                        Text(detail).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: Category Picker Sheet

    private var categoryPickerSheet: some View {
        NavigationStack {
            List(allCategories) { cat in
                Button {
                    showConvertPicker = false
                    // Small delay lets the picker sheet dismiss before the pay-mode sheet presents
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        categoryForPayMode = cat
                    }
                } label: {
                    HStack {
                        Image(systemName: cat.type.icon).foregroundStyle(cat.type.color)
                        VStack(alignment: .leading) {
                            Text(cat.name)
                            Text(cat.type.rawValue).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(.secondary).font(.caption)
                    }
                }
                .foregroundStyle(.primary)
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { showConvertPicker = false }
                }
            }
        }
    }

    // MARK: Pay Mode Sheet

    private func payModeSheet(for category: DonationCategory) -> some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Text("Converting").font(.subheadline).foregroundStyle(.secondary)
                    Text(vm.accumulatedAmount.formatted)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(hex: "#2E7D6B"))
                    Text("→ \(category.name)").font(.caption).foregroundStyle(.secondary)
                }
                .padding(.vertical, 28)

                Divider()

                payModeOption(
                    title: "Pay Now",
                    detail: "Records this amount as paid immediately.\nProgress and totals update right away.",
                    icon: "checkmark.circle.fill",
                    color: Color(hex: "#2E7D6B")
                ) { convertToTransaction(category: category, isPaid: true) }

                Divider().padding(.leading, 72)

                payModeOption(
                    title: "Set Aside",
                    detail: "Saves as pending — mark it paid later\nfrom the category detail screen.",
                    icon: "clock.badge.plus",
                    color: .orange
                ) { convertToTransaction(category: category, isPaid: false) }

                Divider()
                Spacer()
            }
            .navigationTitle("How to record?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { categoryForPayMode = nil }
                }
            }
        }
    }

    private func payModeOption(title: String, detail: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(color.opacity(0.12)).frame(width: 52, height: 52)
                    Image(systemName: icon).font(.system(size: 22)).foregroundStyle(color)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline).foregroundStyle(.primary)
                    Text(detail)
                        .font(.caption).foregroundStyle(.secondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary).font(.caption)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .buttonStyle(.plain)
    }

    // MARK: Helpers

    private func pickCategoryThenConvert() {
        guard !allCategories.isEmpty else {
            showNoCategoryAlert = true
            return
        }
        if targetCategories.count == 1 {
            categoryForPayMode = targetCategories[0]
        } else {
            showConvertPicker = true
        }
    }

    private func convertToTransaction(category: DonationCategory, isPaid: Bool) {
        categoryForPayMode = nil
        showConvertPicker = false
        do {
            try vm.convertToTransaction(category: category, context: context, isPaid: isPaid)
            successMessage = isPaid
                ? "Recorded as paid in \"\(category.name)\"."
                : "Amount set aside in \"\(category.name)\". Mark it paid when you're ready."
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
