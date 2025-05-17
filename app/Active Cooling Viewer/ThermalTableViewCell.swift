//
//  StatsTableViewCell.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 4/20/25.
//

import UIKit
import SwiftUI

class ThermalTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var chartContainerView: UIView!
    
    private var chartData: [Float] = []
    private var hostingController: UIHostingController<ThermalChartView>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 12
        self.contentView.layer.masksToBounds = true
        
        contentView.backgroundColor = .white
        backgroundColor = .clear
    }
    
    // Update the chart with new values
    func update(model: ThermalChartDataModel, temperature: Float, unit: String) {
        currentValueLabel.attributedText = formattedTemperatureString(temperature, unit: unit)

        if let hosting = hostingController {
            hosting.rootView = ThermalChartView(model: model, color: .blue)
        } else {
            // First-time creation
            let chartView = ThermalChartView(model: model, color: .blue)
            let hosting = UIHostingController(rootView: chartView)
            hosting.view.translatesAutoresizingMaskIntoConstraints = false
            chartContainerView.addSubview(hosting.view)
            
            // Constrain the chart to a fixed size
            NSLayoutConstraint.activate([
                hosting.view.topAnchor.constraint(equalTo: chartContainerView.topAnchor),
                hosting.view.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor),
                hosting.view.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor),
                hosting.view.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor)
            ])

            hostingController = hosting
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
    }
    
    // Format the temperature display nicely
    func formattedTemperatureString(_ value: Float, unit: String) -> NSAttributedString {
        let fullString = String(format: "%.1f %@", value, unit)
        let attributed = NSMutableAttributedString(string: fullString)

        let numberString = String(format: "%.1f", value)

        if let numberRange = fullString.range(of: numberString) {
            let nsNumberRange = NSRange(numberRange, in: fullString)
            attributed.addAttribute(.font, value: UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .semibold), range: nsNumberRange)
        }

        if let unitRange = fullString.range(of: unit) {
            let nsUnitRange = NSRange(unitRange, in: fullString)
            attributed.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.gray
            ], range: nsUnitRange)
        }

        return attributed
    }
}
