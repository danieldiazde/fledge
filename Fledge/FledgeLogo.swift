//
//  FledgeLogo.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//
import SwiftUI

struct FledgeLogo: View {
    let isAppeared: Bool
    var size: CGFloat = 80
    
    @State private var breathe = false
    @State private var starOpacity: CGFloat = 0
    
    // Simplified 8-star bird — same language as The Sky
    let stars: [(x: CGFloat, y: CGFloat)] = [
        (0.50, 0.52), // body center
        (0.50, 0.38), // head
        (0.28, 0.42), // left wing outer
        (0.38, 0.48), // left wing inner
        (0.72, 0.42), // right wing outer
        (0.62, 0.48), // right wing inner
        (0.44, 0.66), // tail left
        (0.56, 0.65), // tail right
    ]
    
    let connections: [(Int, Int)] = [
        (0, 1), // body to head
        (0, 3), (3, 2), // left wing
        (0, 5), (5, 4), // right wing
        (0, 6), (0, 7), // tail
        (2, 4), // wing tip to tip — top arc
    ]
    
    var pillarColors: [Color] = [
        Color.accentColor,                              // body
        Color.accentColor,                              // head
        Color(red: 0.4, green: 0.55, blue: 0.9),       // left wing (city)
        Color(red: 0.4, green: 0.55, blue: 0.9),       // left wing inner
        Color(red: 0.3, green: 0.78, blue: 0.5),       // right wing (growth)
        Color(red: 0.3, green: 0.78, blue: 0.5),       // right wing inner
        Color.accentColor,                              // tail
        Color.accentColor,                              // tail
    ]
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, canvasSize in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let breathIntensity = (sin(time * 1.8) + 1.0) / 2.0
                
                // Draw connections
                for (a, b) in connections {
                    let posA = CGPoint(
                        x: stars[a].x * canvasSize.width,
                        y: stars[a].y * canvasSize.height
                    )
                    let posB = CGPoint(
                        x: stars[b].x * canvasSize.width,
                        y: stars[b].y * canvasSize.height
                    )
                    var path = Path()
                    path.move(to: posA)
                    path.addLine(to: posB)
                    context.stroke(
                        path,
                        with: .color(Color.white.opacity(isAppeared ? 0.25 : 0)),
                        lineWidth: 1
                    )
                }
                
                // Draw stars
                for (i, star) in stars.enumerated() {
                    let pos = CGPoint(
                        x: star.x * canvasSize.width,
                        y: star.y * canvasSize.height
                    )
                    let color = pillarColors[i]
                    let glow = isAppeared ? (0.5 + 0.3 * breathIntensity) : 0.0
                    let glowRadius = isAppeared ? (5.0 + 2.5 * breathIntensity) : 0.0
                    let dotRadius: CGFloat = i == 0 ? 4.0 : 3.0
                    
                    // Glow
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: pos.x - glowRadius, y: pos.y - glowRadius,
                            width: glowRadius * 2, height: glowRadius * 2
                        )),
                        with: .color(color.opacity(glow * 0.3))
                    )
                    
                    // Core
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: pos.x - dotRadius, y: pos.y - dotRadius,
                            width: dotRadius * 2, height: dotRadius * 2
                        )),
                        with: .color(color.opacity(isAppeared ? glow : 0))
                    )
                }
            }
        }
        .frame(width: size, height: size)
    }
}
