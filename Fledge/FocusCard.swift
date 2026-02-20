//
//  FocusCard.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 19/02/26.
//

import Foundation
import SwiftData

@Model
class FocusCard: Identifiable {
    var id: UUID
    var title: String
    var body: String
    var category: String
    var weekNumber: Int
    var isComplete: Bool

    init(title: String, body: String, category: String, weekNumber: Int) {
        self.id = UUID()
        self.title = title
        self.body = body
        self.category = category
        self.weekNumber = weekNumber
        self.isComplete = false
    }
}

