import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2") }
                .tag(AppState.Tab.dashboard)

            TransactionHistoryView()
                .tabItem { Label("History", systemImage: "list.bullet.rectangle") }
                .tag(AppState.Tab.transactions)

            DailyTrackerView()
                .tabItem { Label("Tracker", systemImage: "sun.and.horizon") }
                .tag(AppState.Tab.tracker)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(AppState.Tab.settings)
        }
        .tint(Color(hex: "#2E7D6B"))
    }
}
