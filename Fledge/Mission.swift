//
//  Mission.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import Foundation
import SwiftData

enum Pillar: String, Codable, CaseIterable {
    case city = "The City"
    case adultMode = "Adult Mode"
    case growth = "Your Growth"
    
    var icon: String {
        switch self {
        case .city: return "map"
        case .adultMode: return "wrench.and.screwdriver"
        case .growth: return "leaf"
        }
    }
}

@Model
class Mission: Identifiable {
    var id: UUID
    var title: String
    var truth: String
    var move: String
    var win: String
    var pillar: Pillar
    var weekNumber: Int
    var tags: [String]
    var duration: String
    var isComplete: Bool
    
    init(
        title: String,
        truth: String,
        move: String,
        win: String,
        pillar: Pillar,
        weekNumber: Int,
        tags: [String],
        duration: String
    ) {
        self.id = UUID()
        self.title = title
        self.truth = truth
        self.move = move
        self.win = win
        self.pillar = pillar
        self.weekNumber = weekNumber
        self.tags = tags
        self.duration = duration
        self.isComplete = false
    }
}
