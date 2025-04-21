//
//  FillStationView.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 4/20/25.
//

import UIKit

class FillStationView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        layer.cornerRadius = 16
        drawBoxLayout()
    }

    private func drawBoxLayout() {
        // Box outline
        let boxLayer = CAShapeLayer()
        let boxSize = CGSize(width: 250, height: 250)
        let origin = CGPoint(
            x: (bounds.width - boxSize.width) / 2,
            y: (bounds.height - boxSize.height) / 2 - 15
        )
        let fixedBoxFrame = CGRect(origin: origin, size: boxSize)
        boxLayer.path = UIBezierPath(roundedRect: fixedBoxFrame, cornerRadius: 16).cgPath
        boxLayer.strokeColor = UIColor.black.cgColor
        boxLayer.fillColor = UIColor.clear.cgColor
        boxLayer.lineWidth = 3
        layer.addSublayer(boxLayer)


//            addComponent(x: 30, y: 100, width: 100, height: 40, label: "PCB")
//            addComponent(x: 30, y: 160, width: 100, height: 40, label: "PCB")
//            addComponent(x: 160, y: 220, width: 100, height: 50, label: "PSU")

    }

    private func addComponent(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, label: String) {
        let component = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        component.backgroundColor = .white
        component.layer.cornerRadius = 8
        component.layer.borderWidth = 1
        component.layer.borderColor = UIColor.gray.cgColor
        addSubview(component)

        let labelView = UILabel(frame: component.bounds)
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        labelView.textAlignment = .center
        labelView.textColor = .black
        component.addSubview(labelView)
    }
}
