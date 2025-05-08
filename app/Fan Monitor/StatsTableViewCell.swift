//
//  StatsTableViewCell.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 4/20/25.
//

import UIKit
import SwiftUI

class StatsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var chartContainerView: UIView!
    
    private var chartData: [Float] = []
    private var chartModel = ChartDataModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 12
        self.contentView.layer.masksToBounds = true
        
        contentView.backgroundColor = .white
        backgroundColor = .clear
        
        let chartView = TemperatureChartView(model: chartModel, color: .blue)
        let hosting = UIHostingController(rootView: chartView)

        guard let hostView = hosting.view else { return }

        hostView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostView)

        NSLayoutConstraint.activate([
            hostView.topAnchor.constraint(equalTo: chartContainerView.topAnchor),
            hostView.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor),
            hostView.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor),
            hostView.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor)
        ])
    }
    
    func update(with temperature: Float, unit: String) {
        chartModel.append(temperature)
        currentValueLabel.attributedText = formattedTemperatureString(temperature, unit: unit)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
    }
    
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
