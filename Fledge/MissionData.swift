//
//  MissionData.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import Foundation

@MainActor
struct MissionData {
    
    private static func makePlaceholder(title: String, pillar: Pillar, week: Int) -> Mission {
            return Mission(
                title: title,
                briefing: MoodVariant(
                    ready: "You're ready for this. Let's conquer \(title.lowercased()).",
                    overwhelmed: "Take a deep breath. Just focus on one step today.",
                    lonely: "Getting out and doing this will help you feel connected to {city}."
                ),
                truth: MoodVariant(
                    ready: "Action creates momentum.",
                    overwhelmed: "Small steps are still steps. They all count.",
                    lonely: "Connection starts with engaging the world around you."
                ),
                objective: "Complete the steps for: \(title)",
                steps: [
                    MissionStep(
                        number: 1,
                        action: "Start here",
                        howTo: "Placeholder instructions for this mission.",
                        tip: "Take your time."
                    )
                ],
                resources: [],
                win: MoodVariant(
                    ready: "Great job, you crushed it.",
                    overwhelmed: "You did it, despite the noise. Be proud.",
                    lonely: "You stepped out and succeeded. You're building a life here."
                ),
                pillar: pillar,
                weekNumber: week,
                tags: [],
                duration: "1 day",
                xpValue: 20
            )
        }

    static let all: [Mission] = {
        
        //MARK: WEEK 1

        //City
        let m1 = Mission(
            title: "Learn one route really well",
            briefing: MoodVariant(
                ready: "{city} is a maze and you don't have a map yet. Change that today. One route, owned completely.",
                overwhelmed: "You don't need to know all of {city}. You need to know one path. Just one. Start there.",
                lonely: "Walking a city alone feels different when you know where you are. Own one route and {city} starts to feel less foreign."
            ),
            truth: MoodVariant(
                ready: "Every city feels like a maze until suddenly it doesn't. That moment happens the first time you stop checking your phone.",
                overwhelmed: "You've been navigating on autopilot. That works, but it keeps {city} feeling like a stranger's place instead of yours.",
                lonely: "Feeling lost in a city and feeling lonely in a city are the same feeling. Fixing one fixes both a little."
            ),
            objective: "Walk your most important route twice — once with Maps, once without.",
            steps: [
                MissionStep(
                    number: 1,
                    action: "Pick your one route",
                    howTo: "The place you go most this week — university, work, gym. Open Google Maps, look at it once, then close it.",
                    tip: "Don't pick the shortest route. Pick the most important one."
                ),
                MissionStep(
                    number: 2,
                    action: "Walk it with Maps today",
                    howTo: "Phone in hand is fine. But look up at every turn. Notice one thing per block — a building, a smell, a sound.",
                    tip: nil
                ),
                MissionStep(
                    number: 3,
                    action: "Identify your landmarks",
                    howTo: "Find three things you'll always recognize: a specific taquería, a colored building, a tree. These are your anchors.",
                    tip: "Locals navigate by landmarks, not street names. Start thinking that way."
                ),
                MissionStep(
                    number: 4,
                    action: "Walk it again without Maps",
                    howTo: "Phone in your pocket. Let yourself be uncertain. If you get lost, that's data. You'll remember that corner forever.",
                    tip: nil
                ),
                MissionStep(
                    number: 5,
                    action: "Name the route",
                    howTo: "Open Notes and write: '{name} to [destination] — [your landmark] at [street].' It's yours now.",
                    tip: "The act of naming something makes it real. This route is now part of your city."
                )
            ],
            resources: [
                MissionResource(
                    type: .place,
                    name: "Find your landmark",
                    detail: "Find one thing visible from far away in {city}. Use it as your compass when you're disoriented.",
                    url: nil
                ),
                MissionResource(
                    type: .app,
                    name: "Google Maps — Offline",
                    detail: "Download {city} offline before you go. Settings → Offline Maps. Works without data.",
                    url: nil
                ),
                MissionResource(
                    type: .tip,
                    name: "Ask a local their route",
                    detail: "Ask one classmate or neighbor how they get somewhere. Their route will be better than Maps' route.",
                    url: nil
                ),
                MissionResource(
                    type: .cost,
                    name: "Cost: Free",
                    detail: "Time: 20 minutes × 2 days. No equipment needed.",
                    url: nil
                )
            ],
            win: MoodVariant(
                ready: "{name}, you stopped being a tourist on that route. You became someone who lives here.",
                overwhelmed: "One piece of {city} is yours now, {name}. That's how belonging starts — one route, one corner, one familiar face.",
                lonely: "You know something about {city} that you didn't know yesterday. That's yours. Nobody can take that."
            ),
            pillar: .city,
            weekNumber: 1,
            tags: [.city, .navigation, .independence],
            duration: "2 days",
            xpValue: 25
        )

        let m2 = Mission(
            title: "Find your local spots",
            briefing: MoodVariant(
                ready: "Every city has a version of itself that belongs to locals. Time to find yours in {city} — the taquería, the café, the park bench that becomes yours.",
                overwhelmed: "You don't need a social life yet. You need two or three places in {city} that feel familiar. That's enough for now.",
                lonely: "Places become home when you become a regular. Pick one spot in {city} and go back. The second visit is always easier than the first."
            ),
            truth: MoodVariant(
                ready: "Locals don't discover their city all at once. They find one spot, then another. Your map of {city} grows one place at a time.",
                overwhelmed: "Having a 'usual place' reduces decisions. That matters when everything else is already new.",
                lonely: "Regulars become familiar faces. Familiar faces become something close to community. It starts with one place."
            ),
            objective: "Find and visit three local spots within walking distance of where you live or study.",
            steps: [
                MissionStep(
                    number: 1,
                    action: "Find a café or taquería nearby",
                    howTo: "Open Google Maps, search 'taquería' or 'café' near you. Pick one with reviews in the local language — that's a local spot.",
                    tip: "Avoid chains. The best spots have handwritten menus."
                ),
                MissionStep(
                    number: 2,
                    action: "Go and order something",
                    howTo: "Walk in, order whatever looks most popular. Sit if you can. Spend at least 15 minutes there.",
                    tip: nil
                ),
                MissionStep(
                    number: 3,
                    action: "Find a green space or plaza",
                    howTo: "Search 'parque' or 'plaza' near you. Walk there. Sit for 10 minutes and just watch the neighborhood.",
                    tip: "Locals use their plazas in the evening. Go after 6pm for the real version of {city}."
                ),
                MissionStep(
                    number: 4,
                    action: "Note your three spots",
                    howTo: "Open Notes and write: your café, your green space, and one more place that caught your eye. These are your local anchors.",
                    tip: nil
                )
            ],
            resources: [
                MissionResource(
                    type: .app,
                    name: "Google Maps reviews",
                    detail: "Filter by 'Most relevant' and look for reviews with photos. That's your signal it's a real local spot.",
                    url: nil
                ),
                MissionResource(
                    type: .tip,
                    name: "Go at the right time",
                    detail: "Taquerías peak at 1–3pm and 8–10pm. Cafés are best 8–11am. Timing matters for the authentic version.",
                    url: nil
                ),
                MissionResource(
                    type: .cost,
                    name: "Cost: ~$80–150 MXN",
                    detail: "Enough for a meal and a coffee. Consider it an investment in feeling at home in {city}.",
                    url: nil
                )
            ],
            win: MoodVariant(
                ready: "You have local spots now, {name}. That's not a small thing — that's the beginning of a life in {city}.",
                overwhelmed: "Three familiar places is three fewer unknowns. You just made {city} a little smaller and a lot more yours.",
                lonely: "You know where to go now. And the next time you go back, someone might recognize you. That's how it starts."
            ),
            pillar: .city,
            weekNumber: 1,
            tags: [.city, .exploration, .routine],
            duration: "1 day",
            xpValue: 20
        )
        
        let m3 = makePlaceholder(title: "Decode the transit system", pillar: .city, week: 1)
        
        m2.prerequisiteMissionID = m1.id
        m3.prerequisiteMissionID = m2.id
        
        // Growth
        let m4 = makePlaceholder(title: "Claim your sanctuary", pillar: .growth, week: 1)
        let m5 = makePlaceholder(title: "A quiet reflection", pillar: .growth, week: 1)
        let m6 = makePlaceholder(title: "Summon a piece of home", pillar: .growth, week: 1)
        m5.prerequisiteMissionID = m4.id
        m6.prerequisiteMissionID = m5.id
                
        // Adult Mode
        let m7 = makePlaceholder(title: "The survival grocery run", pillar: .adultMode, week: 1)
        let m8 = makePlaceholder(title: "Master the laundry system", pillar: .adultMode, week: 1)
        let m9 = makePlaceholder(title: "Map your daily cost", pillar: .adultMode, week: 1)
        m8.prerequisiteMissionID = m7.id
        m9.prerequisiteMissionID = m8.id
        
        
        // ─────────────────────────────────────────────────────────────────
        // MARK: - WEEK 2
        // ─────────────────────────────────────────────────────────────────
                
        // City
        let m10 = makePlaceholder(title: "The Third Place", pillar: .city, week: 2)
        let m11 = makePlaceholder(title: "Night Moves", pillar: .city, week: 2)
        let m12 = makePlaceholder(title: "The Cultural Icon", pillar: .city, week: 2)
        m11.prerequisiteMissionID = m10.id
        m12.prerequisiteMissionID = m11.id
                
        // Growth
                let m13 = makePlaceholder(title: "Digital Detox", pillar: .growth, week: 2)
                let m14 = makePlaceholder(title: "Say Yes", pillar: .growth, week: 2)
                let m15 = makePlaceholder(title: "The Hobby Anchor", pillar: .growth, week: 2)
                m14.prerequisiteMissionID = m13.id
                m15.prerequisiteMissionID = m14.id
                
                // Adult Mode
                let m16 = makePlaceholder(title: "Master the endless carb", pillar: .adultMode, week: 2)
                let m17 = makePlaceholder(title: "The Deep Clean", pillar: .adultMode, week: 2)
                let m18 = makePlaceholder(title: "The Healthcare Map", pillar: .adultMode, week: 2)
                m17.prerequisiteMissionID = m16.id
                m18.prerequisiteMissionID = m17.id
                
                
                // ─────────────────────────────────────────────────────────────────
                // MARK: - WEEK 3
                // ─────────────────────────────────────────────────────────────────
                
                // City
                let m19 = makePlaceholder(title: "Lost on Purpose", pillar: .city, week: 3)
                let m20 = makePlaceholder(title: "The Local Market", pillar: .city, week: 3)
                let m21 = makePlaceholder(title: "The Commuter Shift", pillar: .city, week: 3)
                m20.prerequisiteMissionID = m19.id
                m21.prerequisiteMissionID = m20.id
                
                // Growth
                let m22 = makePlaceholder(title: "Strike a Conversation", pillar: .growth, week: 3)
                let m23 = makePlaceholder(title: "The Comfort Zone", pillar: .growth, week: 3)
                let m24 = makePlaceholder(title: "The Future Letter", pillar: .growth, week: 3)
                m23.prerequisiteMissionID = m22.id
                m24.prerequisiteMissionID = m23.id
                
                // Adult Mode
                let m25 = makePlaceholder(title: "The forgiving protein", pillar: .adultMode, week: 3)
                let m26 = makePlaceholder(title: "The Bill Audit", pillar: .adultMode, week: 3)
                let m27 = makePlaceholder(title: "Emergency Fund", pillar: .adultMode, week: 3)
                m26.prerequisiteMissionID = m25.id
                m27.prerequisiteMissionID = m26.id
                
                
                // ─────────────────────────────────────────────────────────────────
                // MARK: - WEEK 4
                // ─────────────────────────────────────────────────────────────────
                
                // City
                let m28 = makePlaceholder(title: "Host a Tour", pillar: .city, week: 4)
                let m29 = makePlaceholder(title: "The Hidden Gem", pillar: .city, week: 4)
                let m30 = makePlaceholder(title: "Public Event", pillar: .city, week: 4)
                m29.prerequisiteMissionID = m28.id
                m30.prerequisiteMissionID = m29.id
                
                // Growth
                let m31 = makePlaceholder(title: "Reflect on Week 1", pillar: .growth, week: 4)
                let m32 = makePlaceholder(title: "The Regular Status", pillar: .growth, week: 4)
                let m33 = makePlaceholder(title: "Own the Move", pillar: .growth, week: 4)
                m32.prerequisiteMissionID = m31.id
                m33.prerequisiteMissionID = m32.id
                
                // Adult Mode
                let m34 = makePlaceholder(title: "Conquer the chicken breast", pillar: .adultMode, week: 4)
                let m35 = makePlaceholder(title: "The Big Budget", pillar: .adultMode, week: 4)
                let m36 = makePlaceholder(title: "The Fledge Final", pillar: .adultMode, week: 4)
                m35.prerequisiteMissionID = m34.id
                m36.prerequisiteMissionID = m35.id
        
        
        
        let allMissions = [
                    m1, m2, m3, m4, m5, m6, m7, m8, m9,
                    m10, m11, m12, m13, m14, m15, m16, m17, m18,
                    m19, m20, m21, m22, m23, m24, m25, m26, m27,
                    m28, m29, m30, m31, m32, m33, m34, m35, m36
                ]
        
        allMissions.forEach { MissionStore.restore($0) }
        
        return allMissions
    }()

    static func missions(forWeek week: Int, tags: [MissionTag] = []) -> [Mission] {
        let weekMissions = all.filter { $0.weekNumber == week }
        if tags.isEmpty { return weekMissions }
        return weekMissions.sorted { a, b in
            let aMatches = a.tags.filter { tags.contains($0) }.count
            let bMatches = b.tags.filter { tags.contains($0) }.count
            return aMatches > bMatches
        }
    }

    static func missions(forWeek week: Int, pillar: Pillar, tags: [MissionTag] = []) -> [Mission] {
        missions(forWeek: week, tags: tags).filter { $0.pillar == pillar }
    }

    static func mission(withID id: UUID) -> Mission? {
        all.first { $0.id == id }
    }
}
