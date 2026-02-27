//
//  ArrivalManager.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 19/02/26.
//

import Foundation
import Combine
import SwiftUI

class ArrivalManager: ObservableObject {
    @Published var arrivalDate: Date
    @Published var hasSetArrivalDate: Bool

    // For Apple review / testing: override the week
    @AppStorage("weekOverride") var weekOverride: Int = 0 

    var currentWeek: Int {
        if weekOverride > 0 { return min(weekOverride, 4) }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: arrivalDate, to: Date()).day ?? 0
        let week = (days / 7) + 1
        return min(week, 4)
    }

    init() {
        if let saved = UserDefaults.standard.object(forKey: "arrivalDate") as? Date {
            self.arrivalDate = saved
            self.hasSetArrivalDate = true
        } else {
            self.arrivalDate = Date()
            self.hasSetArrivalDate = false
        }
    }

    func completeOnboarding(with date: Date) {
        arrivalDate = date
        hasSetArrivalDate = true
        UserDefaults.standard.set(date, forKey: "arrivalDate")
    }

    func simulateWeek(_ week: Int) {
        weekOverride = week
    }

    func stopSimulating() {
        weekOverride = 0
    }

    func reset() {
        hasSetArrivalDate = false
        weekOverride = 0
        UserDefaults.standard.removeObject(forKey: "arrivalDate")
    }
}
