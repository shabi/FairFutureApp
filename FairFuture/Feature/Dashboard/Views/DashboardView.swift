import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \DonationCategory.createdDate) private var categories: [DonationCategory]
    @StateObject private var vm = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerBanner
                    summaryStats
                    categorySection
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Fair Future")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 4) {
                        // Nisab Calculator button
                        Button { vm.showNisabCalculator = true } label: {
                            Image(systemName: "scalemass")
                                .font(.title3)
                        }
                        // Add category button
                        Button { vm.showAddCategory = true } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                    }
                }
            }
            .sheet(isPresented: $vm.showAddCategory) {
                AddCategorySheet()
            }
            .sheet(isPresented: $vm.showNisabCalculator) {
                NisabCalculatorView()
            }
            .sheet(item: $vm.selectedCategory) { cat in
                CategoryDetailView(category: cat)
            }
        }
    }

    // MARK: Header Banner

    private var headerBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("السَّلَامُ عَلَيْكُمْ")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    Text("Your Giving Journey")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "hands.and.sparkles")
                    .font(.system(size: 36))
                    .foregroundStyle(.white.opacity(0.6))
            }

            // Overall progress ring
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 72, height: 72)
                    Circle()
                        .trim(from: 0, to: vm.overallProgress(from: categories))
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 72, height: 72)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(duration: 1), value: vm.overallProgress(from: categories))
                    Text("\(Int(vm.overallProgress(from: categories) * 100))%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Total Paid")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    Text(vm.totalPaid(from: categories).formatted)
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(.white)
                    Text("of \(vm.totalObligation(from: categories).formatted)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(hex: "#2E7D6B"), Color(hex: "#1B5E4F")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: Summary Stats

    private var summaryStats: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            SummaryStatCard(title: "Obligation", amount: vm.totalObligation(from: categories), icon: "scalemass", color: .blue)
            SummaryStatCard(title: "Paid", amount: vm.totalPaid(from: categories), icon: "checkmark.circle", color: .green)
            SummaryStatCard(title: "Remaining", amount: vm.totalRemaining(from: categories), icon: "clock", color: .orange)
        }
    }

    // MARK: Category Section

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CategoryHeaderView("Categories", subtitle: "\(categories.count) active")
                Spacer()
                Button("Add") { vm.showAddCategory = true }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color(hex: "#2E7D6B"))
            }

            if categories.isEmpty {
                // Nisab calculator prompt — shown when no categories yet
                Button { vm.showNisabCalculator = true } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#2E7D6B").opacity(0.12))
                                .frame(width: 48, height: 48)
                            Image(systemName: "scalemass")
                                .font(.system(size: 20))
                                .foregroundStyle(Color(hex: "#2E7D6B"))
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Calculate your Zakat")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text("Use the Nisab Calculator to find your obligation")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .cardStyle()
                }
                .buttonStyle(.plain)

                EmptyStateView(
                    icon: "heart.text.square",
                    title: "No Categories Yet",
                    subtitle: "Add your first donation category to start tracking.",
                    actionTitle: "Add Category"
                ) { vm.showAddCategory = true }
                .cardStyle()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(categories) { cat in
                        DonationCardView(category: cat) {
                            vm.selectedCategory = cat
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                vm.deleteCategory(cat, context: context)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }
}
