//
//  SkyConstellation.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import CoreGraphics

/// Static geometry of the Fledge bird constellation.
///
/// Each star's position in `stars` maps one-to-one with `MissionData.all`:
/// `stars[i]` lights up when `MissionData.all[i].isComplete` is true.
/// `pillarIndex` is the mission's position within its pillar group and is
/// retained for reference — the lighting logic uses the array index only.
enum SkyConstellation {

    typealias Star = (x: CGFloat, y: CGFloat, pillar: Pillar, pillarIndex: Int)

    // MARK: - Stars

    static let stars: [Star] = [

        // Body & spine
        (0.48, 0.41, .adultMode, 0),
        (0.44, 0.47, .adultMode, 1),
        (0.55, 0.44, .adultMode, 2),
        (0.51, 0.51, .adultMode, 3),
        (0.52, 0.57, .adultMode, 4),

        // Head & neck
        (0.49, 0.34, .adultMode, 5),
        (0.45, 0.27, .adultMode, 6),
        (0.41, 0.21, .adultMode, 7),
        (0.50, 0.24, .adultMode, 10),
        (0.39, 0.30, .adultMode, 11),

        // Tail spine
        (0.54, 0.63, .adultMode, 8),
        (0.58, 0.70, .adultMode, 9),

        // Left wing
        (0.39, 0.38, .city, 0),
        (0.30, 0.31, .city, 1),
        (0.23, 0.23, .city, 2),
        (0.16, 0.16, .city, 3),
        (0.36, 0.44, .city, 4),
        (0.26, 0.36, .city, 5),
        (0.18, 0.31, .city, 6),
        (0.12, 0.24, .city, 7),
        (0.47, 0.60, .city, 8),
        (0.42, 0.67, .city, 9),
        (0.28, 0.26, .city, 10),
        (0.14, 0.19, .city, 11),

        // Right wing
        (0.59, 0.41, .growth, 0),
        (0.69, 0.37, .growth, 1),
        (0.79, 0.33, .growth, 2),
        (0.89, 0.30, .growth, 3),
        (0.63, 0.47, .growth, 4),
        (0.74, 0.44, .growth, 5),
        (0.84, 0.40, .growth, 6),
        (0.93, 0.37, .growth, 7),
        (0.61, 0.61, .growth, 8),
        (0.68, 0.66, .growth, 9),
        (0.72, 0.33, .growth, 10),
        (0.86, 0.34, .growth, 11),
    ]

    // MARK: - Connections

    static let connections: [(Int, Int)] = [
        (7, 6), (6, 5), (5, 0), (0, 3), (3, 4), (4, 10), (10, 11),
        (6, 8), (5, 9),
        (0, 1), (0, 2), (1, 3), (2, 3),
        (0, 12), (12, 13), (13, 22), (22, 14), (14, 15),
        (13, 16), (14, 17), (22, 18), (18, 19),
        (15, 23), (23, 19),
        (4, 20), (20, 21), (1, 16),
        (0, 24), (24, 25), (25, 34), (34, 26), (26, 27),
        (24, 28), (28, 29),
        (34, 30), (30, 31),
        (27, 35), (35, 31),
        (4, 32), (32, 33),
    ]
}
