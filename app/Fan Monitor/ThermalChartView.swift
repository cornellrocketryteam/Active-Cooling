//
//  ChartView.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 4/21/25.
//

import SwiftUI
import Charts

class ThermalChartDataModel: ObservableObject {
    @Published var data: [(time: Date, value: Float)] = []

    func append(_ value: Float) {
        guard value > 0 && value < 60 else { return }
        
        let now = Date()
        data.append((now, value))
        data = data.filter { $0.time > now.addingTimeInterval(-60) }
    }
}

struct ThermalChartView: View {
    @ObservedObject var model: ThermalChartDataModel
    var color: Color = .blue
    var smoothed: Bool = true

    var body: some View {
        let now = Date()
        let startTime = now.addingTimeInterval(-60)

        let values = model.data.map(\.value)
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 50

        let yMin = floor(minValue - 5)
        let yMax = ceil(maxValue + 5)

        Chart {
            ForEach(model.data, id: \.time) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("Temperature", point.value)
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
