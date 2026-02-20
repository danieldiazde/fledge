//
//  BudgetSliderView.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import SwiftUI

struct BudgetSliderView: View {
    @State private var weeklyBudget: Double = 50
    
    var protein: Double { weeklyBudget * 0.35 }
    var carbs: Double { weeklyBudget * 0.25 }
    var vegetables: Double { weeklyBudget * 0.20 }
    var snacks: Double { weeklyBudget * 0.12 }
    var buffer: Double { weeklyBudget * 0.08 }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Header
            Text("Budget breakdown")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(Color("PrimaryText"))
            
            // Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Weekly budget")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Color("SecondaryText"))
                    Spacer()
                    Text("€\(Int(weeklyBudget))")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(Color.accentColor)
                }
                
                Slider(value: $weeklyBudget, in: 20...150, step: 5)
                    .tint(Color.accentColor)
            }
            
            // Breakdown rows
            VStack(spacing: 12) {
                BudgetRow(label: "🥩 Protein", amount: protein, color: Color(red: 0.85, green: 0.45, blue: 0.3))
                BudgetRow(label: "🍝 Carbs & grains", amount: carbs, color: Color(red: 0.4, green: 0.55, blue: 0.8))
                BudgetRow(label: "🥦 Vegetables", amount: vegetables, color: Color(red: 0.4, green: 0.7, blue: 0.5))
                BudgetRow(label: "🍎 Snacks & fruit", amount: snacks, color: Color(red: 0.9, green: 0.7, blue: 0.3))
                BudgetRow(label: "🛡️ Buffer", amount: buffer, color: Color(red: 0.6, green: 0.55, blue: 0.7))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("CardBackground"))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
            )
        }
    }
}

struct BudgetRow: View {
    let label: String
    let amount: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(Color("PrimaryText"))
            
            Spacer()
            
            Text("€\(Int(amount))")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(color)
        }
    }
}
