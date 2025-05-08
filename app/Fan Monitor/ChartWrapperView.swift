//
//  ChartWrapperView.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 4/21/25.
//

import SwiftUI
import Charts

class ChartDataModel: ObservableObject {
    @Published var data: [Double] = []
}

struct ChartWrapperView: UIViewRepresentable {
    @ObservedObject var model: ChartDataModel

    func makeUIView(context: Context) -> UIView {
        let controller = UIHostingController(rootView: ChartView(model: model))
        controller.view.backgroundColor = .clear
        return controller.view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let controller = uiView.next as? UIHostingController<ChartView> {
            controller.rootView = ChartView(model: model)
        }
    }
}

struct ChartView: View {
    @ObservedObject var model: ChartDataModel

    var body: some View {
        Chart {
            ForEach(Array(model.data.enumerated()), id: \.0) { index, value in
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
