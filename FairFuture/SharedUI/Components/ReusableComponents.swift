import SwiftUI

// MARK: - DonationCardView

struct DonationCardView: View {
    let category: DonationCategory
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button { onTap?() } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Header row
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(category.type.color.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: category.type.icon)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(category.type.color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Text(category.type.rawValue)
                            .font(.caption)
                            .foregroundStyle(category.type.color)
                    }

                    Spacer()

                    if category.isFullyPaid {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                            .font(.title3)
                    }
                }

                // Progress bar
                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(category.type.color.opacity(0.12))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(category.isFullyPaid ? Color.green : category.type.color)
                                .frame(width: geo.size.width * category.completionPercent, height: 6)
                                .animation(.spring(duration: 0.5), value: category.completionPercent)
                        }
                    }
                    .frame(height: 6)

                    HStack {
                        Text("\(Int(category.completionPercent * 100))% paid")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if category.totalAmount > 0 {
                            Text("\(category.paidAmount.formatted) / \(category.totalAmount.formatted)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

            // Amount row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Paid")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(category.paidAmount.formatted)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.green)
                }

                if category.hasPendingAmount {
                    Spacer()
                    VStack(alignment: .center, spacing: 2) {
                        Text("Set Aside")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(category.accumulatedUnpaidAmount.formatted)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.orange)
                    }
                }

                Spacer()

                if category.totalAmount > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Remaining")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(category.remainingAmount.formatted)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(category.isFullyPaid ? .secondary : .primary)
                    }
                }
            }
            }
            .padding(16)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - TransactionRowView

struct TransactionRowView: View {
    let transaction: DonationTransaction
    let category: DonationCategory
    var onMarkPaid: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(transaction.isPaid
                          ? category.type.color.opacity(0.12)
                          : Color.orange.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: transaction.isPaid
                      ? transaction.paymentMethod.icon
                      : "clock.badge.plus")
                    .font(.system(size: 16))
                    .foregroundStyle(transaction.isPaid ? category.type.color : .orange)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(transaction.isPaid ? transaction.paymentMethod.rawValue : "Set Aside")
                        .font(.subheadline.weight(.medium))

                    if !transaction.isPaid {
                        Text("PENDING")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                }

                if let notes = transaction.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if !transaction.isPaid, let onMarkPaid {
                    Button {
                        onMarkPaid()
                    } label: {
                        Label("Mark as Paid", systemImage: "checkmark.circle")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(hex: "#2E7D6B"))
                    }
                    .padding(.top, 2)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(transaction.amount.formatted)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(transaction.isPaid ? category.type.color : .orange)
                Text(transaction.date.displayDate)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .opacity(transaction.isPaid ? 1 : 0.85)
    }
}

// MARK: - CategoryHeaderView

struct CategoryHeaderView: View {
    let title: String
    let subtitle: String?
    let color: Color

    init(_ title: String, subtitle: String? = nil, color: Color = .accentColor) {
        self.title = title; self.subtitle = subtitle; self.color = color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.title3.weight(.bold))
            if let sub = subtitle {
                Text(sub)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - SummaryStatCard

struct SummaryStatCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(amount.shortFormatted)
                .font(.title3.weight(.heavy))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - EmptyStateView

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundStyle(.quaternary)
            VStack(spacing: 6) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            if let actionTitle, let action {
                Button(actionTitle, action: action).buttonStyle(.borderedProminent)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}
