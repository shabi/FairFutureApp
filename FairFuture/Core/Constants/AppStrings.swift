import Foundation

// MARK: - AppStrings
// All user-facing strings centralised here.
// Views reference these instead of inline string literals.
// NSLocalizedString keys must match the entries in Localizable.xcstrings.

enum AppStrings {

    // MARK: General
    enum General {
        static let cancel       = NSLocalizedString("general.cancel",       value: "Cancel",       comment: "Cancel button")
        static let save         = NSLocalizedString("general.save",         value: "Save",         comment: "Save button")
        static let done         = NSLocalizedString("general.done",         value: "Done",         comment: "Done button")
        static let delete       = NSLocalizedString("general.delete",       value: "Delete",       comment: "Delete action")
        static let ok           = NSLocalizedString("general.ok",           value: "OK",           comment: "OK button")
        static let add          = NSLocalizedString("general.add",          value: "Add",          comment: "Add button")
        static let edit         = NSLocalizedString("general.edit",         value: "Edit",         comment: "Edit button")
        static let resume       = NSLocalizedString("general.resume",       value: "Resume",       comment: "Resume action")
        static let pause        = NSLocalizedString("general.pause",        value: "Pause",        comment: "Pause action")
        static let error        = NSLocalizedString("general.error",        value: "Error",        comment: "Error title")
        static let success      = NSLocalizedString("general.success",      value: "Done!",        comment: "Success title")
        static let optional_    = NSLocalizedString("general.optional",     value: "Optional",     comment: "Optional field hint")
        static let perDay       = NSLocalizedString("general.per_day",      value: "per day",      comment: "Per day suffix")
    }

    // MARK: Tabs
    enum Tabs {
        static let dashboard    = NSLocalizedString("tab.dashboard",    value: "Dashboard",  comment: "Dashboard tab")
        static let history      = NSLocalizedString("tab.history",      value: "History",    comment: "History tab")
        static let tracker      = NSLocalizedString("tab.tracker",      value: "Tracker",    comment: "Tracker tab")
        static let settings     = NSLocalizedString("tab.settings",     value: "Settings",   comment: "Settings tab")
    }

    // MARK: Dashboard
    enum Dashboard {
        static let title            = NSLocalizedString("dashboard.title",              value: "Fair Future",     comment: "Dashboard nav title")
        static let greeting         = NSLocalizedString("dashboard.greeting",           value: "السَّلَامُ عَلَيْكُمْ", comment: "Arabic greeting")
        static let givingJourney    = NSLocalizedString("dashboard.giving_journey",     value: "Your Giving Journey", comment: "Dashboard subtitle")
        static let totalPaid        = NSLocalizedString("dashboard.total_paid",         value: "Total Paid",          comment: "Total paid label")
        static let obligation       = NSLocalizedString("dashboard.obligation",         value: "Obligation",          comment: "Obligation stat")
        static let paid             = NSLocalizedString("dashboard.paid",               value: "Paid",                comment: "Paid stat")
        static let remaining        = NSLocalizedString("dashboard.remaining",          value: "Remaining",           comment: "Remaining stat")
        static let yearlyGiving     = NSLocalizedString("dashboard.yearly_giving",      value: "Yearly Giving",       comment: "Chart section title")
        static let monthlyTotals    = NSLocalizedString("dashboard.monthly_totals",     value: "Monthly donation totals", comment: "Chart subtitle")
        static let categories       = NSLocalizedString("dashboard.categories",         value: "Categories",          comment: "Categories section")
        static let activeCount      = NSLocalizedString("dashboard.active_count",       value: "%d active",           comment: "Active category count — %d is the number")
        static let noCategoriesTitle    = NSLocalizedString("dashboard.no_categories_title",    value: "No Categories Yet",           comment: "Empty state title")
        static let noCategoriesSubtitle = NSLocalizedString("dashboard.no_categories_subtitle", value: "Add your first donation category to start tracking.", comment: "Empty state subtitle")
        static let addCategory      = NSLocalizedString("dashboard.add_category",       value: "Add Category",        comment: "Add category button")
        static let of               = NSLocalizedString("dashboard.of",                 value: "of %@",               comment: "Fraction label e.g. 'of ₹18,500'")
        static let percentPaid      = NSLocalizedString("dashboard.percent_paid",       value: "%d%%",                comment: "Progress percent label")
    }

    // MARK: Category Detail
    enum CategoryDetail {
        static let history          = NSLocalizedString("category_detail.history",          value: "History",               comment: "Transaction history section")
        static let records          = NSLocalizedString("category_detail.records",          value: "%d records",            comment: "Record count label")
        static let noRecordsTitle   = NSLocalizedString("category_detail.no_records_title", value: "No Records Yet",        comment: "Empty state title")
        static let noRecordsSub     = NSLocalizedString("category_detail.no_records_sub",   value: "Tap Add to record a payment or set money aside.", comment: "Empty state subtitle")
        static let addRecord        = NSLocalizedString("category_detail.add_record",       value: "Add Record",            comment: "Add record button")
        static let totalObligation  = NSLocalizedString("category_detail.total_obligation", value: "Total Obligation",      comment: "Stat cell title")
        static let setAside         = NSLocalizedString("category_detail.set_aside",        value: "Set Aside",             comment: "Stat cell title")
        static let transactions     = NSLocalizedString("category_detail.transactions",     value: "Transactions",          comment: "Stat cell title")
        static let percentPaid      = NSLocalizedString("category_detail.percent_paid",     value: "%d%% paid",             comment: "Progress label")
        static let percentPending   = NSLocalizedString("category_detail.percent_pending",  value: "· %d%% incl. pending",  comment: "Progress pending suffix")
        static let fullyPaid        = NSLocalizedString("category_detail.fully_paid",       value: "Fully Paid",            comment: "Fully paid badge")
    }

    // MARK: Pending Banner
    enum PendingBanner {
        static let title        = NSLocalizedString("pending_banner.title",     value: "Pending — Set Aside",   comment: "Banner title")
        static let subtitle     = NSLocalizedString("pending_banner.subtitle",  value: "You've accumulated this amount but haven't confirmed payment yet.", comment: "Banner subtitle")
        static let awaiting     = NSLocalizedString("pending_banner.awaiting",  value: "Awaiting Payment",      comment: "Awaiting label")
        static let payAllNow    = NSLocalizedString("pending_banner.pay_all",   value: "Pay All Now",           comment: "Pay all button")
    }

    // MARK: Add Transaction
    enum AddTransaction {
        static let navTitle         = NSLocalizedString("add_tx.nav_title",         value: "Record Donation",           comment: "Sheet title")
        static let saveAndPay       = NSLocalizedString("add_tx.save_pay",          value: "Save & Pay",                comment: "Confirm button when isPaid=true")
        static let setAside         = NSLocalizedString("add_tx.set_aside_btn",     value: "Set Aside",                 comment: "Confirm button when isPaid=false")
        static let amount           = NSLocalizedString("add_tx.amount",            value: "Amount",                    comment: "Amount section label")
        static let date             = NSLocalizedString("add_tx.date",              value: "Date",                      comment: "Date field label")
        static let method           = NSLocalizedString("add_tx.method",            value: "Method",                    comment: "Payment method label")
        static let notes            = NSLocalizedString("add_tx.notes",             value: "Notes",                     comment: "Notes field label")
        static let remainingHint    = NSLocalizedString("add_tx.remaining_hint",    value: "Remaining obligation: %@",  comment: "Remaining amount hint — %@ is formatted amount")

        // Pay mode toggle
        static let payNow           = NSLocalizedString("add_tx.pay_now",           value: "Pay Now",                   comment: "Pay now mode title")
        static let payNowSub        = NSLocalizedString("add_tx.pay_now_sub",       value: "Mark as paid immediately",  comment: "Pay now subtitle")
        static let payNowHint       = NSLocalizedString("add_tx.pay_now_hint",      value: "This amount will be counted as paid and reflected in your progress immediately.", comment: "Pay now hint")
        static let setAsideTitle    = NSLocalizedString("add_tx.set_aside_title",   value: "Set Aside",                 comment: "Set aside mode title")
        static let setAsideSub      = NSLocalizedString("add_tx.set_aside_sub",     value: "Accumulate, pay later",     comment: "Set aside subtitle")
        static let setAsideHint     = NSLocalizedString("add_tx.set_aside_hint",    value: "This amount will be set aside in a pending pool. You can mark it as paid later when you actually send the money.", comment: "Set aside hint")

        // UPI
        static let upiTitle         = NSLocalizedString("add_tx.upi_title",         value: "UPI Payment",               comment: "UPI section title")
        static let upiId            = NSLocalizedString("add_tx.upi_id",            value: "UPI ID",                    comment: "UPI ID field label")
        static let upiIdPlaceholder = NSLocalizedString("add_tx.upi_id_ph",         value: "name@upi",                  comment: "UPI ID placeholder")
        static let recipient        = NSLocalizedString("add_tx.recipient",         value: "Recipient",                 comment: "Recipient field label")
        static let recipientName    = NSLocalizedString("add_tx.recipient_name",    value: "Name",                      comment: "Recipient name placeholder")
        static let payVia           = NSLocalizedString("add_tx.pay_via",           value: "Pay ₹%@ via %@",            comment: "Pay via UPI app button — %1 amount %2 app name")
        static let noUpiApp         = NSLocalizedString("add_tx.no_upi_app",        value: "No UPI app detected. Install Google Pay, PhonePe, or Paytm.", comment: "No UPI app warning")
    }

    // MARK: Add Category
    enum AddCategory {
        static let navTitle     = NSLocalizedString("add_cat.nav_title",    value: "New Category",          comment: "Sheet title")
        static let typeLabel    = NSLocalizedString("add_cat.type",         value: "Donation Type",         comment: "Type section label")
        static let nameLabel    = NSLocalizedString("add_cat.name",         value: "Category Name",         comment: "Name section label")
        static let namePH       = NSLocalizedString("add_cat.name_ph",      value: "e.g. Zakat 1446H",      comment: "Name placeholder")
        static let amountLabel  = NSLocalizedString("add_cat.amount",       value: "Total Obligation",      comment: "Amount section label")
        static let amountPH     = NSLocalizedString("add_cat.amount_ph",    value: "0.00",                  comment: "Amount placeholder")
        static let amountHint   = NSLocalizedString("add_cat.amount_hint",  value: "Leave blank for open-ended giving (e.g. Sadaqah).", comment: "Amount hint")
        static let fullGuide    = NSLocalizedString("add_cat.full_guide",   value: "Full Guide",            comment: "Full guide button")
        static let typeGuide    = NSLocalizedString("add_cat.type_guide",   value: "Donation Type Guide",   comment: "Guide sheet title")
        static let whyMultiple  = NSLocalizedString("add_cat.why_multiple", value: "Why create multiple?",  comment: "Why multiple section header")
        static let examples     = NSLocalizedString("add_cat.examples",     value: "Example names",         comment: "Example names label")
    }

    // MARK: Daily Tracker
    enum Tracker {
        static let navTitle             = NSLocalizedString("tracker.nav_title",          value: "Daily Tracker",                  comment: "Nav title")
        static let accumulatingDaily    = NSLocalizedString("tracker.accumulating",       value: "Accumulating Daily",             comment: "Active state label")
        static let pausedSavedUp        = NSLocalizedString("tracker.paused",             value: "Paused — Saved Up",              comment: "Paused state label")
        static let inactive             = NSLocalizedString("tracker.inactive",           value: "Tracker Inactive",               comment: "Inactive state label")
        static let daysOfGiving         = NSLocalizedString("tracker.days_giving",        value: "%d day of giving",               comment: "Singular days label")
        static let daysOfGivingPlural   = NSLocalizedString("tracker.days_giving_plural", value: "%d days of giving",              comment: "Plural days label")
        static let pausedResume         = NSLocalizedString("tracker.paused_hint",        value: "Paused — tap Resume to continue",comment: "Paused hint")
        static let lifetimeConverted    = NSLocalizedString("tracker.lifetime",           value: "Lifetime converted: %@",         comment: "Lifetime total label")
        static let convertBtn           = NSLocalizedString("tracker.convert_btn",        value: "Convert to Donation",            comment: "Convert button")
        static let pauseBtn             = NSLocalizedString("tracker.pause_btn",          value: "Pause",                          comment: "Pause button")
        static let resumeBtn            = NSLocalizedString("tracker.resume_btn",         value: "Resume Tracker",                 comment: "Resume button")
        static let convertPausedBtn     = NSLocalizedString("tracker.convert_paused_btn", value: "Convert Saved Amount Now",       comment: "Convert while paused button")
        static let startBtn             = NSLocalizedString("tracker.start_btn",          value: "Start Daily Tracker",            comment: "Start button")
        static let dailyAmountTitle     = NSLocalizedString("tracker.daily_amount_title", value: "Daily Amount",                   comment: "Config card title")
        static let dailyAmountSub       = NSLocalizedString("tracker.daily_amount_sub",   value: "Accumulates automatically every day", comment: "Config card subtitle")
        static let weekly               = NSLocalizedString("tracker.weekly",             value: "Weekly",                         comment: "Weekly projection label")
        static let monthly              = NSLocalizedString("tracker.monthly",            value: "Monthly",                        comment: "Monthly projection label")
        static let yearly               = NSLocalizedString("tracker.yearly",             value: "Yearly",                         comment: "Yearly projection label")
        static let historyTitle         = NSLocalizedString("tracker.history_title",      value: "Conversion History",             comment: "History card title")
        static let historySessions      = NSLocalizedString("tracker.history_sessions",   value: "%d sessions",                    comment: "Sessions count")
        static let paidBadge            = NSLocalizedString("tracker.paid_badge",         value: "Paid",                           comment: "Paid badge in history")
        static let setAsideBadge        = NSLocalizedString("tracker.set_aside_badge",    value: "Set Aside",                      comment: "Set aside badge in history")
        static let howItWorksTitle      = NSLocalizedString("tracker.how_it_works",       value: "How It Works",                   comment: "How it works card title")
        static let selectCategory       = NSLocalizedString("tracker.select_category",    value: "Select Category",                comment: "Category picker title")
        static let howToRecord          = NSLocalizedString("tracker.how_to_record",      value: "How to record?",                 comment: "Pay mode sheet title")
        static let converting           = NSLocalizedString("tracker.converting",         value: "Converting",                     comment: "Converting label in pay mode sheet")

        // Pay mode
        static let payNow               = NSLocalizedString("tracker.pay_now",            value: "Pay Now",                        comment: "Pay now option")
        static let payNowDetail         = NSLocalizedString("tracker.pay_now_detail",     value: "Records this amount as paid immediately.\nProgress and totals update right away.", comment: "Pay now detail")
        static let setAside             = NSLocalizedString("tracker.set_aside",          value: "Set Aside",                      comment: "Set aside option")
        static let setAsideDetail       = NSLocalizedString("tracker.set_aside_detail",   value: "Saves as pending — mark it paid later\nfrom the category detail screen.", comment: "Set aside detail")

        // Success messages
        static let successPaid          = NSLocalizedString("tracker.success_paid",       value: "Recorded as paid in \"%@\".",     comment: "Success paid message — %@ is category name")
        static let successSetAside      = NSLocalizedString("tracker.success_set_aside",  value: "Amount set aside in \"%@\". Mark it paid when you're ready.", comment: "Success set aside message")

        // How it works steps
        static let step1Title   = NSLocalizedString("tracker.step1_title", value: "Set a daily amount",           comment: "Step 1 title")
        static let step1Detail  = NSLocalizedString("tracker.step1_detail",value: "₹10/day builds up quietly in the background.", comment: "Step 1 detail")
        static let step2Title   = NSLocalizedString("tracker.step2_title", value: "Accumulates automatically",   comment: "Step 2 title")
        static let step2Detail  = NSLocalizedString("tracker.step2_detail",value: "Each passing day adds to your total.", comment: "Step 2 detail")
        static let step3Title   = NSLocalizedString("tracker.step3_title", value: "Pause anytime",               comment: "Step 3 title")
        static let step3Detail  = NSLocalizedString("tracker.step3_detail",value: "Balance is preserved. Resume whenever you're ready.", comment: "Step 3 detail")
        static let step4Title   = NSLocalizedString("tracker.step4_title", value: "Convert when ready",          comment: "Step 4 title")
        static let step4Detail  = NSLocalizedString("tracker.step4_detail",value: "Choose Pay Now or Set Aside — fully at your own pace.", comment: "Step 4 detail")
    }

    // MARK: Transaction History
    enum History {
        static let navTitle         = NSLocalizedString("history.nav_title",    value: "History",               comment: "Nav title")
        static let noTxTitle        = NSLocalizedString("history.no_tx_title",  value: "No Transactions",       comment: "Empty state title")
        static let noTxSub          = NSLocalizedString("history.no_tx_sub",    value: "Your donation history will appear here once you start recording payments.", comment: "Empty state subtitle")
        static let searchPrompt     = NSLocalizedString("history.search",       value: "Search notes, methods…",comment: "Search bar placeholder")
        static let allCategories    = NSLocalizedString("history.all_cats",     value: "All Categories",        comment: "Filter option")
        static let filterCategory   = NSLocalizedString("history.filter_cat",   value: "Filter by Category",    comment: "Filter menu title")
        static let pending          = NSLocalizedString("history.pending",      value: "PENDING",               comment: "Pending badge text")
        static let markAsPaid       = NSLocalizedString("history.mark_paid",    value: "Mark as Paid",          comment: "Mark as paid button")
    }

    // MARK: Settings
    enum Settings {
        static let navTitle             = NSLocalizedString("settings.nav_title",           value: "Settings",                  comment: "Nav title")
        static let notifications        = NSLocalizedString("settings.notifications",       value: "Notifications",             comment: "Section header")
        static let dailyReminder        = NSLocalizedString("settings.daily_reminder",      value: "Daily Sadaqah Reminder",    comment: "Toggle label")
        static let reminderTime         = NSLocalizedString("settings.reminder_time",       value: "Reminder Time",             comment: "Picker label")
        static let zakatReminder        = NSLocalizedString("settings.zakat_reminder",      value: "Zakat Yearly Reminder",     comment: "Toggle label")
        static let fitraReminder        = NSLocalizedString("settings.fitra_reminder",      value: "Ramadan Fitra Reminder",    comment: "Toggle label")
        static let upiSettings          = NSLocalizedString("settings.upi_settings",        value: "Default UPI Settings",      comment: "Section header")
        static let upiId                = NSLocalizedString("settings.upi_id",              value: "Your UPI ID",               comment: "Field label")
        static let upiName              = NSLocalizedString("settings.upi_name",            value: "Default Recipient Name",    comment: "Field label")
        static let upiFooter            = NSLocalizedString("settings.upi_footer",          value: "Used as the default recipient when making UPI payments.", comment: "Section footer")
        static let export               = NSLocalizedString("settings.export",              value: "Export",                    comment: "Section header")
        static let exportPDF            = NSLocalizedString("settings.export_pdf",          value: "Export as PDF",             comment: "Button label")
        static let exportCSV            = NSLocalizedString("settings.export_csv",          value: "Export as CSV",             comment: "Button label")
        static let exportFooter         = NSLocalizedString("settings.export_footer",       value: "Export your full donation history. (Coming soon)", comment: "Section footer")
        static let dataReset            = NSLocalizedString("settings.data_reset",          value: "Data & Reset",              comment: "Section header")
        static let resetTransactions    = NSLocalizedString("settings.reset_tx",            value: "Reset All Transactions",    comment: "Button label")
        static let resetEverything      = NSLocalizedString("settings.reset_all",           value: "Reset Everything",          comment: "Button label")
        static let about                = NSLocalizedString("settings.about",               value: "About",                     comment: "Section header")
        static let language             = NSLocalizedString("settings.language",            value: "Language",                  comment: "Language row label")
        static let appLanguage          = NSLocalizedString("settings.app_language",        value: "App Language",              comment: "Language sheet title")
    }

    // MARK: Errors
    enum Errors {
        static let invalidAmount    = NSLocalizedString("error.invalid_amount",     value: "Please enter a valid amount.",   comment: "Amount validation error")
        static let invalidName      = NSLocalizedString("error.invalid_name",       value: "Please enter a category name.", comment: "Name validation error")
        static let noUpiApp         = NSLocalizedString("error.no_upi_app",         value: "No UPI app found. Install Google Pay, PhonePe, or Paytm and try again.", comment: "No UPI app error")
        static let upiAppFailed     = NSLocalizedString("error.upi_app_failed",     value: "%@ is not installed or could not be opened.", comment: "UPI app open failed — %@ is app name")
    }
}
