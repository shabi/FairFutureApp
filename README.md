# FairFutureApp
iOS app to track Islamic charitable giving — Zakat, Fitra, Khums &amp; Sadaqah. SwiftUI · SwiftData · UPI payments · Daily tracker · 100% on-device.

# ff · Fair Future

> **Track every blessing.** A privacy-first Islamic charity tracking app for Muslims to manage Zakat, Fitra, Khums, Sadaqah and daily giving — built natively for iPhone.

<br/>

<p align="center">
  <img src="Resources/AppIcon/AppIcon-ff-logo.svg" width="120" height="120" alt="Fair Future Icon"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2017%2B-2E7D6B?style=flat-square"/>
  <img src="https://img.shields.io/badge/Swift-5.9-F05138?style=flat-square&logo=swift"/>
  <img src="https://img.shields.io/badge/SwiftUI-5-0070C9?style=flat-square"/>
  <img src="https://img.shields.io/badge/SwiftData-✓-34C759?style=flat-square"/>
  <img src="https://img.shields.io/badge/License-MIT-1B5E4F?style=flat-square"/>
</p>

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Key Modules](#key-modules)
- [UPI Payment Integration](#upi-payment-integration)
- [Notifications](#notifications)
- [App Icon & Launch Screen](#app-icon--launch-screen)
- [Localization](#localization)
- [Performance](#performance)
- [Known Limitations](#known-limitations)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

Fair Future helps Muslims track their obligatory and voluntary charitable giving in one place. Whether you're calculating your annual Zakat, setting aside daily Sadaqah, or managing household Fitra — the app gives you a clear picture of your giving journey with no accounts, no cloud, and no ads.

All data stays on your device using SwiftData. Payments are recorded manually or initiated through UPI deep links to Google Pay, PhonePe, Paytm, or BHIM.

---

## Features

### Donation Categories
- Create unlimited categories for **Zakat**, **Fitra**, **Khums**, **Sadaqah**, and **Custom** types
- Set a total obligation amount with contextual formula hints per type
- Track progress with a dual-layer progress bar (paid + set-aside)
- Add notes to any category

### Flexible Payment Recording
- **Pay Now** — records a transaction as immediately paid; updates progress
- **Set Aside** — saves amount in a pending pool for later payment
- Mark individual pending transactions as paid from the category detail screen
- **Pay All Now** banner to settle all pending amounts at once

### Daily Tracker
- Set a daily Sadaqah amount that accumulates automatically
- **Pause** freezes the balance; **Resume** continues from exactly where you left off
- Convert accumulated amount to a transaction with Pay Now or Set Aside choice
- Full conversion history with session log

### Transaction History
- Grouped by month with paid/pending totals per group
- Filter by All / Paid / Pending
- Sort by date (newest/oldest) or amount (highest/lowest)
- Full-text search across notes, payment methods, and category names

### UPI Payments
- Deep-link directly into Google Pay (`tez://`), PhonePe, Paytm, or BHIM
- Auto-detects installed UPI apps at sheet open time
- Pre-fills UPI ID, recipient name, amount, and note in the target app
- Quick-select preset charity recipients

### Notifications
- Daily Sadaqah reminder at configurable time
- Ramadan Fitra reminder (late Ramadan)
- Zakat yearly reminder (Islamic New Year approximation)

### Data & Privacy
- 100% on-device — no accounts, no sync, no analytics
- Reset all transactions or full app data from Settings
- Export to PDF / CSV (coming soon)

---

## Screenshots

> Add screenshots to `Resources/Screenshots/` and reference them here.

| Dashboard | Category Detail | Daily Tracker | Add Transaction |
|-----------|----------------|---------------|----------------|
| _(screenshot)_ | _(screenshot)_ | _(screenshot)_ | _(screenshot)_ |

---

## Architecture

The app follows **MVVM** with a clean layered dependency graph:

```
Views
  └── ViewModels  (@MainActor ObservableObject)
        └── Services  (DonationService, UPIService, NotificationService)
              └── Domain  (Models, Enums)
                    └── Persistence  (SwiftData ModelContainer)
```

**Key conventions:**
- All business logic lives in ViewModels, never in Views
- Services are protocol-backed for testability
- SwiftData `@Model` classes are the single source of truth for persistent state
- `DailyTrackerSettings` is UserDefaults-backed (Codable) — not SwiftData — because it changes frequently and doesn't need relational storage
- All user-facing strings are centralised in `AppStrings.swift` (plain static constants, no NSLocalizedString overhead)
- All brand colours are accessed via `Color.App.*` extension
- All SF Symbol names are centralised in `AppIcons` enum

---

## Project Structure

```
FairFuture/
│
├── App/
│   ├── FairFutureApp.swift        @main entry, ModelContainer, launch screen
│   └── RootView.swift                TabView shell (4 tabs)
│
├── Core/
│   ├── Constants/
│   │   ├── AppStrings.swift          All user-facing strings
│   │   └── AppConstants.swift        Color.App.* + AppIcons enum
│   ├── Extensions/
│   │   └── Extensions.swift          Color(hex:), Double.formatted,
│   │                                 Date.displayDate, cardStyle()
│   │                                 Formatters (cached DateFormatter/NumberFormatter)
│   └── Utilities/
│       └── LocalizationManager.swift In-app language switching (en/hi/ur)
│
├── Domain/
│   ├── Models/
│   │   └── Models.swift              @Model DonationCategory, DonationTransaction,
│   │                                 DailyTrackerSettings (Codable)
│   └── Enums/
│       └── Enums.swift               DonationType, PaymentMethod
│
├── Data/
│   ├── Persistence/
│   │   └── PersistenceController.swift  SwiftData ModelContainer + preview seeds
│   └── Services/
│       ├── DonationService.swift     CRUD for categories & transactions
│       ├── UPIService.swift          UPI deep-link URL builder + app detection
│       └── NotificationService.swift UNUserNotificationCenter scheduling
│
├── Features/
│   ├── Dashboard/
│   │   ├── Views/DashboardView.swift
│   │   └── ViewModels/DashboardViewModel.swift
│   ├── CategoryDetail/
│   │   └── Views/CategoryDetailView.swift
│   ├── Transactions/
│   │   ├── Views/AddViews.swift          AddTransactionSheet + AddCategorySheet
│   │   ├── Views/TransactionHistoryView.swift
│   │   └── ViewModels/TransactionViewModel.swift
│   ├── DailyTracker/
│   │   ├── Views/DailyTrackerView.swift
│   │   └── ViewModels/TrackerHistoryViewModel.swift
│   └── Settings/
│       └── Views/SettingsView.swift
│
├── SharedUI/
│   └── Components/
│       └── ReusableComponents.swift  DonationCardView, TransactionRowView,
│                                     CategoryHeaderView, SummaryStatCard,
│                                     EmptyStateView
│
├── Resources/
│   ├── AppIcon/                      13 PNG sizes + Contents.json + SVG master
│   ├── Localizable/
│   │   └── Localizable.xcstrings     String Catalog (en, hi, ur)
│   └── Assets.xcassets
│
└── Views/
    └── LaunchScreenView.swift        Animated splash (FFGeometricMark Canvas)
```

---

## Requirements

| Requirement | Version |
|-------------|---------|
| iOS | 17.0+ |
| Xcode | 15.0+ |
| Swift | 5.9+ |
| macOS (dev) | Ventura 13.5+ |

**Frameworks used:**
- SwiftUI, SwiftData, Charts (all built-in, no third-party dependencies)
- UserNotifications
- UIKit (UPI `canOpenURL` / `open` only)

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/shabi/FairFuture.git
cd FairFuture
```

### 2. Open in Xcode

```bash
open FairFuture.xcodeproj
```

### 3. Set your development team

In Xcode: **FairFuture target → Signing & Capabilities**
- Check **Automatically manage signing**
- Select your **Team** (Apple ID personal team works for device testing)
- Set a unique **Bundle Identifier** e.g. `com.shabiapps.FairFuture`

### 4. Run on Simulator or Device

Press **⌘R** or tap the Run button.

> **Note:** UPI payment features require a physical iPhone with Google Pay, PhonePe, or Paytm installed. They will not work on Simulator.

---

## Configuration

### Info.plist — Required for UPI

Add the following to `Info.plist` (open as Source Code):

```xml
<!-- UPI app detection — required for canOpenURL to work on iOS 9+ -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>tez</string>       <!-- Google Pay -->
    <string>phonepe</string>   <!-- PhonePe -->
    <string>paytmmp</string>   <!-- Paytm -->
    <string>bhim</string>      <!-- BHIM -->
    <string>upi</string>       <!-- Generic UPI fallback -->
</array>

<!-- Notification usage description -->
<key>NSUserNotificationUsageDescription</key>
<string>Fair Future sends reminders for Zakat, Fitra and daily Sadaqah.</string>
```

After editing Info.plist always do a **Clean Build Folder** (`⇧⌘K`) before running.

### Launch Background Color (prevents white flash)

In `Assets.xcassets` create a **New Color Set** named `LaunchBackground`:
- Any Appearance: `#2E7D6B`
- Dark Appearance: `#1B5E4F`

Then in Info.plist add:
```xml
<key>UILaunchScreen</key>
<dict>
    <key>UIColorName</key>
    <string>LaunchBackground</string>
</dict>
```

---

## Key Modules

### DonationService

The central data mutation layer. All writes go through here — never directly via the ModelContext in views.

```swift
// Add a paid transaction
try service.addTransaction(
    to: category,
    amount: 500,
    date: .now,
    notes: "Masjid donation",
    paymentMethod: .upi,
    isPaid: true,
    context: context
)

// Mark a set-aside transaction as paid
try service.markAsPaid(transaction, category: category, context: context)

// Reset all data
try service.resetEverything(categories: categories, context: context)
```

### DailyTrackerViewModel

Manages the accumulation tracker. State is persisted to UserDefaults as a `Codable` struct.

```swift
vm.startTracking()           // begins accumulation from now
vm.pauseTracking()           // freezes balance in UserDefaults
vm.resumeTracking()          // resumes from frozen balance
try vm.convertToTransaction(category: cat, context: ctx, isPaid: true)
```

**Reset notification:** When Settings resets all data, it posts `Notification.Name.trackerDidReset`. The ViewModel observes this via an async `NotificationCenter` stream and wipes its in-memory state immediately — no stale history shown.

### TransactionStats (single-pass performance)

`DonationCategory` exposes a `transactionStats` computed property that traverses the transactions array **once** to return both `paidTotal` and `unpaidTotal`. Views read from this struct rather than calling `filter/reduce` separately.

```swift
let stats = category.transactionStats
// stats.paidTotal
// stats.unpaidTotal
// stats.hasPending
```

---

## UPI Payment Integration

### How it works

The app uses iOS URL scheme deep links to open UPI apps pre-filled with payment details. It does **not** process payments itself — the user completes the payment inside the UPI app and confirms in Fair Future.

### URL formats

| App | Scheme | URL format |
|-----|--------|-----------|
| Google Pay | `tez://` | `tez://upi/pay?pa=...&pn=...&am=...&cu=INR&tn=...` |
| PhonePe | `phonepe://` | `upi://pay?pa=...&pn=...&am=...&cu=INR&tn=...` |
| Paytm | `paytmmp://` | `upi://pay?pa=...&pn=...&am=...&cu=INR&tn=...` |
| BHIM | `bhim://` | `upi://pay?pa=...&pn=...&am=...&cu=INR&tn=...` |

### App detection

`UPIService.availableUPIApps()` calls `canOpenURL` once per app when the `AddTransactionSheet` appears (`.onAppear`), caches the result, and returns only installed apps. This avoids calling `canOpenURL` on every SwiftUI render pass.

### Limitations

UPI deep links from **non-NPCI-registered apps** may be rejected by some bank backends with errors like "bank not found" or "transaction limit exceeded". This is a platform-level restriction — not a bug. The feature works reliably for launching the UPI app and pre-filling details; actual transaction success depends on the recipient UPI ID being valid and the bank allowing third-party deep links.

For reliable UPI in a production app intended for wider distribution, NPCI merchant registration is required.

---

## Notifications

Three notification types are scheduled on first launch (after permission is granted):

| Notification | Schedule | ID |
|---|---|---|
| Daily Sadaqah reminder | Daily at user-configured time (default 7:00 AM) | `daily_sadaqa_reminder` |
| Ramadan Fitra reminder | March 28 at 8:00 AM (approximate) | `ramadan_fitra_reminder` |
| Zakat yearly reminder | July 1 at 9:00 AM (Islamic New Year approx.) | `zakat_yearly_reminder` |

Toggle each from **Settings → Notifications**. The daily reminder time is configurable via a picker.

---

## App Icon & Launch Screen

### Icon

The **ff** mark is a custom geometric letterform — two `f` characters with straight stems, clean cubic-bezier hooks, a shared crossbar, and a gold nuqta dot. It is drawn entirely as SVG path data with no font files, making it copyright-free.

**Master source:** `Resources/AppIcon/AppIcon-ff-logo.svg`

To regenerate all PNG sizes from scratch, run:
```bash
python3 Resources/AppIcon/generate_icons.py
```

### Launch Screen

`LaunchScreenView.swift` contains `FFGeometricMark` — a SwiftUI `Canvas` view that redraws the icon letterforms using the exact same Bézier control points as the SVG. No image assets are used. The launch sequence:

1. ff logo springs in (0.08s delay, spring animation)
2. "ff · fam finance" name slides up (0.5s delay)
3. Decorative rule expands outward (0.65s)
4. Gold dot pops with spring (0.82s)
5. Arabic tagline fades in (1.0s)
6. After 1.8s total, cross-fades into RootView

---

## Localization

The app ships with an `AppStrings.swift` file containing all user-facing strings as plain Swift `static let` constants. This gives zero-runtime-overhead string access with a single file to update for any text changes.

A `Localizable.xcstrings` String Catalog is included with translations for:
- 🇬🇧 English (default)
- 🇮🇳 Hindi
- 🇵🇰 Urdu (RTL)

**To activate localization** (currently disabled for performance):
1. Replace `static let` values in `AppStrings.swift` with `NSLocalizedString(key:value:comment:)` calls
2. Add the `Localizable.xcstrings` file to your Xcode target
3. Add `LocalizationManager.swift` to the project and wire it in `FairFutureApp`

> **Why is localization off by default?** `NSLocalizedString` + `LocalizationManager` as an `@EnvironmentObject` caused noticeable UI lag by forcing full view-tree re-evaluation on every render. The plain string constants approach is instant.

---

## Performance

Several performance optimizations are baked into the codebase:

| Problem | Solution |
|---------|----------|
| `DateFormatter` allocated on every `displayDate` call | Static cached `Formatters.displayDate` / `Formatters.monthYear` |
| `Color(hex:)` running Scanner on every render | `colorCache` dictionary — parsed once per unique hex string |
| `transactions.filter + reduce` called separately for each computed property | Single-pass `TransactionStats` struct on `DonationCategory` |
| `canOpenURL` called on every SwiftUI render | `UPIService._cachedApps` — refreshed once on sheet appear |
| `LocalizationManager` as `@ObservableObject` at root causing full tree re-renders | Removed — plain string constants used instead |

---

## Known Limitations

- **UPI payments on Simulator:** `canOpenURL` always returns `false`. Test on a physical device.
- **UPI merchant registration:** Deep links from unregistered apps may be rejected by some banks. This is a platform limitation, not a bug.
- **SwiftData migrations:** Adding new fields to `@Model` classes requires either a lightweight migration or a clean install. The `PersistenceController` handles this automatically for additive changes.
- **Daily Tracker accuracy:** The accumulation is day-based, not hour-based. Partial days count as full days.
- **Export feature:** PDF and CSV export are UI placeholders — not yet implemented.
- **iCloud Sync:** Not implemented. All data is local only.

---

## Roadmap

- [ ] PDF export of full transaction history
- [ ] CSV export for spreadsheet import
- [ ] iCloud sync via SwiftData CloudKit backend
- [ ] Nisab calculator (integrated gold/silver price fetch)
- [ ] Zakat calculator with asset categories
- [ ] Widgets (Home Screen + Lock Screen) — daily tracker balance
- [ ] Shortcut / Siri intent — "Add ₹100 to my Sadaqah"
- [ ] Multiple currency support
- [ ] App Store release

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Follow the existing architecture — business logic in ViewModels, strings in `AppStrings`, colours via `Color.App.*`
4. Commit with a clear message: `git commit -m "feat: add Nisab calculator"`
5. Open a Pull Request with a description of what changed and why

---

## License

```
MIT License

Copyright (c) 2026 Shabi Haider

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```

---

<p align="center">
  Made with ❤️ and بارك الله فيك
</p>
