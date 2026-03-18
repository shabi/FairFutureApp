import SwiftUI
import SwiftData

// MARK: - NisabCalculatorView

struct NisabCalculatorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss)      private var dismiss
    @StateObject private var vm = NisabCalculatorViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ── Step progress bar ──────────────────────────────
                stepProgressBar
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                // ── Step content ───────────────────────────────────
                ScrollView {
                    VStack(spacing: 20) {
                        stepHeader
                            .padding(.horizontal)

                        switch vm.currentStep {
                        case .metalPrices:  metalPricesStep
                        case .assets:       assetsStep
                        case .liabilities:  liabilitiesStep
                        case .result:       resultStep
                        }
                    }
                    .padding(.bottom, 40)
                }
                .scrollDismissesKeyboard(.immediately)

                // ── Navigation buttons ─────────────────────────────
                navigationButtons
                    .padding(.horizontal)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Nisab Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        vm.resetCalculator()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .sheet(isPresented: $vm.showZakatSheet) {
                createCategorySheet(
                    title: "Add Zakat Category",
                    amount: vm.zakatDueFormatted,
                    type: .zakat,
                    onConfirm: {
                        try vm.createZakatCategory(context: context)
                        vm.showZakatSheet = false
                        dismiss()
                    }
                )
            }
            .sheet(isPresented: $vm.showFitraSheet) {
                createCategorySheet(
                    title: "Add Fitra Category",
                    amount: vm.fitraTotalFormatted,
                    type: .fitra,
                    onConfirm: {
                        try vm.createFitraCategory(context: context)
                        vm.showFitraSheet = false
                        dismiss()
                    }
                )
            }
        }
    }

    // MARK: ── Step Progress Bar ─────────────────────────────────────

    private var stepProgressBar: some View {
        HStack(spacing: 0) {
            ForEach(NisabCalculatorViewModel.Step.allCases, id: \.self) { step in
                let isActive    = step == vm.currentStep
                let isCompleted = step.rawValue < vm.currentStep.rawValue

                Button { if isCompleted { vm.goToStep(step) } } label: {
                    VStack(spacing: 5) {
                        ZStack {
                            Circle()
                                .fill(isActive ? Color(hex:"#2E7D6B")
                                      : isCompleted ? Color(hex:"#2E7D6B").opacity(0.35)
                                      : Color(.systemGray5))
                                .frame(width: 32, height: 32)

                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            } else {
                                Text("\(step.rawValue + 1)")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(isActive ? .white : .secondary)
                            }
                        }
                        Text(step.title)
                            .font(.system(size: 9, weight: isActive ? .semibold : .regular))
                            .foregroundStyle(isActive ? Color(hex:"#2E7D6B") : .secondary)
                    }
                }
                .buttonStyle(.plain)

                if step != NisabCalculatorViewModel.Step.allCases.last {
                    Rectangle()
                        .fill(isCompleted ? Color(hex:"#2E7D6B").opacity(0.4)
                              : Color(.systemGray5))
                        .frame(height: 2)
                        .padding(.bottom, 22)
                }
            }
        }
    }

    // MARK: ── Step Header ────────────────────────────────────────────

    private var stepHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(vm.currentStep.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.easeInOut, value: vm.currentStep)
    }

    // MARK: ── Navigation Buttons ─────────────────────────────────────

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if vm.currentStep != .metalPrices {
                Button {
                    vm.back()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .buttonStyle(.bordered)
                .tint(Color(hex:"#2E7D6B"))
            }

            if vm.currentStep == .result {
                // On result step the action buttons are inside the step itself
                EmptyView()
            } else {
                Button {
                    vm.persist()
                    vm.next()
                } label: {
                    HStack {
                        Text(vm.currentStep == .liabilities ? "Calculate" : "Next")
                        Image(systemName: vm.currentStep == .liabilities
                              ? "checkmark.circle.fill" : "chevron.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex:"#2E7D6B"))
            }
        }
    }

    // MARK: ══════════════════════════════════════════════════════════
    // STEP 1 — Metal Prices
    // ══════════════════════════════════════════════════════════════

    private var metalPricesStep: some View {
        VStack(spacing: 16) {
            // Info card
            infoCard(
                icon: "info.circle",
                text: "Nisab is the minimum wealth threshold for Zakat. It is calculated based on the current price of gold or silver. Prices are fetched automatically but you can edit them manually."
            )
            .padding(.horizontal)

            // Nisab standard picker
            VStack(alignment: .leading, spacing: 10) {
                Text("Nisab Standard")
                    .font(.headline)

                ForEach(NisabStandard.allCases) { standard in
                    Button {
                        withAnimation { vm.state.nisabStandard = standard }
                        vm.persist()
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .stroke(vm.state.nisabStandard == standard
                                            ? Color(hex:"#2E7D6B") : Color(.separator),
                                            lineWidth: 2)
                                    .frame(width: 22, height: 22)
                                if vm.state.nisabStandard == standard {
                                    Circle()
                                        .fill(Color(hex:"#2E7D6B"))
                                        .frame(width: 12, height: 12)
                                }
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(standard.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text(standard.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineSpacing(2)
                            }
                        }
                        .padding(14)
                        .background(vm.state.nisabStandard == standard
                                    ? Color(hex:"#2E7D6B").opacity(0.07)
                                    : Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(vm.state.nisabStandard == standard
                                        ? Color(hex:"#2E7D6B").opacity(0.4)
                                        : Color(.separator).opacity(0.5),
                                        lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)

            // Price inputs
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Metal Prices")
                        .font(.headline)
                    Spacer()
                    // Live price fetch button
                    Button {
                        Task { await vm.fetchLivePrices() }
                    } label: {
                        if vm.isLoadingPrices {
                            ProgressView().scaleEffect(0.8)
                        } else {
                            Label("Fetch Live", systemImage: "arrow.clockwise")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color(hex:"#2E7D6B"))
                        }
                    }
                    .disabled(vm.isLoadingPrices)
                }
                .padding(.horizontal)

                if let err = vm.priceError {
                    Label(err, systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(.horizontal)
                }

                // Updated time
                Text("Prices last updated: \(vm.priceAgeDescription)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                VStack(spacing: 0) {
                    priceRow(
                        label: "Gold (per gram)",
                        icon:  "circle.fill",
                        iconColor: Color(hex:"#E8B84B"),
                        value: Binding(
                            get: { vm.state.goldPricePerGram },
                            set: { vm.state.goldPricePerGram = $0; vm.persist() }
                        )
                    )
                    Divider().padding(.leading, 14)
                    priceRow(
                        label: "Silver (per gram)",
                        icon:  "circle",
                        iconColor: .gray,
                        value: Binding(
                            get: { vm.state.silverPricePerGram },
                            set: { vm.state.silverPricePerGram = $0; vm.persist() }
                        )
                    )
                }
                .cardStyle()
                .padding(.horizontal)
            }

            // Nisab threshold preview
            nisabPreviewCard
                .padding(.horizontal)
        }
    }

    private func priceRow(label: String, icon: String, iconColor: Color,
                          value: Binding<Double>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 4) {
                Text("₹")
                    .foregroundStyle(.secondary)
                TextField("0", value: value, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(.subheadline.weight(.semibold))
                    .frame(width: 90)
            }
        }
        .padding(14)
    }

    private var nisabPreviewCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex:"#2E7D6B").opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "scalemass")
                    .foregroundStyle(Color(hex:"#2E7D6B"))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Current Nisab Threshold")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(vm.nisabThresholdFormatted)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color(hex:"#2E7D6B"))
                Text("Based on \(vm.state.nisabStandard.rawValue)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex:"#2E7D6B").opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(Color(hex:"#2E7D6B").opacity(0.2), lineWidth: 1))
    }

    // MARK: ══════════════════════════════════════════════════════════
    // STEP 2 — Assets
    // ══════════════════════════════════════════════════════════════

    private var assetsStep: some View {
        VStack(spacing: 16) {
            infoCard(
                icon: "plus.circle",
                text: "Enter the current value of everything you own that could be considered wealth. Be as accurate as possible — Zakat is a trust (amanah)."
            )
            .padding(.horizontal)

            // Running total
            runningTotalCard(
                label: "Total Assets",
                amount: vm.state.totalAssets,
                color: Color(hex:"#2E7D6B")
            )
            .padding(.horizontal)

            VStack(spacing: 0) {
                // Cash & Bank
                assetRow(
                    category: .cashAndBank,
                    value: Binding(get: { vm.state.cashAndBank },
                                   set: { vm.state.cashAndBank = $0; vm.persist() })
                )
                divider()

                // Gold — weight + auto-calculated value
                goldSilverRow(
                    category:  .gold,
                    grams:     Binding(get: { vm.state.goldGrams },
                                       set: { vm.state.goldGrams = $0; vm.persist() }),
                    pricePerG: vm.state.goldPricePerGram,
                    value:     vm.state.goldValue
                )
                divider()

                // Silver
                goldSilverRow(
                    category:  .silver,
                    grams:     Binding(get: { vm.state.silverGrams },
                                       set: { vm.state.silverGrams = $0; vm.persist() }),
                    pricePerG: vm.state.silverPricePerGram,
                    value:     vm.state.silverValue
                )
                divider()

                assetRow(
                    category: .investments,
                    value: Binding(get: { vm.state.investments },
                                   set: { vm.state.investments = $0; vm.persist() })
                )
                divider()

                assetRow(
                    category: .businessInventory,
                    value: Binding(get: { vm.state.businessInventory },
                                   set: { vm.state.businessInventory = $0; vm.persist() })
                )
                divider()

                assetRow(
                    category: .moneOwed,
                    value: Binding(get: { vm.state.moneyOwed },
                                   set: { vm.state.moneyOwed = $0; vm.persist() })
                )
                divider()

                assetRow(
                    category: .other,
                    value: Binding(get: { vm.state.otherAssets },
                                   set: { vm.state.otherAssets = $0; vm.persist() })
                )
            }
            .cardStyle()
            .padding(.horizontal)
        }
    }

    // MARK: ══════════════════════════════════════════════════════════
    // STEP 3 — Liabilities
    // ══════════════════════════════════════════════════════════════

    private var liabilitiesStep: some View {
        VStack(spacing: 16) {
            infoCard(
                icon: "minus.circle",
                text: "Deduct only debts that are genuinely due within this Zakat year. Long-term mortgages are generally not deducted in full — consult your scholar for your specific situation."
            )
            .padding(.horizontal)

            // Running total
            runningTotalCard(
                label: "Total Liabilities",
                amount: vm.state.totalLiabilities,
                color: .red
            )
            .padding(.horizontal)

            VStack(spacing: 0) {
                assetRow(
                    category: .debtsOwed,
                    value: Binding(get: { vm.state.debtsOwed },
                                   set: { vm.state.debtsOwed = $0; vm.persist() })
                )
                .padding(.trailing, 14)
                divider()
                assetRow(
                    category: .billsDue,
                    value: Binding(get: { vm.state.billsDue },
                                   set: { vm.state.billsDue = $0; vm.persist() })
                )
                divider()
                assetRow(
                    category: .otherLiabilities,
                    value: Binding(get: { vm.state.otherLiabilities },
                                   set: { vm.state.otherLiabilities = $0; vm.persist() })
                )
            }
            .cardStyle()
            .padding(.horizontal)

            // Net worth preview
            netWorthPreview
                .padding(.horizontal)
        }
    }

    private var netWorthPreview: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Net Zakatable Wealth")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(vm.netWorthFormatted)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color(hex:"#2E7D6B"))
            }
            HStack {
                Text("Nisab threshold")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text(vm.nisabThresholdFormatted)
                    .font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            }

            // Mini progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex:"#2E7D6B").opacity(0.12))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(vm.state.isAboveNisab ? Color(hex:"#2E7D6B") : .orange)
                        .frame(width: geo.size.width * vm.progressPercent, height: 8)
                        .animation(.spring(duration: 0.5), value: vm.progressPercent)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    // MARK: ══════════════════════════════════════════════════════════
    // STEP 4 — Result
    // ══════════════════════════════════════════════════════════════

    private var resultStep: some View {
        VStack(spacing: 20) {

            // ── Zakat result card ──────────────────────────────────
            VStack(spacing: 16) {
                // Status badge
                HStack {
                    Spacer()
                    Label(
                        vm.state.isAboveNisab ? "Zakat is due" : "Below Nisab",
                        systemImage: vm.state.isAboveNisab
                            ? "checkmark.seal.fill" : "xmark.seal.fill"
                    )
                    .font(.caption.weight(.bold))
                    .foregroundStyle(vm.state.isAboveNisab ? .white : .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(vm.state.isAboveNisab
                                ? Color(hex:"#2E7D6B") : Color.orange)
                    .clipShape(Capsule())
                    Spacer()
                }

                Divider()

                // Breakdown rows
                resultRow("Total Assets",     vm.state.totalAssets.formatted,
                          color: Color(hex:"#2E7D6B"))
                resultRow("Total Liabilities",
                          "− \(vm.state.totalLiabilities.formatted)", color: .red)
                resultRow("Net Zakatable Wealth", vm.netWorthFormatted,
                          color: .primary, isBold: true)
                resultRow("Nisab Threshold",  vm.nisabThresholdFormatted,
                          color: .secondary)

                Divider()

                // Zakat due — the big number
                VStack(spacing: 4) {
                    Text("Zakat Due (2.5%)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(vm.zakatDueFormatted)
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundStyle(vm.state.zakatDue > 0
                                         ? Color(hex:"#2E7D6B") : .secondary)
                        .contentTransition(.numericText())
                }
                .padding(.vertical, 8)

                if vm.state.isAboveNisab {
                    // Add to tracker button
                    Button {
                        vm.showZakatSheet = true
                    } label: {
                        Label("Add to My Tracker", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex:"#2E7D6B"))
                } else {
                    Text("Your wealth is below the Nisab threshold. Zakat is not obligatory this year, but voluntary Sadaqah is always encouraged.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding(16)
            .cardStyle()
            .padding(.horizontal)

            // ── Fitra calculator ───────────────────────────────────
            fitraSection
                .padding(.horizontal)

            // ── Disclaimer ─────────────────────────────────────────
            infoCard(
                icon: "exclamationmark.triangle",
                text: "This calculator provides an estimate based on the values you entered. For complex financial situations — multiple business entities, overseas assets, pension funds — please consult a qualified Islamic scholar or certified Zakat advisor."
            )
            .padding(.horizontal)

            // ── Share / Save summary ───────────────────────────────
            Button {
                // Could add share sheet in future
            } label: {
                Label("Save Calculation Summary", systemImage: "square.and.arrow.down")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex:"#2E7D6B"))
            }
            .padding(.horizontal)
        }
    }

    private var fitraSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Zakat al-Fitr (Fitra)")
                        .font(.headline)
                    Text("Due before Eid prayer for each household member")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            VStack(spacing: 0) {
                // Per-head rate
                HStack {
                    Label("Rate per person", systemImage: "person")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 4) {
                        Text("₹")
                            .foregroundStyle(.secondary)
                        TextField("120", value: $vm.state.fitraPerHead,
                                  format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.subheadline.weight(.semibold))
                            .frame(width: 80)
                            .onChange(of: vm.state.fitraPerHead) { _, _ in
                                vm.persist()
                            }
                    }
                }
                .padding(14)

                Divider().padding(.leading, 14)

                // Household members stepper
                HStack {
                    Label("Household members", systemImage: "person.3")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 16) {
                        Button {
                            if vm.state.fitraMembers > 1 {
                                vm.state.fitraMembers -= 1
                                vm.persist()
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color(hex:"#2E7D6B"))
                        }
                        Text("\(vm.state.fitraMembers)")
                            .font(.title3.weight(.bold))
                            .frame(minWidth: 28)
                        Button {
                            vm.state.fitraMembers += 1
                            vm.persist()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color(hex:"#2E7D6B"))
                        }
                    }
                }
                .padding(14)

                Divider().padding(.leading, 14)

                // Fitra total
                HStack {
                    Text("Total Fitra Due")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(vm.fitraTotalFormatted)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color(hex:"#6B4FA0"))
                }
                .padding(14)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)

            // Add Fitra to tracker
            Button {
                vm.showFitraSheet = true
            } label: {
                Label("Add Fitra to My Tracker", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex:"#6B4FA0"))
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    // MARK: ── Shared sub-views ────────────────────────────────────────

    private func assetRow(category: AssetCategory,
                          value: Binding<Double>) -> some View {
        DisclosureGroup {
            // Hint text when expanded
            Text(category.hint)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .foregroundStyle(category.color)
                    .frame(width: 22)
                Text(category.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Spacer()
                HStack(spacing: 4) {
                    if !category.isLiability { Text("₹").foregroundStyle(.secondary) }
                    else { Text("₹").foregroundStyle(.red.opacity(0.7)) }
                    TextField("0", value: value, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 90)
                        .foregroundStyle(category.isLiability ? .red : .primary)
                }
            }
            .padding(14)
        }
        .tint(.secondary)
    }

    private func goldSilverRow(category: AssetCategory,
                               grams: Binding<Double>,
                               pricePerG: Double,
                               value: Double) -> some View {
        VStack(spacing: 0) {
            DisclosureGroup {
                Text(category.hint)
                    .font(.caption).foregroundStyle(.secondary).lineSpacing(3)
                    .padding(.horizontal, 14).padding(.bottom, 8)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: category.icon)
                        .foregroundStyle(category == .gold
                                         ? Color(hex:"#E8B84B") : .gray)
                        .frame(width: 22)
                    Text(category.rawValue)
                        .font(.subheadline).foregroundStyle(.primary)
                    Spacer()
                    HStack(spacing: 4) {
                        TextField("0", value: grams, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.subheadline.weight(.semibold))
                            .frame(width: 70)
                        Text("g")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
                .padding(14)
            }
            .tint(.secondary)

            // Auto-calculated value
            if grams.wrappedValue > 0 {
                HStack {
                    Text("= \(value.formatted)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex:"#2E7D6B"))
                    Text("(₹\(Int(pricePerG))/g)")
                        .font(.caption2).foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 10)
            }
        }
    }

    private func runningTotalCard(label: String,
                                  amount: Double,
                                  color: Color) -> some View {
        HStack {
            Text(label)
                .font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(amount.formatted)
                .font(.title3.weight(.bold))
                .foregroundStyle(color)
                .contentTransition(.numericText())
        }
        .padding(14)
        .background(color.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func resultRow(_ label: String, _ value: String,
                           color: Color, isBold: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(isBold ? .subheadline.weight(.semibold) : .subheadline)
                .foregroundStyle(isBold ? .primary : .secondary)
            Spacer()
            Text(value)
                .font(isBold ? .subheadline.weight(.bold) : .subheadline)
                .foregroundStyle(color)
        }
        .padding(.horizontal, 4)
    }

    private func divider() -> some View {
        Divider().padding(.leading, 50)
    }

    private func infoCard(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color(hex:"#2E7D6B"))
                .padding(.top, 1)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(12)
        .background(Color(hex:"#2E7D6B").opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: ── Create Category Sheet ──────────────────────────────────

    private func createCategorySheet(title: String,
                                     amount: String,
                                     type: DonationType,
                                     onConfirm: @escaping () throws -> Void) -> some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(type.color.opacity(0.12))
                            .frame(width: 64, height: 64)
                        Image(systemName: type.icon)
                            .font(.system(size: 28))
                            .foregroundStyle(type.color)
                    }
                    Text("Calculated obligation")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Text(amount)
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundStyle(type.color)
                }
                .padding(.top, 32)

                Text("This will create a new \(type.rawValue) category in your tracker with this amount as your obligation. You can then record payments against it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()

                Button {
                    try? onConfirm()
                } label: {
                    Label("Add to Tracker", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(type.color)
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}
