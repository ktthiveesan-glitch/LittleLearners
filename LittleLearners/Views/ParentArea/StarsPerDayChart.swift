//
//  StarsPerDayChart.swift
//  LittleLearners
//

import SwiftUI
import Charts

/// A bar chart of the stars earned on each of the last 7 days, built with Swift Charts.
struct StarsPerDayChart: View {
    /// One entry per day, oldest first.
    let days: [DailyStars]

    /// The app language, so the weekday names under the bars are translated.
    @Environment(\.locale) private var locale

    /// The user's text size setting.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The chart's height. Grows with the text size so the labels have room.
    @ScaledMetric private var chartHeight: CGFloat = 200

    /// The top of the y axis: at least 5, so one star does not fill the whole chart.
    private var highestValue: Int {
        max(5, days.map(\.stars).max() ?? 0)
    }

    var body: some View {
        Chart(days) { day in
            BarMark(
                x: .value("Day", day.date, unit: .day),
                y: .value("Stars", day.stars)
            )
            .foregroundStyle(Theme.secondary)
            .cornerRadius(4)
        }
        .chartYScale(domain: 0...highestValue)
        // One label per day, showing the short weekday name (Mon, Tue, ...).
        // With very large text only the first letter is shown (M, T, ...), so the labels do not overlap.
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisValueLabel(format: .dateTime.weekday(dynamicTypeSize.isAccessibilitySize ? .narrow : .abbreviated)
                    .locale(locale), centered: true)
            }
        }
        .frame(height: chartHeight)
    }
}

#Preview {
    let today = Calendar.current.startOfDay(for: .now)
    let days = (0..<7).reversed().map { daysAgo in
        DailyStars(date: Calendar.current.date(byAdding: .day, value: -daysAgo, to: today) ?? today,
                   stars: (daysAgo * 3) % 5)
    }
    return StarsPerDayChart(days: days)
        .padding()
}
