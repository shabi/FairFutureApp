//import SwiftUI
//
//// MARK: - AddTransactionSheet
//
//struct AddTransactionSheet: View {
//    let category: DonationCategory
//    @Environment(\.modelContext) private var context
//    @Environment(\.dismiss) private var dismiss
//    @StateObject private var vm = AddTransactionViewModel()
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(spacing: 16) {
//
//                    // ── Pay Mode toggle ───────────────────────────
//                    payModeToggle
//                        .padding(.horizontal)
//                        .padding(.top, 8)
//
//                    // ── Amount ────────────────────────────────────
//                    amountCard
//                        .padding(.horizontal)
//
//                    // ── Details ───────────────────────────────────
//                    detailsCard
//                        .padding(.horizontal)
//
//                    // ── UPI (only when Pay Now + UPI method) ──────
//                    if vm.isPaid && vm.paymentMethod == .upi {
//                        upiCard
//                            .padding(.horizontal)
//                    }
//
//                    // ── Error ─────────────────────────────────────
//                    if let error = vm.errorMessage {
//                        Label(error, systemImage: "exclamationmark.triangle.fill")
//                            .foregroundStyle(.red)
//                            .font(.caption)
//                            .padding(.horizontal)
//                    }
//
//                    Spacer(minLength: 32)
//                }
//            }
//            .background(Color(.systemGroupedBackground))
//            .navigationTitle("Record Donation")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") { dismiss() }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(vm.isPaid ? "Save & Pay" : "Set Aside") {
//                        if vm.save(to: category, context: context) { dismiss() }
//                    }
//                    .fontWeight(.semibold)
//                    .foregroundStyle(vm.isPaid ? Color(hex: "#2E7D6B") : .orange)
//                    .disabled(!vm.isValid)
//                }
//            }
//        }
//    }
//
//    // MARK: Pay Mode Toggle
//
//    private var payModeToggle: some View {
//        VStack(spacing: 10) {
//            // Segmented-style two-button toggle
//            HStack(spacing: 0) {
//                modeButton(
//                    title: "Pay Now",
//                    subtitle: "Mark as paid immediately",
//                    icon: "checkmark.circle.fill",
//                    color: Color(hex: "#2E7D6B"),
//                    selected: vm.isPaid
//                ) { withAnimation(.spring(response: 0.3)) { vm.isPaid = true } }
//
//                Divider().frame(height: 60)
//
//                modeButton(
//                    title: "Set Aside",
//                    subtitle: "Accumulate, pay later",
//                    icon: "clock.badge.plus",
//                    color: .orange,
//                    selected: !vm.isPaid
//                ) { withAnimation(.spring(response: 0.3)) { vm.isPaid = false } }
//            }
//            .background(Color(.systemBackground))
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(vm.isPaid ? Color(hex: "#2E7D6B").opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1.5)
//            )
//
//            // Context hint
//            HStack(alignment: .top, spacing: 8) {
//                Image(systemName: vm.isPaid ? "checkmark.seal" : "hourglass")
//                    .font(.caption)
//                    .foregroundStyle(vm.isPaid ? Color(hex: "#2E7D6B") : .orange)
//                    .padding(.top, 1)
//                Text(vm.isPaid
//                     ? "This amount will be counted as paid and reflected in your progress immediately."
//                     : "This amount will be set aside in a pending pool. You can mark it as paid later when you actually send the money.")
//                    .font(.caption)
//                    .foregroundStyle(.secondary)
//                    .lineSpacing(3)
//            }
//            .padding(12)
//            .background((vm.isPaid ? Color(hex: "#2E7D6B") : Color.orange).opacity(0.07))
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//        }
//    }
//
//    private func modeButton(title: String, subtitle: String, icon: String, color: Color, selected: Bool, action: @escaping () -> Void) -> some View {
//        Button(action: action) {
//            HStack(spacing: 10) {
//                Image(systemName: icon)
//                    .font(.system(size: 22))
//                    .foregroundStyle(selected ? color : .secondary)
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(title)
//                        .font(.subheadline.weight(.semibold))
//                        .foregroundStyle(selected ? color : .secondary)
//                    Text(subtitle)
//                        .font(.caption2)
//                        .foregroundStyle(.secondary)
//                }
//                Spacer()
//                if selected {
//                    Image(systemName: "checkmark")
//                        .font(.caption.weight(.bold))
//                        .foregroundStyle(color)
//                }
//            }
//            .padding(.horizontal, 14)
//            .padding(.vertical, 14)
//            .background(selected ? color.opacity(0.07) : .clear)
//        }
//        .buttonStyle(.plain)
//    }
//
//    // MARK: Amount Card
//
//    private var amountCard: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Amount")
//                .font(.caption.weight(.semibold))
//                .foregroundStyle(.secondary)
//                .padding(.horizontal, 4)
//            HStack {
//                Text("₹")
//                    .foregroundStyle(.secondary)
//                    .font(.system(size: 28, weight: .medium))
//                TextField("0.00", text: $vm.amount)
//                    .keyboardType(.decimalPad)
//                    .font(.system(size: 28, weight: .bold))
//            }
//            .padding(16)
//            .background(Color(.systemBackground))
//            .clipShape(RoundedRectangle(cornerRadius: 14))
//
//            // Remaining hint
//            if category.totalAmount > 0 {
//                let remaining = category.remainingAmount
//                HStack(spacing: 6) {
//                    Image(systemName: "info.circle")
//                        .font(.caption2)
//                    Text("Remaining obligation: \(remaining.formatted)")
//                        .font(.caption)
//                }
//                .foregroundStyle(.secondary)
//                .padding(.horizontal, 4)
//            }
//        }
//    }
//
//    // MARK: Details Card
//
//    private var detailsCard: some View {
//        VStack(spacing: 0) {
//            // Date
//            HStack {
//                Label("Date", systemImage: "calendar")
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//                Spacer()
//                DatePicker("", selection: $vm.date, displayedComponents: .date)
//                    .labelsHidden()
//            }
//            .padding(14)
//
//            Divider().padding(.leading, 14)
//
//            // Payment method — only shown when Pay Now
//            if vm.isPaid {
//                VStack(spacing: 0) {
//                    HStack {
//                        Label("Method", systemImage: "creditcard")
//                            .font(.subheadline)
//                            .foregroundStyle(.secondary)
//                        Spacer()
//                        Picker("", selection: $vm.paymentMethod) {
//                            ForEach(PaymentMethod.allCases) { m in
//                                Label(m.rawValue, systemImage: m.icon).tag(m)
//                            }
//                        }
//                        .labelsHidden()
//                    }
//                    .padding(14)
//                    Divider().padding(.leading, 14)
//                }
//            }
//
//            // Notes
//            HStack(alignment: .top) {
//                Label("Notes", systemImage: "note.text")
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//                    .padding(.top, 2)
//                Spacer()
//                TextField("Optional", text: $vm.notes, axis: .vertical)
//                    .font(.subheadline)
//                    .lineLimit(3)
//                    .multilineTextAlignment(.trailing)
//            }
//            .padding(14)
//        }
//        .background(Color(.systemBackground))
//        .clipShape(RoundedRectangle(cornerRadius: 14))
//    }
//
//    // MARK: UPI Card
//
//    private var upiCard: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("UPI Payment")
//                .font(.caption.weight(.semibold))
//                .foregroundStyle(.secondary)
//                .padding(.horizontal, 4)
//
//            VStack(spacing: 0) {
//                HStack {
//                    Label("UPI ID", systemImage: "qrcode")
//                        .font(.subheadline).foregroundStyle(.secondary)
//                    Spacer()
//                    TextField("name@upi", text: $vm.upiId)
//                        .font(.subheadline)
//                        .autocorrectionDisabled()
//                        .textInputAutocapitalization(.never)
//                        .multilineTextAlignment(.trailing)
//                }
//                .padding(14)
//
//                Divider().padding(.leading, 14)
//
//                HStack {
//                    Label("Recipient", systemImage: "person")
//                        .font(.subheadline).foregroundStyle(.secondary)
//                    Spacer()
//                    TextField("Name", text: $vm.upiReceiver)
//                        .font(.subheadline)
//                        .multilineTextAlignment(.trailing)
//                }
//                .padding(14)
//
//                if !vm.upiId.isEmpty, !vm.upiReceiver.isEmpty, let amount = vm.parsedAmount {
//                    Divider().padding(.leading, 14)
//
//                    let apps = vm.availableUPIApps
//                    if apps.isEmpty {
//                        HStack(spacing: 8) {
//                            Image(systemName: "exclamationmark.triangle")
//                                .foregroundStyle(.orange)
//                            Text("No UPI app detected. Install Google Pay, PhonePe, or Paytm.")
//                                .font(.caption)
//                                .foregroundStyle(.secondary)
//                        }
//                        .padding(14)
//                    } else {
//                        ForEach(apps) { app in
//                            Button {
//                                vm.openInApp(app, amount: amount, receiver: vm.upiReceiver, upiId: vm.upiId)
//                            } label: {
//                                HStack(spacing: 10) {
//                                    Image(systemName: app.icon)
//                                        .font(.system(size: 18))
//                                        .foregroundStyle(Color(hex: "#2E7D6B"))
//                                        .frame(width: 28)
//                                    Text("Pay ₹\(String(format: "%.0f", amount)) via \(app.name)")
//                                        .font(.subheadline.weight(.medium))
//                                        .foregroundStyle(Color(hex: "#2E7D6B"))
//                                    Spacer()
//                                    Image(systemName: "arrow.up.right")
//                                        .font(.caption)
//                                        .foregroundStyle(.secondary)
//                                }
//                                .padding(.horizontal, 14)
//                                .padding(.vertical, 12)
//                            }
//                            if app.id != apps.last?.id {
//                                Divider().padding(.leading, 52)
//                            }
//                        }
//                    }
//                }
//            }
//            .background(Color(.systemBackground))
//            .clipShape(RoundedRectangle(cornerRadius: 14))
//
//            // Quick recipient chips
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 8) {
//                    ForEach(UPIRecipient.presets) { r in
//                        Button {
//                            vm.upiId = r.upiId
//                            vm.upiReceiver = r.name
//                        } label: {
//                            VStack(alignment: .leading, spacing: 2) {
//                                Text(r.name).font(.caption.weight(.semibold))
//                                Text(r.upiId).font(.caption2).foregroundStyle(.secondary)
//                            }
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 8)
//                            .background(Color(.systemBackground))
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 0.5))
//                        }
//                        .foregroundStyle(.primary)
//                    }
//                }
//                .padding(.top, 8)
//            }
//        }
//    }
//}
//
//// MARK: - AddCategorySheet
//
//struct AddCategorySheet: View {
//    @Environment(\.modelContext) private var context
//    @Environment(\.dismiss) private var dismiss
//    @StateObject private var vm = AddCategoryViewModel()
//
//    @State private var showTypeGuide = false
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(spacing: 0) {
//                    // ── Type selector cards ──────────────────────
//                    typeSelectorSection
//
//                    // ── Name field with suggestions ───────────────
//                    nameSection
//                        .padding(.horizontal)
//                        .padding(.bottom, 16)
//
//                    // ── Obligation amount ─────────────────────────
//                    amountSection
//                        .padding(.horizontal)
//                        .padding(.bottom, 16)
//
////                    // ── Explanation card for selected type ───────
////                    selectedTypeExplanationCard
////                        .padding(.horizontal)
////                        .padding(.bottom, 16)
////
////                    // ── Why multiple? ─────────────────────────────
////                    whyMultipleCard
////                        .padding(.horizontal)
////                        .padding(.bottom, 32)
//
////                    // ── Name field with suggestions ───────────────
////                    nameSection
////                        .padding(.horizontal)
////                        .padding(.bottom, 16)
////
////                    // ── Obligation amount ─────────────────────────
////                    amountSection
////                        .padding(.horizontal)
////                        .padding(.bottom, 32)
//
//                    // Error
//                    if let error = vm.errorMessage {
//                        Label(error, systemImage: "exclamationmark.triangle.fill")
//                            .foregroundStyle(.red)
//                            .font(.caption)
//                            .padding(.horizontal)
//                            .padding(.bottom, 16)
//                    }
//                }
//            }
//            .background(Color(.systemGroupedBackground))
//            .navigationTitle("New Category")
//            .navigationBarTitleDisplayMode(.inline)
//            .sheet(isPresented: $showTypeGuide) { TypeGuideSheet() }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") { dismiss() }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Add") {
//                        if vm.save(context: context) { dismiss() }
//                    }
//                    .fontWeight(.semibold)
//                    .disabled(!vm.isValid)
//                }
//            }
//        }
//    }
//
//    // MARK: — Type Selector
//
//    private var typeSelectorSection: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            HStack {
//                Text("Choose Type")
//                    .font(.headline)
//                    .padding(.leading)
//                Spacer()
//                Button {
//                    showTypeGuide = true
//                } label: {
//                    Label("Click here for Full Guide", systemImage: "book.pages")
//                        .font(.caption.weight(.medium))
//                        .foregroundStyle(vm.selectedType.color)
//                }
//                .padding(.trailing)
//            }
//            .padding(.top, 20)
//
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 10) {
//                    ForEach(DonationType.allCases) { type in
//                        TypeSelectorCard(type: type, isSelected: vm.selectedType == type) {
//                            withAnimation(.spring(response: 0.3)) {
//                                vm.selectedType = type
//                            }
//                        }
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.vertical, 4)
//            }
//        }
//        .padding(.bottom, 8)
//    }
//
//    // MARK: — Explanation Card
//
//    private var selectedTypeExplanationCard: some View {
//        let type = vm.selectedType
//        return VStack(alignment: .leading, spacing: 14) {
//            // Header
//            HStack(spacing: 12) {
//                ZStack {
//                    Circle()
//                        .fill(type.color.opacity(0.15))
//                        .frame(width: 46, height: 46)
//                    Image(systemName: type.icon)
//                        .font(.system(size: 20, weight: .medium))
//                        .foregroundStyle(type.color)
//                }
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(type.rawValue)
//                        .font(.title3.weight(.bold))
//                    Text(type.description)
//                        .font(.caption)
//                        .foregroundStyle(type.color)
//                }
//            }
//
//            Divider()
//
//            Text(type.fullExplanation)
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//                .lineSpacing(4)
//        }
//        .padding(16)
//        .background(Color(.systemBackground))
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//                .stroke(type.color.opacity(0.2), lineWidth: 1.5)
//        )
//        .animation(.easeInOut(duration: 0.2), value: vm.selectedType)
//    }
//
//    // MARK: — Why Multiple Card
//
//    private var whyMultipleCard: some View {
//        let type = vm.selectedType
//        return VStack(alignment: .leading, spacing: 10) {
//            Label("Why create multiple \(type.rawValue) categories?", systemImage: "plus.square.on.square")
//                .font(.subheadline.weight(.semibold))
//                .foregroundStyle(type.color)
//
//            Text(type.whyMultiple)
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//                .lineSpacing(4)
//        }
//        .padding(14)
//        .background(type.color.opacity(0.07))
//        .clipShape(RoundedRectangle(cornerRadius: 14))
//        .overlay(
//            RoundedRectangle(cornerRadius: 14)
//                .stroke(type.color.opacity(0.15), lineWidth: 1)
//        )
//        .animation(.easeInOut(duration: 0.2), value: vm.selectedType)
//    }
//
//    // MARK: — Name Section
//
//    private var nameSection: some View {
//        let type = vm.selectedType
//        return VStack(alignment: .leading, spacing: 10) {
//            Text("Category Name")
//                .font(.headline)
//
//            // Text field
//            HStack {
//                Image(systemName: type.icon)
//                    .foregroundStyle(type.color)
//                    .frame(width: 20)
//                TextField("e.g. \(type.exampleNames.first ?? "")", text: $vm.name)
//                    .font(.body)
//            }
//            .padding(14)
//            .background(Color(.systemBackground))
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 1))
//
//            // Suggested names
//            VStack(alignment: .leading, spacing: 6) {
//                Text("Suggested names")
//                    .font(.caption)
//                    .foregroundStyle(.secondary)
//
//                FlowLayout(spacing: 8) {
//                    ForEach(type.exampleNames, id: \.self) { suggestion in
//                        Button {
//                            withAnimation { vm.name = suggestion }
//                        } label: {
//                            Text(suggestion)
//                                .font(.caption.weight(.medium))
//                                .padding(.horizontal, 10)
//                                .padding(.vertical, 6)
//                                .background(
//                                    vm.name == suggestion
//                                        ? type.color
//                                        : type.color.opacity(0.1)
//                                )
//                                .foregroundStyle(
//                                    vm.name == suggestion ? .white : type.color
//                                )
//                                .clipShape(Capsule())
//                        }
//                        .animation(.spring(response: 0.25), value: vm.name)
//                    }
//                }
//            }
//        }
//        .animation(.easeInOut(duration: 0.2), value: vm.selectedType)
//    }
//
//    // MARK: — Amount Section
//
//    private var amountSection: some View {
//        let type = vm.selectedType
//        let isOptional = (type == .sadaqa || type == .custom)
//
//        return VStack(alignment: .leading, spacing: 10) {
//            HStack {
//                Text("Obligation Amount")
//                    .font(.headline)
//                if isOptional {
//                    Text("Optional")
//                        .font(.caption.weight(.medium))
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 3)
//                        .background(Color(.secondarySystemBackground))
//                        .clipShape(Capsule())
//                        .foregroundStyle(.secondary)
//                }
//            }
//
//            HStack {
//                Text("₹")
//                    .foregroundStyle(.secondary)
//                    .font(.title3)
//                TextField("0.00", text: $vm.totalAmount)
//                    .keyboardType(.decimalPad)
//                    .font(.title3.weight(.semibold))
//            }
//            .padding(14)
//            .background(Color(.systemBackground))
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 1))
//
//            // Contextual hint
//            HStack(alignment: .top, spacing: 8) {
//                Image(systemName: "lightbulb")
//                    .font(.caption)
//                    .foregroundStyle(type.color)
//                    .padding(.top, 1)
//                Text(amountHint(for: type))
//                    .font(.caption)
//                    .foregroundStyle(.secondary)
//                    .lineSpacing(3)
//            }
//            .padding(12)
//            .background(type.color.opacity(0.06))
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//        }
//        .animation(.easeInOut(duration: 0.2), value: vm.selectedType)
//    }
//
//    private func amountHint(for type: DonationType) -> String {
//        switch type {
//        case .zakat:
//            return "Enter your total calculated Zakat for this cycle. Use the nisab calculator if needed: (Total savings − liabilities) × 2.5%."
//        case .fitra:
//            return "Enter the total Fitra due: (Number of persons in your household) × (per-head rate set by your local scholars this year)."
//        case .khums:
//            return "Enter 20% of your annual surplus. Surplus = (Total income for the year) − (All legitimate living expenses for the year)."
//        case .sadaqa:
//            return "Sadaqah has no fixed obligation. Leave this blank to track how much you give voluntarily, or set a personal target if you have one in mind."
//        case .custom:
//            return "Enter the total amount you intend to give or have vowed to give, if applicable. Leave blank if it is open-ended."
//        }
//    }
//}
//
//// MARK: - TypeSelectorCard
//
//private struct TypeSelectorCard: View {
//    let type: DonationType
//    let isSelected: Bool
//    let onTap: () -> Void
//
//    var body: some View {
//        Button(action: onTap) {
//            VStack(spacing: 8) {
//                ZStack {
//                    Circle()
//                        .fill(isSelected ? type.color : type.color.opacity(0.12))
//                        .frame(width: 48, height: 48)
//                    Image(systemName: type.icon)
//                        .font(.system(size: 20, weight: .medium))
//                        .foregroundStyle(isSelected ? .white : type.color)
//                }
//                Text(type.rawValue)
//                    .font(.caption.weight(isSelected ? .bold : .medium))
//                    .foregroundStyle(isSelected ? type.color : .secondary)
//                    .lineLimit(1)
//            }
//            .frame(width: 76)
//            .padding(.vertical, 12)
//            .background(
//                isSelected
//                    ? type.color.opacity(0.1)
//                    : Color(.systemBackground)
//            )
//            .clipShape(RoundedRectangle(cornerRadius: 14))
//            .overlay(
//                RoundedRectangle(cornerRadius: 14)
//                    .stroke(
//                        isSelected ? type.color : Color(.separator),
//                        lineWidth: isSelected ? 1.5 : 0.5
//                    )
//            )
//            .shadow(color: isSelected ? type.color.opacity(0.15) : .clear, radius: 6, y: 2)
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//// MARK: - FlowLayout  (wrapping chip layout)
//
//private struct FlowLayout: Layout {
//    var spacing: CGFloat = 8
//
//    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
//        let width = proposal.width ?? 0
//        var height: CGFloat = 0
//        var x: CGFloat = 0
//        var rowHeight: CGFloat = 0
//
//        for view in subviews {
//            let size = view.sizeThatFits(.unspecified)
//            if x + size.width > width, x > 0 {
//                height += rowHeight + spacing
//                x = 0; rowHeight = 0
//            }
//            x += size.width + spacing
//            rowHeight = max(rowHeight, size.height)
//        }
//        height += rowHeight
//        return CGSize(width: width, height: height)
//    }
//
//    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
//        var x = bounds.minX
//        var y = bounds.minY
//        var rowHeight: CGFloat = 0
//
//        for view in subviews {
//            let size = view.sizeThatFits(.unspecified)
//            if x + size.width > bounds.maxX, x > bounds.minX {
//                y += rowHeight + spacing
//                x = bounds.minX; rowHeight = 0
//            }
//            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
//            x += size.width + spacing
//            rowHeight = max(rowHeight, size.height)
//        }
//    }
//}
//
//// MARK: - Full Type Guide Sheet
//
//struct TypeGuideSheet: View {
//    @Environment(\.dismiss) private var dismiss
//
//    var body: some View {
//        NavigationStack {
//            List {
//                ForEach(DonationType.allCases) { type in
//                    Section {
//                        VStack(alignment: .leading, spacing: 12) {
//                            HStack(spacing: 10) {
//                                ZStack {
//                                    Circle().fill(type.color.opacity(0.15)).frame(width: 38, height: 38)
//                                    Image(systemName: type.icon).foregroundStyle(type.color)
//                                }
//                                VStack(alignment: .leading, spacing: 1) {
//                                    Text(type.rawValue).font(.headline)
//                                    Text(type.description).font(.caption).foregroundStyle(.secondary)
//                                }
//                            }
//
//                            Text(type.fullExplanation)
//                                .font(.subheadline)
//                                .foregroundStyle(.secondary)
//                                .lineSpacing(4)
//
//                            VStack(alignment: .leading, spacing: 6) {
//                                Text("When to create multiple")
//                                    .font(.caption.weight(.semibold))
//                                    .foregroundStyle(type.color)
//                                Text(type.whyMultiple)
//                                    .font(.caption)
//                                    .foregroundStyle(.secondary)
//                                    .lineSpacing(3)
//                            }
//                            .padding(10)
//                            .background(type.color.opacity(0.07))
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//
//                            VStack(alignment: .leading, spacing: 6) {
//                                Text("Example names")
//                                    .font(.caption.weight(.semibold))
//                                    .foregroundStyle(.secondary)
//                                FlowLayout(spacing: 6) {
//                                    ForEach(type.exampleNames, id: \.self) { name in
//                                        Text(name)
//                                            .font(.caption)
//                                            .padding(.horizontal, 9)
//                                            .padding(.vertical, 5)
//                                            .background(type.color.opacity(0.1))
//                                            .foregroundStyle(type.color)
//                                            .clipShape(Capsule())
//                                    }
//                                }
//                            }
//                        }
//                        .padding(.vertical, 4)
//                    }
//                }
//            }
//            .listStyle(.insetGrouped)
//            .navigationTitle("Category Guide")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") { dismiss() }
//                }
//            }
//        }
//    }
//}

///new

import SwiftUI

// MARK: - AddTransactionSheet

struct AddTransactionSheet: View {
    let category: DonationCategory
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = AddTransactionViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // ── Pay Mode toggle ───────────────────────────
                    payModeToggle
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // ── Amount ────────────────────────────────────
                    amountCard
                        .padding(.horizontal)

                    // ── Details ───────────────────────────────────
                    detailsCard
                        .padding(.horizontal)

                    // ── UPI (only when Pay Now + UPI method) ──────
                    if vm.isPaid && vm.paymentMethod == .upi {
                        upiCard
                            .padding(.horizontal)
                    }

                    // ── Error ─────────────────────────────────────
                    if let error = vm.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }

                    Spacer(minLength: 32)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Record Donation")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { vm.refreshUPIApps() }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(vm.isPaid ? "Save & Pay" : "Set Aside") {
                        if vm.save(to: category, context: context) { dismiss() }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(vm.isPaid ? Color(hex: "#2E7D6B") : .orange)
                    .disabled(!vm.isValid)
                }
            }
        }
    }

    // MARK: Pay Mode Toggle

    private var payModeToggle: some View {
        VStack(spacing: 10) {
            // Segmented-style two-button toggle
            HStack(spacing: 0) {
                modeButton(
                    title: "Pay Now",
                    subtitle: "Mark as paid immediately",
                    icon: "checkmark.circle.fill",
                    color: Color(hex: "#2E7D6B"),
                    selected: vm.isPaid
                ) { withAnimation(.spring(response: 0.3)) { vm.isPaid = true } }

                Divider().frame(height: 60)

                modeButton(
                    title: "Set Aside",
                    subtitle: "Accumulate, pay later",
                    icon: "clock.badge.plus",
                    color: .orange,
                    selected: !vm.isPaid
                ) { withAnimation(.spring(response: 0.3)) { vm.isPaid = false } }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(vm.isPaid ? Color(hex: "#2E7D6B").opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1.5)
            )

            // Context hint
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: vm.isPaid ? "checkmark.seal" : "hourglass")
                    .font(.caption)
                    .foregroundStyle(vm.isPaid ? Color(hex: "#2E7D6B") : .orange)
                    .padding(.top, 1)
                Text(vm.isPaid
                     ? "This amount will be counted as paid and reflected in your progress immediately."
                     : "This amount will be set aside in a pending pool. You can mark it as paid later when you actually send the money.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
            }
            .padding(12)
            .background((vm.isPaid ? Color(hex: "#2E7D6B") : Color.orange).opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func modeButton(title: String, subtitle: String, icon: String, color: Color, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(selected ? color : .secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(selected ? color : .secondary)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(color)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(selected ? color.opacity(0.07) : .clear)
        }
        .buttonStyle(.plain)
    }

    // MARK: Amount Card

    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            HStack {
                Text("₹")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 28, weight: .medium))
                TextField("0.00", text: $vm.amount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 28, weight: .bold))
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))

            // Remaining hint
            if category.totalAmount > 0 {
                let remaining = category.remainingAmount
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.caption2)
                    Text("Remaining obligation: \(remaining.formatted)")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            }
        }
    }

    // MARK: Details Card

    private var detailsCard: some View {
        VStack(spacing: 0) {
            // Date
            HStack {
                Label("Date", systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                DatePicker("", selection: $vm.date, displayedComponents: .date)
                    .labelsHidden()
            }
            .padding(14)

            Divider().padding(.leading, 14)

            // Payment method — only shown when Pay Now
            if vm.isPaid {
                VStack(spacing: 0) {
                    HStack {
                        Label("Method", systemImage: "creditcard")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Picker("", selection: $vm.paymentMethod) {
                            ForEach(PaymentMethod.allCases) { m in
                                Label(m.rawValue, systemImage: m.icon).tag(m)
                            }
                        }
                        .labelsHidden()
                    }
                    .padding(14)
                    Divider().padding(.leading, 14)
                }
            }

            // Notes
            HStack(alignment: .top) {
                Label("Notes", systemImage: "note.text")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
                Spacer()
                TextField("Optional", text: $vm.notes, axis: .vertical)
                    .font(.subheadline)
                    .lineLimit(3)
                    .multilineTextAlignment(.trailing)
            }
            .padding(14)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: UPI Card

    private var upiCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("UPI Payment")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                HStack {
                    Label("UPI ID", systemImage: "qrcode")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Spacer()
                    TextField("name@upi", text: $vm.upiId)
                        .font(.subheadline)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .multilineTextAlignment(.trailing)
                }
                .padding(14)

                Divider().padding(.leading, 14)

                HStack {
                    Label("Recipient", systemImage: "person")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Spacer()
                    TextField("Name", text: $vm.upiReceiver)
                        .font(.subheadline)
                        .multilineTextAlignment(.trailing)
                }
                .padding(14)

                if !vm.upiId.isEmpty, !vm.upiReceiver.isEmpty, let amount = vm.parsedAmount {
                    Divider().padding(.leading, 14)

                    let apps = vm.availableUPIApps
                    if apps.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundStyle(.orange)
                            Text("No UPI app detected. Install Google Pay, PhonePe, or Paytm.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(14)
                    } else {
                        ForEach(apps) { app in
                            Button {
                                vm.openInApp(app, amount: amount, receiver: vm.upiReceiver, upiId: vm.upiId)
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: app.icon)
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color(hex: "#2E7D6B"))
                                        .frame(width: 28)
                                    Text("Pay ₹\(String(format: "%.0f", amount)) via \(app.name)")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(Color(hex: "#2E7D6B"))
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                            }
                            if app.id != apps.last?.id {
                                Divider().padding(.leading, 52)
                            }
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))

            // Quick recipient chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(UPIRecipient.presets) { r in
                        Button {
                            vm.upiId = r.upiId
                            vm.upiReceiver = r.name
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(r.name).font(.caption.weight(.semibold))
                                Text(r.upiId).font(.caption2).foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 0.5))
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - AddCategorySheet

struct AddCategorySheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = AddCategoryViewModel()
    @State private var showTypeGuide = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // 1 ── Type selector ───────────────────────────
                    typeSelectorSection

                    VStack(spacing: 16) {

                        // 2 ── Category name + suggested chips ──────
                        nameSection

                        // 3 ── Obligation amount + formula hint ──────
                        amountSection

                        // 4 ── Note (optional) ───────────────────────
                        notesSection

                        // ── Error ───────────────────────────────────
                        if let error = vm.errorMessage {
                            Label(error, systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showTypeGuide) { TypeGuideSheet() }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if vm.save(context: context) { dismiss() }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(vm.isValid ? vm.selectedType.color : .secondary)
                    .disabled(!vm.isValid)
                }
            }
        }
    }

    // MARK: 1 — Type Selector

    private var typeSelectorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Choose Type")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
                Button {
                    showTypeGuide = true
                } label: {
                    Label("Click here for Full Guide", systemImage: "book.pages")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(vm.selectedType.color)
                }
                .padding(.trailing)
            }
            .padding(.top, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(DonationType.allCases) { type in
                        TypeSelectorCard(type: type, isSelected: vm.selectedType == type) {
                            withAnimation(.spring(response: 0.3)) { vm.selectedType = type }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
        .padding(.bottom, 16)
    }

    // MARK: 2 — Name Section

    private var nameSection: some View {
        let type = vm.selectedType
        return VStack(alignment: .leading, spacing: 10) {
            Text("Category Name")
                .font(.headline)

            HStack {
                Image(systemName: type.icon)
                    .foregroundStyle(type.color)
                    .frame(width: 20)
                TextField("e.g. \(type.exampleNames.first ?? "")", text: $vm.name)
                    .font(.body)
            }
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12).stroke(
                    vm.name.isEmpty ? Color(.separator) : type.color.opacity(0.6),
                    lineWidth: vm.name.isEmpty ? 1 : 1.5
                )
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Suggested names")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                FlowLayout(spacing: 8) {
                    ForEach(type.exampleNames, id: \.self) { suggestion in
                        Button {
                            withAnimation { vm.name = suggestion }
                        } label: {
                            Text(suggestion)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(vm.name == suggestion ? type.color : type.color.opacity(0.1))
                                .foregroundStyle(vm.name == suggestion ? .white : type.color)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.25), value: vm.name)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: vm.selectedType)
    }

    // MARK: 3 — Amount Section

    private var amountSection: some View {
        let type = vm.selectedType
        let isOptional = (type == .sadaqa || type == .custom)

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("Obligation Amount")
                    .font(.headline)
                if isOptional {
                    Text("Optional")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Text("₹").foregroundStyle(.secondary).font(.title3)
                TextField("0.00", text: $vm.totalAmount)
                    .keyboardType(.decimalPad)
                    .font(.title3.weight(.semibold))
            }
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 1))

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb")
                    .font(.caption).foregroundStyle(type.color).padding(.top, 1)
                Text(amountHint(for: type))
                    .font(.caption).foregroundStyle(.secondary).lineSpacing(3)
            }
            .padding(12)
            .background(type.color.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .animation(.easeInOut(duration: 0.2), value: vm.selectedType)
    }

    // MARK: 4 — Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("Note")
                    .font(.headline)
                Text("Optional")
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .top) {
                Image(systemName: "note.text")
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
                    .frame(width: 20)
                TextField("e.g. For the masjid building fund", text: $vm.notes, axis: .vertical)
                    .font(.body)
                    .lineLimit(3)
            }
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 1))
        }
    }

    // MARK: 5 — Type Explanation Card (below fold)

    private var selectedTypeExplanationCard: some View {
        let type = vm.selectedType
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(type.color.opacity(0.15)).frame(width: 46, height: 46)
                    Image(systemName: type.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(type.color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("What is \(type.rawValue)?")
                        .font(.subheadline.weight(.bold))
                    Text(type.description)
                        .font(.caption).foregroundStyle(type.color)
                }
            }
            Divider()
            Text(type.fullExplanation)
                .font(.subheadline).foregroundStyle(.secondary).lineSpacing(4)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(type.color.opacity(0.2), lineWidth: 1.5))
        .animation(.easeInOut(duration: 0.2), value: vm.selectedType)
    }

    // MARK: 6 — Why Multiple Card (below fold)

    private var whyMultipleCard: some View {
        let type = vm.selectedType
        return VStack(alignment: .leading, spacing: 10) {
            Label("Why create multiple \(type.rawValue) categories?", systemImage: "plus.square.on.square")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(type.color)
            Text(type.whyMultiple)
                .font(.subheadline).foregroundStyle(.secondary).lineSpacing(4)
        }
        .padding(14)
        .background(type.color.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(type.color.opacity(0.15), lineWidth: 1))
        .animation(.easeInOut(duration: 0.2), value: vm.selectedType)
    }

    // MARK: Helpers

    private func amountHint(for type: DonationType) -> String {
        switch type {
        case .zakat:  return "Formula: (Total savings − liabilities) × 2.5%."
        case .fitra:  return "Total Fitra = number of household members × per-head rate set by your local scholars."
        case .khums:  return "20% of annual surplus. Surplus = total income − all legitimate yearly expenses."
        case .sadaqa: return "No fixed amount. Leave blank for open giving, or set a personal target."
        case .custom: return "Enter the amount you intend or have vowed to give. Leave blank if open-ended."
        }
    }
}

// MARK: - TypeSelectorCard

private struct TypeSelectorCard: View {
    let type: DonationType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? type.color : type.color.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: type.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(isSelected ? .white : type.color)
                }
                Text(type.rawValue)
                    .font(.caption.weight(isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? type.color : .secondary)
                    .lineLimit(1)
            }
            .frame(width: 76)
            .padding(.vertical, 12)
            .background(
                isSelected
                    ? type.color.opacity(0.1)
                    : Color(.systemBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? type.color : Color(.separator),
                        lineWidth: isSelected ? 1.5 : 0.5
                    )
            )
            .shadow(color: isSelected ? type.color.opacity(0.15) : .clear, radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - FlowLayout  (wrapping chip layout)

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                height += rowHeight + spacing
                x = 0; rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX; rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Full Type Guide Sheet

struct TypeGuideSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(DonationType.allCases) { type in
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle().fill(type.color.opacity(0.15)).frame(width: 38, height: 38)
                                    Image(systemName: type.icon).foregroundStyle(type.color)
                                }
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(type.rawValue).font(.headline)
                                    Text(type.description).font(.caption).foregroundStyle(.secondary)
                                }
                            }

                            Text(type.fullExplanation)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineSpacing(4)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("When to create multiple")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(type.color)
                                Text(type.whyMultiple)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineSpacing(3)
                            }
                            .padding(10)
                            .background(type.color.opacity(0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Example names")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                FlowLayout(spacing: 6) {
                                    ForEach(type.exampleNames, id: \.self) { name in
                                        Text(name)
                                            .font(.caption)
                                            .padding(.horizontal, 9)
                                            .padding(.vertical, 5)
                                            .background(type.color.opacity(0.1))
                                            .foregroundStyle(type.color)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Category Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
