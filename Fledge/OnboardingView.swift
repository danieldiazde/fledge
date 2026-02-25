//
//  OnboardingView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 19/02/26.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var arrivalManager: ArrivalManager
    @EnvironmentObject var userProfile: UserProfile
    @Environment(\.colorScheme) var colorScheme

    @State private var step         = 0
    @State private var nameInput    = ""
    @State private var cityInput    = ""
    @State private var selectedDate = Date()
    @State private var appeared     = false
    @FocusState private var fieldFocused: Bool


    var allowedDateRange: ClosedRange<Date> {
        let today        = Date()
        let fourWeeksAgo = Calendar.current.date(byAdding: .day, value: -28, to: today)!
        return fourWeeksAgo...today
    }


    var derivedWeek: Int {
        let days = Calendar.current.dateComponents([.day], from: selectedDate, to: Date()).day ?? 0
        return min(4, max(1, (days / 7) + 1))
    }

    var weekName: String {
        switch derivedWeek {
        case 1: return "Your first week."
        case 2: return "Finding your rhythm."
        case 3: return "Getting comfortable."
        case 4: return "One month in."
        default: return ""
        }
    }

    var relativeArrivalString: String {
        if Calendar.current.isDateInToday(selectedDate) { return "Today" }
        let fmt = RelativeDateTimeFormatter()
        fmt.unitsStyle = .full
        fmt.dateTimeStyle = .named
        let t = fmt.localizedString(for: selectedDate, relativeTo: Date())
        return t.prefix(1).uppercased() + t.dropFirst()
    }

    var canAdvance: Bool {
        switch step {
        case 0:  return nameInput.trimmingCharacters(in: .whitespaces).count >= 2
        case 1:  return cityInput.trimmingCharacters(in: .whitespaces).count >= 2
        default: return true
        }
    }

    
    private let stepLabels = ["Your name", "Your city", "Your arrival"]


    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color("AtmosphereTop"), Color("AtmosphereBottom")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color.accentColor.opacity(0.10), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 450
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .opacity(appeared ? 1 : 0)

                Spacer()

                stepContent
                    .padding(.horizontal, 24)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .offset(x:  42)),
                        removal:   .opacity.combined(with: .offset(x: -42))
                    ))
                    .id(step)
                    .animation(.spring(response: 0.45, dampingFraction: 0.85), value: step)

                Spacer()

                ctaBlock
                    .padding(.bottom, 48)
                    .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.75, dampingFraction: 0.75).delay(0.12)) {
                appeared = true
            }
        }
    }


    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { i in
                VStack(spacing: 5) {
                    // Filled track
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.primary.opacity(0.10))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(i < step
                                  ? Color.accentColor.opacity(0.55)
                                  : i == step
                                  ? Color.accentColor
                                  : Color.clear)
                            .frame(height: 4)
                            .animation(.spring(response: 0.4), value: step)
                    }

                    Text(stepLabels[i])
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(i == step
                                         ? Color.accentColor
                                         : Color.primary.opacity(0.28))
                        .animation(.easeInOut(duration: 0.25), value: step)
                }
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 0:  nameStep
        case 1:  cityStep
        default: arrivalStep
        }
    }


    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your name?")
                    .font(.system(.largeTitle, design: .rounded)).fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Just for you.")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.secondary)
            }

            AnimatedTextField(
                placeholder: "Your first name",
                text: $nameInput,
                isFocused: $fieldFocused,
                isValid: nameInput.count >= 2
            )
            .onAppear { fieldFocused = true }
        }
    }


    private var cityStep: some View {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Where are you\nlanding?")
                        .font(.system(.largeTitle, design: .rounded)).fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineSpacing(2)
                    Text("Fledge is currently exclusive to our flagship city.")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 12) {
                    CitySelectionCard(
                        city: "Monterrey",
                        state: "Nuevo León",
                        isAvailable: true,
                        isSelected: cityInput == "Monterrey"
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            cityInput = "Monterrey"
                        }
                    }
                    
                    CitySelectionCard(
                        city: "Mexico City",
                        state: "CDMX",
                        isAvailable: false,
                        isSelected: false
                    ) {}
                    
                    CitySelectionCard(
                        city: "Guadalajara",
                        state: "Jalisco",
                        isAvailable: false,
                        isSelected: false
                    ) {}
                }
            }
            .onAppear {
                fieldFocused = false
            }
        }


    private var arrivalStep: some View {
            VStack(alignment: .leading, spacing: 0) {

                
                VStack(alignment: .leading, spacing: 10) {
                    Text("When did you arrive,\n\(nameInput.isEmpty ? "friend" : nameInput)?")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.7)
                    
                    Text("Fledge is tailored for your first 4 weeks.")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 40)


                VStack(spacing: 0) {
                    DatePicker(
                        "Arrival date",
                        selection: $selectedDate,
                        in: allowedDateRange,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .background {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(colorScheme == .dark
                              ? AnyShapeStyle(.ultraThinMaterial)
                              : AnyShapeStyle(Color.white))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .strokeBorder(
                                    colorScheme == .dark
                                        ? Color.white.opacity(0.10)
                                        : Color.black.opacity(0.05),
                                    lineWidth: 1
                                )
                        )
                }
                .padding(.bottom, 40)

                MinimalChapterMapView(
                    derivedWeek: derivedWeek,
                    weekName: weekName,
                    relativeArrivalString: relativeArrivalString
                )
                
            }
        }


    private var ctaBlock: some View {
        VStack(spacing: 14) {
            Button(action: advance) {
                HStack(spacing: 6) {
                    Text(ctaLabel)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .contentTransition(.opacity)
                        .animation(.easeInOut(duration: 0.2), value: ctaLabel)
                    Image(systemName: "arrow.right")
                        .font(.system(.body))
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(canAdvance
                              ? Color.accentColor
                              : Color.accentColor.opacity(0.32))
                        .shadow(
                            color: canAdvance ? Color.accentColor.opacity(0.35) : .clear,
                            radius: 14, x: 0, y: 6
                        )
                )
            }
            .disabled(!canAdvance)
            .padding(.horizontal, 24)
            .animation(.easeInOut(duration: 0.18), value: canAdvance)

            if step == 2 {
                HStack(spacing: 5) {
                    Image(systemName: "lock.fill").font(.system(.caption2))
                    Text("Entirely on-device. Your data is yours alone.")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                }
                .foregroundColor(.secondary)
                .transition(.opacity.combined(with: .offset(y: 6)))
            }
        }
    }

    private var ctaLabel: String {
        switch step {
        case 0:
            let n = nameInput.trimmingCharacters(in: .whitespaces)
            return n.count >= 2 ? "Continue, \(n)" : "Continue"
        case 1:
            return "Continue"
        default:
            return "Begin Week \(derivedWeek)"
        }
    }

    // MARK: - Navigation

    private func advance() {
        fieldFocused = false
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        
        switch step {
        case 0:
            userProfile.name = nameInput.trimmingCharacters(in: .whitespaces)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { step = 1 }
        case 1:
            
            if !cityInput.isEmpty {
                            userProfile.city = cityInput
                        }
            
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { step = 2 }
        default:
            arrivalManager.completeOnboarding(with: selectedDate)
        }
    }
}

private struct CitySelectionCard: View {
    let city: String
    let state: String
    let isAvailable: Bool
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon Map Pin
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.accentColor : Color.primary.opacity(0.06))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: isAvailable ? "mappin.and.ellipse" : "lock.fill")
                        .foregroundColor(isSelected ? .white : (isAvailable ? Color.accentColor : .secondary.opacity(0.6)))
                        .font(.system(.title3))
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(city)
                        .font(.system(.title3, design: .rounded)).fontWeight(.bold)
                        .foregroundColor(isAvailable ? .primary : .secondary.opacity(0.6))
                    Text(state)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.6))
                }

                Spacer()

                // State Badge / Selection Check
                if !isAvailable {
                    Text("Coming soon")
                        .font(.system(.caption2, design: .rounded)).fontWeight(.bold)
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.primary.opacity(0.06)))
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.accentColor)
                        .font(.system(.title2))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(colorScheme == .dark
                          ? AnyShapeStyle(.ultraThinMaterial)
                          : AnyShapeStyle(Color.white))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(
                                isSelected
                                    ? Color.accentColor.opacity(0.6)
                                    : (colorScheme == .dark ? Color.white.opacity(0.07) : Color.black.opacity(0.06)),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? Color.accentColor.opacity(0.15) : .clear,
                        radius: 8, x: 0, y: 4
                    )
            )
            .opacity(isAvailable ? 1.0 : 0.6)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
    }
}


private struct AnimatedTextField: View {
    let placeholder: String
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let isValid: Bool

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(.title2, design: .rounded))
            .fontWeight(.semibold)
            .focused(isFocused)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.words)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(colorScheme == .dark
                          ? AnyShapeStyle(.ultraThinMaterial)
                          : AnyShapeStyle(Color.white))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                isValid
                                    ? Color.accentColor.opacity(0.45)
                                    : Color.primary.opacity(0.09),
                                lineWidth: 1.5
                            )
                            .animation(.easeInOut(duration: 0.2), value: isValid)
                    )
                    .shadow(
                        color: isValid ? Color.accentColor.opacity(0.12) : .clear,
                        radius: 10
                    )
                    .animation(.easeInOut(duration: 0.3), value: isValid)
            )
    }
}


// MARK: - Minimal Chapter Map ─────────────────────────────────────────────────

/// A breathing, Apple-esque timeline that reacts to the date picker instantly.
private struct MinimalChapterMapView: View {
    let derivedWeek: Int
    let weekName: String
    let relativeArrivalString: String

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            
            // Dynamic Readout
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "sparkles")
                        .font(.system(.title3, weight: .semibold))
                        .foregroundColor(Color.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Week \(derivedWeek)")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .contentTransition(.numericText())
                        
                        Text("·")
                            .font(.system(.headline))
                            .foregroundColor(.secondary.opacity(0.5))
                        
                        Text(relativeArrivalString)
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.accentColor)
                            .contentTransition(.opacity)
                    }
                    
                    Text(weekName)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                        .contentTransition(.opacity)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: derivedWeek)
            .animation(.easeInOut(duration: 0.2), value: relativeArrivalString)

            // Minimalist 4-Week Bar Indicator
            HStack(spacing: 8) {
                ForEach(1...4, id: \.self) { week in
                    let isActive = week == derivedWeek
                    let isPast = week < derivedWeek
                    
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(isActive
                              ? Color.accentColor
                              : (isPast ? Color.accentColor.opacity(0.3) : Color.primary.opacity(0.06)))
                        .frame(height: 6)
                        .shadow(color: isActive ? Color.accentColor.opacity(0.4) : .clear, radius: 6, y: 2)
                        .scaleEffect(isActive ? 1.02 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isActive)
                }
            }
        }
    }
}
