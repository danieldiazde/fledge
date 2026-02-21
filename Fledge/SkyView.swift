//
//  NestView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import SwiftUI

struct SkyView: View {
    @EnvironmentObject var arrivalManager: ArrivalManager
    @EnvironmentObject var userProfile: UserProfile
    @State private var appeared = false
    
    var allMissions: [Mission] { MissionData.all }
    var completedCount: Int { allMissions.filter { $0.isComplete }.count }
    var totalCount: Int { allMissions.count }
    var isFledged: Bool { completedCount == totalCount && totalCount > 0 }
    
    var statusLine: String {
        if completedCount == 0 {
            return "Your sky is waiting to be filled."
        } else if completedCount == totalCount {
            return "You fledged. ✦"
        } else {
            return "\(completedCount) of \(totalCount) stars lit. Keep going."
        }
    }
    
    let starLayout: [(x: CGFloat, y: CGFloat, pillar: Pillar, index: Int)] = [
            // --- BODY & SPINE (0-4) ---
            (0.48, 0.53, .adultMode, 0), // Core
            (0.44, 0.59, .adultMode, 1), // Left body offset
            (0.55, 0.56, .adultMode, 2), // Right body offset
            (0.51, 0.63, .adultMode, 3), // Lower spine
            (0.52, 0.69, .adultMode, 4), // Tail base

            // --- HEAD & NECK (5-9) (Turned slightly left) ---
            (0.49, 0.46, .adultMode, 5),  // Neck
            (0.45, 0.39, .adultMode, 6),  // Head
            (0.41, 0.33, .adultMode, 7),  // Beak tip
            (0.50, 0.36, .adultMode, 10), // Crest star (offshoot)
            (0.39, 0.42, .adultMode, 11), // Lower head star

            // --- TAIL SPINE (10-11) ---
            (0.54, 0.75, .adultMode, 8), // Mid tail (curving right)
            (0.58, 0.82, .adultMode, 9), // Low tail tip

            // --- LEFT WING (12-23) (Tucked and banking upward) ---
            (0.39, 0.50, .city, 0),  // Inner
            (0.30, 0.43, .city, 1),  // Mid
            (0.23, 0.35, .city, 2),  // Outer
            (0.16, 0.28, .city, 3),  // High Tip
            (0.36, 0.56, .city, 4),  // Trailing feather 1
            (0.26, 0.48, .city, 5),  // Trailing feather 2
            (0.18, 0.43, .city, 6),  // Trailing feather 3
            (0.12, 0.36, .city, 7),  // Low Tip
            (0.47, 0.72, .city, 8),  // Left tail flare
            (0.42, 0.79, .city, 9),  // Far left tail tip
            (0.28, 0.38, .city, 10), // Wing joint star
            (0.14, 0.31, .city, 11), // Scattered wing star

            // --- RIGHT WING (24-35) (Stretched long and wide) ---
            (0.59, 0.53, .growth, 0),  // Inner
            (0.69, 0.49, .growth, 1),  // Mid
            (0.79, 0.45, .growth, 2),  // Outer
            (0.89, 0.42, .growth, 3),  // High Tip
            (0.63, 0.59, .growth, 4),  // Trailing feather 1
            (0.74, 0.56, .growth, 5),  // Trailing feather 2
            (0.84, 0.52, .growth, 6),  // Trailing feather 3
            (0.93, 0.49, .growth, 7),  // Low Tip
            (0.61, 0.73, .growth, 8),  // Right tail flare
            (0.68, 0.78, .growth, 9),  // Far right tail tip
            (0.72, 0.45, .growth, 10), // Wing joint star
            (0.86, 0.46, .growth, 11)  // Scattered wing star
        ]

    let connections: [(Int, Int)] = [
            // The Central Spine (Beak through to the tip of the tail)
            (7, 6), (6, 5), (5, 0), (0, 3), (3, 4), (4, 10), (10, 11),
            
            // Head Details (Jagged branches, not triangles)
            (6, 8), (5, 9),
            
            // Wonky Body Core
            (0, 1), (0, 2), (1, 3), (2, 3),
            
            // Left Wing (Steep and jagged)
            (0, 12), (12, 13), (13, 22), (22, 14), (14, 15), // Main arm
            (13, 16), (14, 17), (22, 18), (18, 19),          // Dropped feathers
            (15, 23), (23, 19),                              // Wingtip loop
            (4, 20), (20, 21),  (1,16),                            // Left tail

            // Right Wing (Long, sweeping chains)
            (0, 24), (24, 25), (25, 34), (34, 26), (26, 27), // Main arm
            (24, 28), (28, 29),                              // Chain feather 1
            (34, 30), (30, 31),                              // Chain feather 2
            (27, 35), (35, 31),                              // Wingtip loop
            (4, 32), (32, 33)                                // Right tail
        ]
    
    func isStarLit(_ layoutIndex: Int) -> Bool {
        guard layoutIndex < allMissions.count else { return false }
        return allMissions[layoutIndex].isComplete
    }
    
    func isConnectionLit(_ a: Int, _ b: Int) -> Bool {
        isStarLit(a) && isStarLit(b)
    }
    
    func pillarColor(_ pillar: Pillar) -> Color {
        switch pillar {
        case .city: return Color(red: 0.5, green: 0.65, blue: 1.0)
        case .adultMode: return Color(red: 1.0, green: 0.65, blue: 0.45)
        case .growth: return Color(red: 0.5, green: 0.9, blue: 0.65)
        }
    }
    
    func triggerFledgeCelebration() {
            #if os(iOS)
            let impact = UIImpactFeedbackGenerator(style: .rigid)
            impact.prepare()
            impact.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                impact.impactOccurred(intensity: 0.8)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let success = UINotificationFeedbackGenerator()
                success.prepare()
                success.notificationOccurred(.success)
            }
            #endif
        }
    
    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.12, green: 0.10, blue: 0.28),
                    Color(red: 0.05, green: 0.05, blue: 0.18),
                    Color(red: 0.02, green: 0.02, blue: 0.10)
                ]),
                center: .top,
                startRadius: 100,
                endRadius: 800
            )
            .ignoresSafeArea()
            
            TimelineView(.animation) { timeline in
                GeometryReader { geo in
                    Canvas { context, size in
                        
                        let time = timeline.date.timeIntervalSinceReferenceDate
                        let breathIntensity = (sin(time * 2.0) + 1.0) / 2.0
                        
                        for i in 1...50 {
                            let bgX = CGFloat((i * 73) % 100) / 100.0 * size.width
                            let bgY = CGFloat((i * 91) % 100) / 100.0 * size.height
                            let twinkle = (sin(time * Double(i % 5) * 0.7) + 1.0) / 2.0
                            context.fill(
                                Path(ellipseIn: CGRect(x: bgX - 0.75, y: bgY - 0.75, width: 1.5, height: 1.5)),
                                with: .color(Color.white.opacity(0.08 + (0.08 * twinkle)))
                            )
                        }
                        
                        for (a, b) in connections {
                            guard a < starLayout.count, b < starLayout.count else { continue }
                            let posA = CGPoint(x: starLayout[a].x * size.width, y: starLayout[a].y * size.height)
                            let posB = CGPoint(x: starLayout[b].x * size.width, y: starLayout[b].y * size.height)
                            let lit = isConnectionLit(a, b)
                            var path = Path()
                            path.move(to: posA)
                            path.addLine(to: posB)
                            
                            let lineOpacity = lit ? (isFledged ? 1.0 : 0.4) : 0.12
                            let lineWidth: CGFloat = lit ? (isFledged ? 2.5 : 1.5) : 1.0
                            
                            context.stroke(
                                path,
                                with: .color(Color.white.opacity(lineOpacity)),
                                lineWidth: lineWidth
                            )
                        }
                        
                        for (layoutIndex, star) in starLayout.enumerated() {
                            let pos = CGPoint(x: star.x * size.width, y: star.y * size.height)
                            let lit = isStarLit(layoutIndex)
                            let actualPillar: Pillar
                            
                            if layoutIndex < allMissions.count {
                                actualPillar = allMissions[layoutIndex].pillar
                            } else {
                                actualPillar = star.pillar
                            }
                            let color = pillarColor(actualPillar)
                            
                            let baseGlowRadius = isFledged ? 12.0 : 7.0
                            let glowRadius = lit ? (baseGlowRadius + (4.0 * breathIntensity)) : 4.0
                            let glowOpacity = lit ? (0.5 + (0.4 * breathIntensity)) : 0.20
                            let dotRadius: CGFloat = lit ? (isFledged ? 5.5 : 4.5) : 2.5
                            
                            if lit {
                                context.fill(
                                    Path(ellipseIn: CGRect(
                                        x: pos.x - glowRadius, y: pos.y - glowRadius,
                                        width: glowRadius * 2, height: glowRadius * 2
                                    )),
                                    with: .color(color.opacity(isFledged ? 0.5 : 0.35))
                                )
                            }
                            
                            context.fill(
                                Path(ellipseIn: CGRect(
                                    x: pos.x - dotRadius, y: pos.y - dotRadius,
                                    width: dotRadius * 2, height: dotRadius * 2
                                )),
                                with: .color(lit ? color : Color.white.opacity(glowOpacity))
                            )
                        }
                    }
                }
                .padding(.bottom, 80)
            }
            
            VStack {
                VStack(spacing: 6) {
                    Text("The Sky")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(statusLine)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                .padding(.top, 60)
                .opacity(appeared ? 1 : 0)
                
                Spacer()
                
                HStack(spacing: 20) {
                    ForEach(Pillar.allCases, id: \.self) { pillar in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(pillarColor(pillar))
                                .frame(width: 7, height: 7)
                            Text(pillar.rawValue)
                                .font(.system(size: 11, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.45))
                        }
                    }
                }
                .padding(.bottom, 100)
                .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                appeared = true
            }}
            .onChange(of: completedCount) { oldValue, newValue in
                if newValue == totalCount && totalCount > 0 {
                    triggerFledgeCelebration()
                }
            }
        }
    }


