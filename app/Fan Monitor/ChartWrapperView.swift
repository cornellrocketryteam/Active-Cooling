//
//  ChartWrapperView.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 4/21/25.
//

import SwiftUI
import Charts

struct ChartWrapperView: UIViewRepresentable {
    var data: [Double]

    func makeUIView(context: Context) -> UIView {
        let hostingController = UIHostingController(rootView: ChartView(data: data))
        hostingController.view.backgroundColor = .clear
        return hostingController.view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct ChartView: View {
    var data: [Double]

    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.0) { index, value in
                LineMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .symbol(Circle())
            }
        }
        .chartXAxis(.hidden)
        .chartYScale(domain: 15...55)
    }
}
