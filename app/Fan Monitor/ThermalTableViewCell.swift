//
//  ThermalTableViewCell.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 4/20/25.
//

import UIKit
import SwiftUI

class ThermalTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chartContainerView: UIView!
    
    private var chartHost: UIHostingController<ChartWrapperView>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 12
        self.contentView.layer.masksToBounds = true
        
        contentView.backgroundColor = .white
        backgroundColor = .clear
        
        
        let sampleData: [Double] = [42, 44, 43, 45, 46]
        let chartView = ChartWrapperView(data: sampleData)
        let hosting = UIHostingController(rootView: chartView)

        chartHost = hosting
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
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
