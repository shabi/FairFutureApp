import Foundation
import UserNotifications

// MARK: - NotificationServiceProtocol

protocol NotificationServiceProtocol {
    func requestAuthorization() async
    func scheduleDailySadaqaReminder(at hour: Int, minute: Int) async
    func scheduleRamadanFitraReminder() async
    func scheduleZakatYearlyReminder() async
    func cancelAllNotifications()
}

// MARK: - NotificationService

final class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()

    enum NotificationID {
        static let dailySadaqa   = "daily_sadaqa_reminder"
        static let ramadanFitra  = "ramadan_fitra_reminder"
        static let zakatYearly   = "zakat_yearly_reminder"
    }

    func requestAuthorization() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                await scheduleDefaultNotifications()
            }
        } catch {
            print("Notification auth error: \(error)")
        }
    }

    private func scheduleDefaultNotifications() async {
        await scheduleDailySadaqaReminder(at: 7, minute: 0)
        await scheduleRamadanFitraReminder()
        await scheduleZakatYearlyReminder()
    }

    // MARK: Daily Sadaqa

    func scheduleDailySadaqaReminder(at hour: Int, minute: Int) async {
        center.removePendingNotificationRequests(withIdentifiers: [NotificationID.dailySadaqa])

        let content = UNMutableNotificationContent()
        content.title = "Daily Sadaqah Reminder"
        content.body = "Don't forget your daily charitable giving. Every good deed counts! 🤲"
        content.sound = .default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationID.dailySadaqa, content: content, trigger: trigger)

        do {
            try await center.add(request)
        } catch {
            print("Daily reminder scheduling error: \(error)")
        }
    }

    // MARK: Ramadan Fitra Reminder (27th Ramadan ~)

    func scheduleRamadanFitraReminder() async {
        center.removePendingNotificationRequests(withIdentifiers: [NotificationID.ramadanFitra])

        let content = UNMutableNotificationContent()
        content.title = "Zakat al-Fitr Reminder"
        content.body = "Ramadan is ending soon. Make sure to pay your Fitra before Eid prayers! 🌙"
        content.sound = .default

        // Schedule for March 28 (approximate Ramadan end — adjust yearly)
        var dateComponents = DateComponents()
        dateComponents.month = 3
        dateComponents.day = 28
        dateComponents.hour = 8

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationID.ramadanFitra, content: content, trigger: trigger)

        do { try await center.add(request) } catch { print("Fitra reminder error: \(error)") }
    }

    // MARK: Yearly Zakat Reminder (1st Muharram approximation)

    func scheduleZakatYearlyReminder() async {
        center.removePendingNotificationRequests(withIdentifiers: [NotificationID.zakatYearly])

        let content = UNMutableNotificationContent()
        content.title = "Zakat Calculation Reminder"
        content.body = "A new Islamic year has begun. Time to review and calculate your Zakat obligations. ⚖️"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.month = 7
        dateComponents.day = 1
        dateComponents.hour = 9

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationID.zakatYearly, content: content, trigger: trigger)

        do { try await center.add(request) } catch { print("Zakat reminder error: \(error)") }
    }

    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}
