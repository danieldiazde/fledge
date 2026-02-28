//
//  PillarSwitcher.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 19/02/26.
//

import SwiftUI

// MARK: - MorphingPillarSwitcher

/// Full-width switcher showing the active pillar as a tall hero card and the
/// two inactive pillars as smaller accessory cards on the right.
/// Uses `matchedGeometryEffect` so switching pillars morphs the cards in place.
struct MorphingPillarSwitcher: View {
    @Binding var selectedPillar: Pillar
    @Namespace private var heroNamespace
    @Environment(\.colorScheme) var colorScheme

    var accessoryPillars: [Pillar] {
        Pillar.allCases.filter { $0 != selectedPillar }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            HeroPillarCard(pillar: selectedPillar, namespace: heroNamespace, colorScheme: colorScheme)
                .frame(maxWidth: .infinity)
                .frame(height: 160)

            VStack(spacing: 10) {
                ForEach(accessoryPillars, id: \.self) { pillar in
                    AccessoryPillarCard(pillar: pillar, namespace: heroNamespace, colorScheme: colorScheme) {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                            selectedPillar = pillar
                        }
                    }
                    .frame(height: 75)
                }
            }
            .frame(width: 110)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - HeroPillarCard

/// The large, active-pillar card in `MorphingPillarSwitcher`.
struct HeroPillarCard: View {
    @State private var showTagline = true
    let pillar: Pillar
    var namespace: Namespace.ID
    var colorScheme: ColorScheme

    var effectiveColor: Color {
        colorScheme == .dark ? pillar.color : pillar.lightModeColor
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(effectiveColor.opacity(colorScheme == .dark ? 0.18 : 0.11))
                .matchedGeometryEffect(id: "bg_\(pillar.rawValue)", in: namespace)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(effectiveColor.opacity(0.30), lineWidth: 1.2)
                        .matchedGeometryEffect(id: "border_\(pillar.rawValue)", in: namespace)
                )

            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Image(systemName: pillar.icon)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(effectiveColor)
                    .matchedGeometryEffect(id: "icon_\(pillar.rawValue)", in: namespace)
                    .padding(.bottom, 10)
                Text(pillar.rawValue)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .matchedGeometryEffect(id: "label_\(pillar.rawValue)", in: namespace)
                Text(pillar.tagline)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .padding(.top, 2)
                    .opacity(showTagline ? 0.85 : 0)
                    .onChange(of: pillar) {
                        showTagline = false
                        withAnimation(.easeIn(duration: 0.25).delay(0.35)) { showTagline = true }
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(pillar.rawValue). \(pillar.tagline). Currently selected.")
        .accessibilityAddTraits(.isSelected)
    }
}

// MARK: - AccessoryPillarCard

/// One of the two small inactive-pillar cards in `MorphingPillarSwitcher`.
struct AccessoryPillarCard: View {
    let pillar: Pillar
    var namespace: Namespace.ID
    var colorScheme: ColorScheme
    let action: () -> Void

    var effectiveColor: Color {
        colorScheme == .dark ? pillar.color : pillar.lightModeColor
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.primary.opacity(colorScheme == .dark ? 0.06 : 0.04))
                    .matchedGeometryEffect(id: "bg_\(pillar.rawValue)", in: namespace)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                            .matchedGeometryEffect(id: "border_\(pillar.rawValue)", in: namespace)
                    )
                VStack(spacing: 6) {
                    Image(systemName: pillar.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(effectiveColor.opacity(0.75))
                        .matchedGeometryEffect(id: "icon_\(pillar.rawValue)", in: namespace)
                    Text(pillar.rawValue)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .matchedGeometryEffect(id: "label_\(pillar.rawValue)", in: namespace)
                }
                .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(pillar.rawValue)
        .accessibilityHint("Switch to \(pillar.rawValue) pillar.")
    }
}
