//
//  FairFutureApp.swift
//  FairFuture
//
//  Created by Shabi Haider on 15/03/26.
//

import Combine
import SwiftUI
import SwiftData
import UserNotifications

@main
struct FairFutureApp: App {

    @StateObject private var appState     = AppState()
    @StateObject private var localization = LocalizationManager.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(localization)
                // ── Localization ──────────────────────────────────
                .environment(\.locale,          localization.locale)
                .environment(\.layoutDirection, localization.layoutDirection)
                // ── SwiftData ─────────────────────────────────────
                .modelContainer(PersistenceController.shared.container)
                // ── Notifications ─────────────────────────────────
                .task { await NotificationService.shared.requestAuthorization() }
        }
    }
}

// MARK: - AppState

@MainActor
final class AppState: ObservableObject {
    @Published var selectedTab: Tab = .dashboard

    enum Tab: Int, CaseIterable {
        case dashboard, transactions, tracker, settings

        var label: String {
            switch self {
            case .dashboard:    return AppStrings.Tabs.dashboard
            case .transactions: return AppStrings.Tabs.history
            case .tracker:      return AppStrings.Tabs.tracker
            case .settings:     return AppStrings.Tabs.settings
            }
        }

        var icon: String {
            switch self {
            case .dashboard:    return AppIcons.dashboard
            case .transactions: return AppIcons.history
            case .tracker:      return AppIcons.tracker
            case .settings:     return AppIcons.settings
            }
        }
    }
}
/*
# BarakahLedger — Project Structure

```
BarakahLedger/
│
├── App/
│   ├── BarakahLedgerApp.swift        # @main entry, ModelContainer injection
│   └── RootView.swift                # TabView shell
│
├── Core/
│   ├── Constants/
│   │   ├── AppStrings.swift          # ALL user-facing strings via NSLocalizedString
│   │   └── AppConstants.swift        # AppColors (Color.App.*) + AppIcons (SF symbols)
│   ├── Extensions/
│   │   └── Extensions.swift          # Color(hex:), Double.formatted, Date.displayDate, cardStyle()
│   └── Utilities/
│       └── (future: Analytics, Logging, etc.)
│
├── Domain/
│   ├── Models/
│   │   └── Models.swift              # @Model DonationCategory, DonationTransaction, DailyTrackerSettings
│   └── Enums/
│       └── Enums.swift               # DonationType, PaymentMethod
│
├── Data/
│   ├── Persistence/
│   │   └── PersistenceController.swift
│   └── Services/
│       ├── DonationService.swift
│       ├── UPIService.swift
│       └── NotificationService.swift
│
├── Features/
│   ├── Dashboard/
│   │   ├── Views/
│   │   │   └── DashboardView.swift
│   │   └── ViewModels/
│   │       └── DashboardViewModel.swift
│   │
│   ├── CategoryDetail/
│   │   ├── Views/
│   │   │   └── CategoryDetailView.swift
│   │   └── ViewModels/
│   │       └── (CategoryDetailViewModel — future if needed)
│   │
│   ├── Transactions/
│   │   ├── Views/
│   │   │   ├── TransactionHistoryView.swift
│   │   │   └── AddViews.swift         # AddTransactionSheet + AddCategorySheet
│   │   └── ViewModels/
│   │       └── TransactionViewModel.swift
│   │
│   ├── DailyTracker/
│   │   ├── Views/
│   │   │   └── DailyTrackerView.swift
│   │   └── ViewModels/
│   │       └── TrackerHistoryViewModel.swift
│   │
│   └── Settings/
│       └── Views/
│           └── SettingsView.swift
│
├── SharedUI/
│   ├── Components/
│   │   └── ReusableComponents.swift   # DonationCardView, TransactionRowView,
│   │                                  # CategoryHeaderView, SummaryStatCard, EmptyStateView
│   └── Styles/
│       └── (future: custom ButtonStyle, TextFieldStyle)
│
└── Resources/
    ├── Localizable/
    │   └── Localizable.xcstrings      # String Catalog (Xcode 15+)
    │                                  # Covers: en, hi, ur
    └── Assets/
        └── Assets.xcassets
```

---

## Key Conventions

### Strings
All user-facing strings live in `Core/Constants/AppStrings.swift`.
Views reference them as `AppStrings.Dashboard.title`, `AppStrings.Tracker.startBtn`, etc.
Never use string literals directly in views.

### Colors
Brand colours are `Color.App.primary`, `Color.App.pending`, etc. (defined in `AppConstants.swift`).
Never use `Color(hex: "...")` directly in views — always go through `Color.App.*`.

### Icons
All SF Symbol strings live in `AppIcons` enum.
Reference as `AppIcons.addFill`, `AppIcons.paid`, etc.

### Localization
The project uses the **String Catalog** format (`Localizable.xcstrings`) introduced in Xcode 15.
To add a new string:
1. Add the `NSLocalizedString(key:value:comment:)` call in `AppStrings.swift`
2. Add the key + translations (en / hi / ur) in `Localizable.xcstrings`

Supported languages: English (en), Hindi (hi), Urdu (ur).

To add a new language (e.g. Arabic):
1. In Xcode: Project → Info → Localizations → + → Arabic
2. Add `"ar"` entries to `Localizable.xcstrings`
3. Set `environment.locale = Locale(identifier: "ar")` in SwiftUI Previews to test.

### In-app Language Switching
iOS respects the device language automatically.
For an in-app language picker (overrides device setting):
- Store the chosen language code in `@AppStorage("app_language")`
- Apply it with `.environment(\.locale, Locale(identifier: appLanguage))` on the root view.
  
---

## Feature Module Rules
Each feature folder is self-contained:
- Its `Views/` only imports `SharedUI` components, never another feature's views directly.
- Its `ViewModels/` only depends on `Data/Services` and `Domain/Models`.
- Cross-feature navigation is handled by the parent (`RootView`, `DashboardView` sheets).

---

## Adding a New Feature
1. Create `Features/NewFeature/Views/` and `Features/NewFeature/ViewModels/`
2. Add the ViewModel as `@StateObject` in the root view of the feature
3. Add strings to `AppStrings` + `Localizable.xcstrings`
4. Add any shared UI to `SharedUI/Components`
5. Wire into `RootView` or parent sheet as needed
*/
