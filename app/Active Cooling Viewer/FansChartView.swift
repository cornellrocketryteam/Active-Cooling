//
//  FansChartView.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 5/9/25.
//

import SwiftUI
import Charts

class FansChartDataModel: ObservableObject {
    @Published var data: [(time: Date, value: Int32)] = []

    func append(_ value: Int32) {
        let now = Date()
        data.append((now, value))
        
        // Set the chart to display the last minute of data
        data = data.filter { $0.time > now.addingTimeInterval(-60) }
    }
}

struct FansChartView: View {
    @ObservedObject var model: FansChartDataModel
    var color: Color = .blue
    var smoothed: Bool = true

    var body: some View {
        let now = Date()
        let startTime = now.addingTimeInterval(-60)

        let values = model.data.map(\.value)
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 50

        let yMin = minValue - 5
        let yMax = maxValue + 5

        Chart {
            ForEach(model.data, id: \.time) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("PWM", point.value)
                )
                .foregroundStyle(color)
                .interpolationMethod(smoothed ? .catmullRom : .linear)
            }
        }
        .chartXScale(domain: startTime...now)
        .chartYScale(domain: yMin...yMax)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .second, count: 15)) { value in
                AxisGridLine()
                AxisTick()
            }
        }
    }
}

