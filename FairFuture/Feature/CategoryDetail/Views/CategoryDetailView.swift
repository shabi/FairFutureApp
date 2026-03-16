import SwiftUI

struct CategoryDetailView: View {
    @Bindable var category: DonationCategory
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showAddTransaction = false

    private let service: DonationServiceProtocol = DonationService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summaryHeader

                    // Pending pool banner — only if there's unpaid money set aside
                    if category.hasPendingAmount {
                        pendingPoolBanner
                    }

                    statsGrid
                    transactionList
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(category.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddTransaction = true
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddTransaction) {
                AddTransactionSheet(category: category)
            }
        }
    }

    // MARK: Summary Header

    private var summaryHeader: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(category.type.color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: category.type.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(category.type.color)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.type.rawValue)
                        .font(.caption)
                        .foregroundStyle(category.type.color)
                    Text(category.name)
                        .font(.title3.weight(.bold))
                    Text(category.type.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Progress bar — reflects only confirmed paid amount
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(category.type.color.opacity(0.12))
                            .frame(height: 10)
                        // Pending layer (orange, behind green)
                        if category.totalAmount > 0 && category.hasPendingAmount {
                            let pendingFraction = min(1, (category.paidAmount + category.accumulatedUnpaidAmount) / category.totalAmount)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.orange.opacity(0.4))
                                .frame(width: geo.size.width * pendingFraction, height: 10)
                        }
                        // Paid layer (solid)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(category.isFullyPaid ? .green : category.type.color)
                            .frame(width: geo.size.width * category.completionPercent, height: 10)
                            .animation(.spring(duration: 0.6), value: category.completionPercent)
                    }
                }
                .frame(height: 10)

                HStack {
                    Text("\(Int(category.completionPercent * 100))% paid")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(category.type.color)
                    if category.hasPendingAmount && category.totalAmount > 0 {
                        let totalFraction = Int(min(1, (category.paidAmount + category.accumulatedUnpaidAmount) / category.totalAmount) * 100)
                        Text("· \(totalFraction)% incl. pending")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    Spacer()
                    if category.isFullyPaid {
                        Label("Fully Paid", systemImage: "checkmark.seal.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: Pending Pool Banner

    private var pendingPoolBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "clock.badge.plus")
                    .font(.system(size: 20))
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pending — Set Aside")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.orange)
                    Text("You've accumulated this amount but haven't confirmed payment yet.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Awaiting Payment")
                        .font(.caption2).foregroundStyle(.secondary)
                    Text(category.accumulatedUnpaidAmount.formatted)
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(.orange)
                }
                Spacer()
                // Mark all pending as paid at once
                Button {
                    markAllPendingAsPaid()
                } label: {
                    Label("Pay All Now", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#2E7D6B"))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(Color.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.orange.opacity(0.25), lineWidth: 1))
    }

    // MARK: Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            if category.totalAmount > 0 {
                statCell(title: "Total Obligation", value: category.totalAmount.formatted, color: .blue)
            }
            statCell(title: "Paid", value: category.paidAmount.formatted, color: .green)
            if category.hasPendingAmount {
                statCell(title: "Set Aside", value: category.accumulatedUnpaidAmount.formatted, color: .orange)
            }
            if category.totalAmount > 0 {
                statCell(title: "Remaining", value: category.remainingAmount.formatted, color: .primary)
            }
            statCell(title: "Transactions", value: "\(category.transactions.count)", color: category.type.color)
        }
    }

    private func statCell(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title3.weight(.bold)).foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: Transaction List

    private var transactionList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CategoryHeaderView("History", subtitle: "\(category.transactions.count) records")
                Spacer()
                Button { showAddTransaction = true } label: {
                    Label("Add", systemImage: "plus")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(category.type.color)
                }
            }

            if category.transactions.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: "No Records Yet",
                    subtitle: "Tap Add to record a payment or set money aside.",
                    actionTitle: "Add Record"
                ) { showAddTransaction = true }
                .cardStyle()
            } else {
                let sorted = category.transactions.sorted { $0.date > $1.date }
                VStack(spacing: 0) {
                    ForEach(Array(sorted.enumerated()), id: \.element.id) { idx, tx in
                        TransactionRowView(
                            transaction: tx,
                            category: category,
                            onMarkPaid: tx.isPaid ? nil : {
                                markAsPaid(tx)
                            }
                        )
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        if idx < sorted.count - 1 {
                            Divider().padding(.leading, 70)
                        }
                    }
                }
                .cardStyle()
            }
        }
    }

    // MARK: Actions

    private func markAsPaid(_ transaction: DonationTransaction) {
        try? service.markAsPaid(transaction, category: category, context: context)
    }

    private func markAllPendingAsPaid() {
        let pending = category.transactions.filter { !$0.isPaid }
        for tx in pending {
            try? service.markAsPaid(tx, category: category, context: context)
        }
    }
}
