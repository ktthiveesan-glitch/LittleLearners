//
//  CategoryProgressChart.swift
//  LittleLearners
//

import SwiftUI
import Charts

/// A horizontal bar chart showing what share of each category (letters, numbers, shapes)
/// the child has completed, from 0% to 100%.
struct CategoryProgressChart: View {
    /// One entry per category.
    let progress: [CategoryProgress]

    /// The app language, so the category names on the chart are translated.
    @Environment(\.locale) private var locale

    /// The user's text size setting.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The chart's height. Grows with the text size so the labels have room.
    @ScaledMetric private var chartHeight: CGFloat = 160

    /// The percentages labelled on the x axis: fewer with very large text, so they do not overlap.
    private var axisValues: [Double] {
        dynamicTypeSize.isAccessibilitySize ? [0, 50, 100] : [0, 25, 50, 75, 100]
    }

    var body: some View {
        Chart(progress) { item in
            BarMark(
                x: .value("Completed", item.fraction * 100),
                y: .value("Category", item.category.title.text(in: locale))
            )
            .foregroundStyle(Theme.color(for: item.category))
            .cornerRadius(4)
        }
        // Always show the full 0 to 100 range, so a short bar really means "little done".
        .chartXScale(domain: 0...100)
        // Each category name is written at the left, just above its bar.
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisValueLabel()
            }
        }
        .chartXAxis {
            AxisMarks(values: axisValues) { value in
                let percent = value.as(Double.self) ?? 0
                AxisGridLine()
                // Labels normally start at their grid line. The last one ("100%") ends at its line instead,
                // otherwise it would run off the edge of the chart and not be shown.
                AxisValueLabel(anchor: percent == 100 ? .topTrailing : .topLeading, collisionResolution: .disabled) {
                    Text(percent / 100, format: .percent)
                }
            }
        }
        .frame(height: chartHeight)
    }
}

#Preview {
    CategoryProgressChart(progress: [
        CategoryProgress(category: .letters, completed: 13, total: 52),
        CategoryProgress(category: .numbers, completed: 8, total: 10),
        CategoryProgress(category: .shapes, completed: 6, total: 6),
    ])
    .padding()
}
