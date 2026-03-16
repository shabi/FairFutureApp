import Foundation
import SwiftUI

// MARK: - DonationType

enum DonationType: String, Codable, CaseIterable, Identifiable {
    case zakat    = "Zakat"
    case fitra    = "Fitra"
    case khums    = "Khums"
    case sadaqa   = "Sadaqah"
    case custom   = "Custom"

    var id: String { rawValue }

    /// One-line summary shown in pickers and cards.
    var description: String {
        switch self {
        case .zakat:  return "Annual obligatory charity — 2.5% of savings above nisab"
        case .fitra:  return "Zakat al-Fitr — fixed amount paid before Eid al-Fitr prayer"
        case .khums:  return "One-fifth (20%) of annual surplus income"
        case .sadaqa: return "Voluntary charitable giving at any time"
        case .custom: return "Any other charity or contribution you want to track"
        }
    }

    /// Full explanation of what this type is and how it works.
    var fullExplanation: String {
        switch self {
        case .zakat:
            return "Zakat is one of the Five Pillars of Islam. Every Muslim whose savings exceed the nisab threshold (equivalent of ~85g gold or ~595g silver) for a full lunar year must pay 2.5% of those savings as Zakat. It must reach specific eligible recipients (the 8 categories in the Quran) and cannot be paid to parents, children, or a spouse.\n\nEnter your total calculated Zakat obligation as the category amount, then record payments against it as you distribute."
        case .fitra:
            return "Zakat al-Fitr (Fitra) is a fixed per-head charity due from every Muslim before the Eid al-Fitr prayer at the end of Ramadan. The amount is set each year by scholars and is typically equivalent to one sa' (roughly 2–3 kg) of a staple food, converted to cash.\n\nYou pay it on behalf of yourself and every dependent (spouse, children, elderly parents) in your household. Create one Fitra category per year or per household cycle."
        case .khums:
            return "Khums literally means 'one-fifth.' In Shia Islamic jurisprudence, 20% of annual surplus income (money left over after all legitimate expenses at the end of your Khums year) is obligatory. It is split equally between Sahm al-Imam (the Imam's share) and Sahm al-Sadat (descendants of the Prophet ﷺ).\n\nTrack your Khums year start and end, calculate surplus, then enter 20% of that as your total obligation."
        case .sadaqa:
            return "Sadaqah is any voluntary charitable act — money, food, time, a smile, or removing a harmful object from the road. Unlike Zakat, it has no minimum amount, no fixed time, and no specific recipients.\n\nUse Sadaqah categories to track ongoing giving to a cause, a person, or an institution. Since there is no obligation amount, you can leave the total blank and simply accumulate what you give."
        case .custom:
            return "Use Custom for any other religious or charitable contribution that does not fit the standard types — such as Waqf (endowment), Nazr (vow), Kaffarah (expiation), or donations to a specific cause or organisation.\n\nGive it a meaningful name so you can identify it at a glance on your dashboard."
        }
    }

    /// Why would someone create multiple categories of the same type?
    var whyMultiple: String {
        switch self {
        case .zakat:
            return "You might split Zakat across different recipients or years (e.g. \"Zakat 1445H\" and \"Zakat 1446H\"), or track Zakat on gold separately from Zakat on savings, or set aside Zakat for a specific cause like orphan sponsorship."
        case .fitra:
            return "A new Fitra category is typically created each Ramadan (e.g. \"Fitra Ramadan 1446\"). You may also create separate ones if you are paying on behalf of two different households, or if the per-head rate differs by region."
        case .khums:
            return "Your Khums year may not align with the calendar year. Create a new Khums category each year (e.g. \"Khums Year — Mar 2024–Mar 2025\"). You can also separate Sahm al-Imam and Sahm al-Sadat into two categories if you distribute them to different recipients."
        case .sadaqa:
            return "Sadaqah is the most flexible type. You might have one for your local masjid, one for a specific family you support, one for a charity campaign, and one for your daily sadaqah habit — all running simultaneously."
        case .custom:
            return "Custom categories are by definition independent of each other. Create as many as you need for different vows, expiations, endowments, or campaigns."
        }
    }

    /// Concrete example names to suggest to the user.
    var exampleNames: [String] {
        switch self {
        case .zakat:
            return ["Zakat 1446H", "Zakat on Savings 2025", "Zakat on Gold", "Zakat — Orphan Fund"]
        case .fitra:
            return ["Fitra Ramadan 1446", "Fitra 2025 — Family of 5", "Fitra — My Household"]
        case .khums:
            return ["Khums Year 2024–25", "Khums — Sahm al-Imam", "Khums — Sahm al-Sadat"]
        case .sadaqa:
            return ["Local Masjid Fund", "Neighbour Support", "Daily Sadaqah Habit", "Eid Food Parcels", "Water Well Project"]
        case .custom:
            return ["Kaffarah — Missed Fasts", "Nazr — Promise to Give", "Waqf Contribution", "Eid Gifts for Orphans"]
        }
    }

    var icon: String {
        switch self {
        case .zakat:  return "scalemass"
        case .fitra:  return "moon.stars"
        case .khums:  return "percent"
        case .sadaqa: return "heart"
        case .custom: return "star"
        }
    }

    var color: Color {
        switch self {
        case .zakat:  return Color(hex: "#2E7D6B")
        case .fitra:  return Color(hex: "#6B4FA0")
        case .khums:  return Color(hex: "#C0632A")
        case .sadaqa: return Color(hex: "#B5452E")
        case .custom: return Color(hex: "#2D6A9F")
        }
    }

    var accentColor: Color { color.opacity(0.15) }
}

// MARK: - PaymentMethod

enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
    case upi          = "UPI"
    case cash         = "Cash"
    case bankTransfer = "Bank Transfer"
    case manual       = "Manual"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .upi:          return "qrcode"
        case .cash:         return "banknote"
        case .bankTransfer: return "building.columns"
        case .manual:       return "pencil"
        }
    }
}
