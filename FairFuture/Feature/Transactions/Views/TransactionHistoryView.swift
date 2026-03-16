import SwiftUI
import SwiftData

struct TransactionHistoryView: View {
    @Query(sort: \DonationCategory.createdDate) private var categories: [DonationCategory]
    @StateObject private var vm = TransactionHistoryViewModel()

    var body: some View {
        NavigationStack {
            Group {
                let groups = vm.groupedTransactions(categories: categories)
                if groups.isEmpty {
                    emptyState
                } else {
                    transactionList(groups: groups)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $vm.searchText, prompt: "Search notes, methods…")
            .toolbar { toolbarContent }
        }
    }

    // MARK: Empty State

    private var emptyState: some View {
        EmptyStateView(
            icon: "list.bullet.rectangle",
            title: "No Transactions",
            subtitle: "Your donation history will appear here once you start recording payments."
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Transaction List

    private func transactionList(groups: [TransactionHistoryViewModel.MonthGroup]) -> some View {
        List {
            ForEach(groups) { group in
                Section {
                    ForEach(group.transactions, id: \.0.id) { (tx, cat) in
                        TransactionRowView(transaction: tx, category: cat)
                    }
                } header: {
                    HStack {
                        Text(group.id)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(group.total.formatted)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(hex: "#2E7D6B"))
                    }
                    .textCase(nil)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Picker("Sort", selection: $vm.sortOption) {
                    ForEach(TransactionHistoryViewModel.SortOption.allCases, id: \.self) { opt in
                        Text(opt.rawValue).tag(opt)
                    }
                }
                Divider()
                Menu("Filter by Category") {
                    Button("All Categories") { vm.selectedCategory = nil }
                    Divider()
                    // Categories listed inline (fetched above)
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .symbolVariant(vm.selectedCategory != nil || vm.sortOption != .dateDesc ? .fill : .none)
            }
        }
    }
}
