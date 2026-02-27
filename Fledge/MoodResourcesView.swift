//
//  MoodResourcesView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 22/02/26.
//

import SwiftUI

struct MoodResourcesView: View {
    let mood: Mood
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var moodColor: Color {
        colorScheme == .dark ? mood.color : mood.lightModeColor
    }
    
    var headline: String {
        switch mood {
        case .overwhelmed: return "When your capacity\nis running low."
        case .lonely:      return "When the distance\nfeels too far."
        case .ready:       return "You're in a\ngood place."
        }
    }
    
    var description: String {
        switch mood {
        case .overwhelmed:
            return "Your brain is processing a new city, new routines, and a new version of yourself all at once. It's okay to run on low capacity. Here's what helps."
        case .lonely:
            return "Loneliness in a new city is one of the most universal human experiences. It doesn't mean something is wrong with you. It means you're paying attention. Here's what helps."
        case .ready:
            return "You're feeling energized and up for it today. Use that. These are the days that move the needle. Here's how to make the most of this feeling."
        }
    }
    
    var resources: [(icon: String, title: String, detail: String)] {
        switch mood {
        case .overwhelmed:
            return [
                ("1.circle.fill", "Do one small thing", "Pick the smallest possible task and complete just that. Not the list — one thing. Momentum starts there."),
                ("moon.fill", "Protect your sleep", "Everything feels worse when you're tired. 7-8 hours isn't a luxury right now, it's load-bearing infrastructure."),
                ("figure.walk", "Walk somewhere with no destination", "20 minutes outside without a goal resets your nervous system more than almost anything else."),
                ("phone.fill", "Call someone who knows you", "Not to report how you're doing. Just to hear a familiar voice. 10 minutes is enough."),
                ("list.bullet", "Write the list, then hide it", "Write everything overwhelming you. Then close the note. Externalizing it takes it out of your head."),
                ("cup.and.saucer.fill", "Eat something real", "When overwhelmed, people stop eating properly. A real meal changes your biochemistry in ways that matter.")
            ]
        case .lonely:
            return [
                ("person.fill", "Identify one person", "Not a social life — one person. A classmate, neighbor, anyone. Send one message today."),
                ("map.fill", "Go somewhere you'll see the same people again", "A café, a gym, a library spot. Regularity creates familiarity. Familiarity creates connection."),
                ("message.fill", "Text someone from home", "Not to say you're lonely. Just to connect. The distance is real but so is the line."),
                ("building.2.fill", "Find your university's student groups", "Tec de Monterrey has hundreds of student organizations. One of them has your people in it."),
                ("heart.fill", "Know that this is temporary", "Loneliness in a new city peaks around weeks 2-3 and drops significantly by month 2. You are not stuck here."),
                ("book.fill", "Read or watch something absorbing", "Sometimes loneliness needs company that asks nothing of you. A book or show can do that.")
            ]
        case .ready:
            return [
                ("bolt.fill", "Tackle your hardest mission today", "You have energy. Use it on the thing you've been avoiding. Today is the day."),
                ("person.2.fill", "Reach out to someone new", "Feeling good makes social connection easier. Use that window. Send the message."),
                ("map.fill", "Explore somewhere new in the city", "Ready days are for expanding your map. Go somewhere you haven't been yet."),
                ("pencil", "Write down what's working", "Take 5 minutes to note what's actually going well. You'll want this record on harder days."),
                ("star.fill", "Set one intention for this week", "From this energy, what do you want to have done by Sunday? Name it now while it's clear."),
                ("arrow.up.forward", "Help someone else", "If you have capacity, use it outward. Ask a classmate if they need anything. It compounds.")
            ]
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("AtmosphereTop"), Color("AtmosphereBottom")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            RadialGradient(
                colors: [moodColor.opacity(0.10), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 450
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: mood.icon)
                                .font(.system(.callout))
                            Text(mood.rawValue.uppercased())
                                .font(.subheadline.weight(.bold))
                                .fontDesign(.rounded)
                                .tracking(2)
                        }
                        .foregroundColor(moodColor)
                        
                        Text(headline)
                            .font(.system(.largeTitle,design: .rounded)).fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                        
                        Text(description)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 28)
                    
                    // Resources
                    VStack(spacing: 10) {
                        ForEach(Array(resources.enumerated()), id: \.offset) { index, resource in
                            HStack(alignment: .top, spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(moodColor.opacity(0.12))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .strokeBorder(moodColor.opacity(0.20), lineWidth: 1)
                                        )
                                    Image(systemName: resource.icon)
                                        .font(.system(.title3))
                                        .foregroundColor(moodColor)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(resource.title)
                                        .font(.system(.headline, design: .rounded)).fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Text(resource.detail)
                                        .font(.system(.callout, design: .rounded))
                                        .foregroundColor(.secondary)
                                        .lineSpacing(3)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                Spacer()
                            }
                            .padding(14)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(colorScheme == .dark
                                        ? AnyShapeStyle(.regularMaterial)
                                        : AnyShapeStyle(Color.white)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(
                                                colorScheme == .dark
                                                    ? Color.white.opacity(0.06)
                                                    : Color.black.opacity(0.06),
                                                lineWidth: 1
                                            )
                                    )
                                    .shadow(
                                        color: Color.black.opacity(colorScheme == .dark ? 0 : 0.04),
                                        radius: 6, x: 0, y: 2
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 48)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(.body, weight: .semibold))
                        Text("Back")
                            .font(.system(.headline, design: .rounded)).fontWeight(.medium)
                    }
                    .foregroundColor(moodColor)
                }
            }
        }
    }
}
