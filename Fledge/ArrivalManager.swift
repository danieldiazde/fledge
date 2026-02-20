//
//  ArrivalManager.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 19/02/26.
//

import Foundation
import Combine

class ArrivalManager: ObservableObject {
    @Published var arrivalDate: Date
    @Published var hasSetArrivalDate: Bool
    
    var currentWeek: Int {
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
    
    func reset() {
        hasSetArrivalDate = false
        UserDefaults.standard.removeObject(forKey: "arrivalDate")
    }
}
