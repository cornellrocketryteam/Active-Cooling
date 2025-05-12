//
//  FillStationView.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 4/20/25.
//

import UIKit

enum Component {
    case PCB
    case TempSensor
    case Fan
}

class FillStationView: UIView {

    private var tempSensorButtons: [Int: UIButton] = [:]
    
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
    
    func update(for tempSensor: Int, value: Float) {
        if let button = tempSensorButtons[tempSensor] {
            button.setTitle(String(format: "%.0f°", value), for: .normal)
        }
    }
    
    private func drawBoxLayout() {
        // Box outline
        let boxLayer = CAShapeLayer()
        let boxSize = CGSize(width: 250, height: 250)
        let origin = CGPoint(
            x: (bounds.width - boxSize.width) / 2,
            y: (bounds.height - boxSize.height) / 2
        )
        let fixedBoxFrame = CGRect(origin: origin, size: boxSize)
        boxLayer.path = UIBezierPath(roundedRect: fixedBoxFrame, cornerRadius: 16).cgPath
        boxLayer.strokeColor = UIColor.black.cgColor
        boxLayer.fillColor = UIColor.clear.cgColor
        boxLayer.lineWidth = 4
        layer.addSublayer(boxLayer)

        let piSize = CGSize(width: 40, height: 50)
        let piOrigin = CGPoint(
            x: fixedBoxFrame.midX - piSize.width / 2,
            y: fixedBoxFrame.midY - piSize.height / 2
        )

        // Pi
        addComponent(
            component: .PCB,
            x: piOrigin.x,
            y: piOrigin.y,
            width: piSize.width,
            height: piSize.height,
            label: "Pi"
        )
        
        // Igniter Board 1
        addComponent(
            component: .PCB,
            x: piOrigin.x,
            y: piOrigin.y + 65,
            width: 40,
            height: 50,
            label: ""
        )
        
        // Igniter Board 2
        addComponent(
            component: .PCB,
            x: fixedBoxFrame.minX + 2,
            y: 175,
            width: 20,
            height: 30,
            label: ""
        )
        
        // Power Board
        addComponent(
            component: .PCB,
            x: fixedBoxFrame.minX + 175,
            y: 210,
            width: 35,
            height: 35,
            label: ""
        )
        
        // Sense Board
        addComponent(
            component: .PCB,
            x: fixedBoxFrame.minX + 2,
            y: 215,
            width: 20,
            height: 30,
            label: ""
        )
        
        // Relay Board
        addComponent(
            component: .PCB,
            x: fixedBoxFrame.maxX - 22,
            y: 190,
            width: 20,
            height: 30,
            label: ""
        )
        
        // Ball Valve Board
        addComponent(
            component: .PCB,
            x: fixedBoxFrame.maxX - 22,
            y: 140,
            width: 20,
            height: 30,
            label: ""
        )
        
        // Fan 1
        addComponent(
            component: .Fan,
            x: fixedBoxFrame.minX + 25,
            y: 245,
            width: 45,
            height: 30,
            label: "F1"
        )
        
        // Fan 2
        addComponent(
            component: .Fan,
            x: fixedBoxFrame.minX + 190,
            y: 40,
            width: 50,
            height: 30,
            label: "F2"
        )
        
        addTempSensor(index: 1, x: fixedBoxFrame.minX + 145, y: 140)
        addTempSensor(index: 2, x: fixedBoxFrame.minX + 80, y: 245)
        addTempSensor(index: 3, x: fixedBoxFrame.minX + 40, y: 40)
        
    }

    private func addComponent(component: Component, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, label: String) {
        switch component {
        case .PCB:
            let componentView = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
            componentView.backgroundColor = .green
            componentView.layer.cornerRadius = 6
            
            let labelView = UILabel(frame: componentView.bounds)
            labelView.text = label
            labelView.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            labelView.textAlignment = .center
            labelView.textColor = .black
            componentView.addSubview(labelView)
            
            addSubview(componentView)
            
        case .TempSensor, .Fan:
            let button = UIButton(type: .system)
            button.frame = CGRect(x: x, y: y, width: width, height: height)
            button.backgroundColor = .clear
            
            button.setTitle(label, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
            
            let imageName: String
            switch component {
            case .TempSensor:
                imageName = "thermometer.variable"
            case .Fan:
                imageName = "fan"
            case .PCB:
                imageName = ""
            }
            
            if let image = UIImage(systemName: imageName) {
                button.setImage(image, for: .normal)
                button.tintColor = .black
                
                button.semanticContentAttribute = .forceLeftToRight
            }
            
            addSubview(button)
        }
    }
    
    private func addTempSensor(index: Int, x: CGFloat, y: CGFloat) {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: x, y: y, width: 50, height: 30)
        button.backgroundColor = .clear
        button.setTitle("42°", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)

        if let image = UIImage(systemName: "thermometer.variable") {
            button.setImage(image, for: .normal)
            button.tintColor = .black
            button.semanticContentAttribute = .forceLeftToRight
        }

        tempSensorButtons[index] = button
        addSubview(button)
    }
    
//    private func addFan(index)
}
