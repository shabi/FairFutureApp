import SwiftUI

// MARK: - AppColors
// Single source of truth for all brand colours.
// Reference as Color.App.primary, Color.App.pending, etc.

extension Color {
    enum App {
        /// Brand teal — primary action colour
        static let primary      = Color(hex: "#2E7D6B")
        /// Deeper teal — gradient end
        static let primaryDark  = Color(hex: "#1B5E4F")
        /// Zakat green
        static let zakat        = Color(hex: "#2E7D6B")
        /// Fitra purple
        static let fitra        = Color(hex: "#6B4FA0")
        /// Khums orange-brown
        static let khums        = Color(hex: "#C0632A")
        /// Sadaqah red
        static let sadaqa       = Color(hex: "#B5452E")
        /// Custom blue
        static let custom       = Color(hex: "#2D6A9F")
        /// Pending / set-aside orange — use system .orange directly;
        /// this alias keeps intent explicit
        static let pending      = Color.orange
    }
}

// MARK: - AppIcons
// SF Symbol names centralised so a single rename touches one file.

enum AppIcons {
    // Navigation / toolbar
    static let addFill          = "plus.circle.fill"
    static let add              = "plus"
    static let settings         = "gearshape"
    static let back             = "chevron.left"
    static let forward          = "chevron.right"

    // Tabs
    static let dashboard        = "square.grid.2x2"
    static let history          = "list.bullet.rectangle"
    static let tracker          = "sun.and.horizon"

    // Donation types
    static let zakat            = "scalemass"
    static let fitra            = "moon.stars"
    static let khums            = "percent"
    static let sadaqa           = "heart"
    static let custom           = "star"

    // Payment methods
    static let upi              = "qrcode"
    static let cash             = "banknote"
    static let bank             = "building.columns"
    static let manual           = "pencil"

    // States
    static let pending          = "clock.badge.plus"
    static let paid             = "checkmark.circle.fill"
    static let fullyPaid        = "checkmark.seal.fill"
    static let warning          = "exclamationmark.triangle.fill"
    static let hands            = "hands.and.sparkles"
    static let heart            = "heart"
    static let heartFill        = "heart.fill"
    static let trophy           = "trophy"
    static let calendar         = "calendar"
    static let clock            = "clock"
    static let arrowUpRight     = "arrow.up.right"
    static let convertArrows    = "arrow.triangle.2.circlepath"
    static let play             = "play.circle.fill"
    static let pauseCircle      = "pause.circle"
    static let tray             = "tray"
    static let empty            = "heart.text.square"

    // UPI apps (SF Symbol fallbacks)
    static let gpay             = "g.circle.fill"
    static let phonepe          = "p.circle.fill"
    static let paytm            = "indianrupeesign.circle.fill"
    static let bhim             = "b.circle.fill"
    static let anyUpi           = "creditcard.fill"
}
