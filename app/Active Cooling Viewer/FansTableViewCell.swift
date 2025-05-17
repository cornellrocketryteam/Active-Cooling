//
//  FansTableCellView.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 5/8/25.
//

import UIKit
import SwiftUI

class FansTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var chartContainerView: UIView!
    
    private var chartData: [Float] = []
    private var hostingController: UIHostingController<FansChartView>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 12
        self.contentView.layer.masksToBounds = true
        
        contentView.backgroundColor = .white
        backgroundColor = .clear
    }
    
    // Update the chart with new values
    func update(model: FansChartDataModel, pwm: Int32) {
        currentValueLabel.text = String(pwm)

        if let hosting = hostingController {
            print("has hosting, update model")
            hosting.rootView = FansChartView(model: model, color: .blue)
        } else {
            // First-time creation
            let chartView = FansChartView(model: model, color: .blue)
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
