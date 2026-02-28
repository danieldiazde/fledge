//
//  NotificationManager.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import Foundation
import UserNotifications
import SwiftUI


@MainActor
final class NotificationManager {
    
    static let shared = NotificationManager()
    private init() {}
    
    // MARK: - Constants

    private let checkInID     = "fledge.dailyMoodCheckIn"
    private let checkInHour   = 10
    private let checkInMinute = 0

    // MARK: - Public API

    func requestPermissionAndSchedule() {
        Task {
            let center   = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()

            switch settings.authorizationStatus {
            case .notDetermined:
                let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
                guard granted else { return }
                await scheduleDailyCheckIn()
            case .authorized, .provisional, .ephemeral:
                await scheduleDailyCheckIn()
            case .denied:
                break
            @unknown default:
                break
            }
        }
    }

    // MARK: - Private scheduling

    private func scheduleDailyCheckIn() async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [checkInID])

        let content       = UNMutableNotificationContent()
        content.title     = "Fledge"
        content.body      = "How are you feeling today? Take a second to check in."
        content.sound     = .default

        var components    = DateComponents()
        components.hour   = checkInHour
        components.minute = checkInMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: checkInID,
                                            content: content,
                                            trigger: trigger)

        try? await center.add(request)
    }
}
