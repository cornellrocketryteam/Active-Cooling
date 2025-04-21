//
//  ThermalTableViewCell.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 4/20/25.
//

import UIKit

class ThermalTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 12
        self.contentView.layer.masksToBounds = true
        
        contentView.backgroundColor = .white
        backgroundColor = .clear
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
