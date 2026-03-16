import SwiftUI
import Combine

// MARK: - AppLanguage

enum AppLanguage: String, CaseIterable, Identifiable {
    case system  = "system"
    case english = "en"
    case hindi   = "hi"
    case urdu    = "ur"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:  return "System Default"
        case .english: return "English"
        case .hindi:   return "हिन्दी (Hindi)"
        case .urdu:    return "اردو (Urdu)"
        }
    }

    /// True if the language is written right-to-left
    var isRTL: Bool { self == .urdu }

    /// The Locale to inject into the SwiftUI environment.
    /// .system returns the device's current locale.
    var locale: Locale {
        self == .system ? .current : Locale(identifier: rawValue)
    }

    /// Layout direction for the SwiftUI environment
    var layoutDirection: LayoutDirection {
        isRTL ? .rightToLeft : .leftToRight
    }
}

// MARK: - LocalizationManager

/// Holds the user's chosen language preference and exposes it to the
/// SwiftUI environment via `.environment(\.locale, ...)`.
///
/// Usage in App entry point:
/// ```swift
/// @StateObject private var localization = LocalizationManager.shared
///
/// WindowGroup {
///     RootView()
///         .environment(\.locale, localization.locale)
///         .environment(\.layoutDirection, localization.layoutDirection)
///         .environmentObject(localization)
/// }
/// ```
@MainActor
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    private let storageKey = "app_language"

    @Published var selectedLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: storageKey)
        }
    }

    var locale: Locale { selectedLanguage.locale }
    var layoutDirection: LayoutDirection { selectedLanguage.layoutDirection }

    init() {
        let stored = UserDefaults.standard.string(forKey: "app_language") ?? "system"
        selectedLanguage = AppLanguage(rawValue: stored) ?? .system
    }
}

// MARK: - Language Picker View
// Drop this into SettingsView inside a Section.

struct LanguagePickerRow: View {
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        NavigationLink {
            languageList
        } label: {
            HStack {
                Label(AppStrings.Settings.language, systemImage: "globe")
                Spacer()
                Text(localization.selectedLanguage.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var languageList: some View {
        List(AppLanguage.allCases) { lang in
            Button {
                withAnimation { localization.selectedLanguage = lang }
            } label: {
                HStack {
                    Text(lang.displayName)
                        .foregroundStyle(.primary)
                    Spacer()
                    if localization.selectedLanguage == lang {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.App.primary)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .navigationTitle(AppStrings.Settings.appLanguage)
        .navigationBarTitleDisplayMode(.inline)
    }
}
