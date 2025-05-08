//
//  ThermalViewController.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 4/14/25.
//

import UIKit

enum UnitType {
    case celsius, fahrenheit
}

class ThermalViewController: UIViewController {

    @IBOutlet weak var fillStationView: FillStationView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedUnit: UnitType = .celsius
    var thermalCameraOn = false
    
    var currentTemps: [Float] = [0, 0, 0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.secondarySystemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTemp(_:)), name: .temp1DidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTemp(_:)), name: .temp2DidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTemp(_:)), name: .temp3DidUpdate, object: nil)
        
        setupSettingsMenu()
    }
    
    @objc func updateTemp(_ notification: Notification) {
        guard let str = notification.object as? String,
              let temp = Float(str) else { return }
        
        var indexToUpdate: Int?
        
        switch notification.name {
        case .temp1DidUpdate:
            currentTemps[0] = temp
            indexToUpdate = 0
        case .temp2DidUpdate:
            currentTemps[1] = temp
            indexToUpdate = 1
        case .temp3DidUpdate:
            currentTemps[2] = temp
            indexToUpdate = 2
        default:
            return
        }

        DispatchQueue.main.async {
            if let index = indexToUpdate {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
    
    func setupSettingsMenu() {
        let unitMenu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Celsius", image: UIImage(systemName: "degreesign.celsius"), state: selectedUnit == .celsius ? .on: .off) { _ in
                self.selectedUnit = .celsius
                self.setupSettingsMenu()
            },
            UIAction(title: "Fahrenheit", image: UIImage(systemName: "degreesign.fahrenheit"), state: selectedUnit == .fahrenheit ? .on: .off) { _ in
                self.selectedUnit = .fahrenheit
                self.setupSettingsMenu()
            },
        ])
        
        let separator = UIMenu(title: "", options: .displayInline, children: unitMenu.children)
        
        let thermalCameraMenu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Thermal Camera", image: UIImage(systemName: "camera"), state: thermalCameraOn == true ? .on : .off ) { _ in
                self.thermalCameraOn.toggle()
                self.setupSettingsMenu()
            },
        ])
        
        let menu = UIMenu(children: [
            separator,
            thermalCameraMenu
        ])
        
        settingsButton.menu = menu
        settingsButton.primaryAction = nil
    }
}

extension ThermalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "ThermalDetailViewController") as? ThermalDetailViewController {
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

extension ThermalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Data Sources"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.backgroundColor = .clear

        let container = UIView()
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
        ])

        return container
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ThermalCell", for: indexPath) as? ThermalTableViewCell else {
            return UITableViewCell()
        }
        
        cell.titleLabel.text = "Thermometer \(indexPath.row + 1)"
        let displayTemp = selectedUnit == .fahrenheit ? (currentTemps[indexPath.row] * 9.0 / 5.0 + 32) : currentTemps[indexPath.row]
        cell.update(with: displayTemp, unit: selectedUnit == .celsius ? "°C" : "°F")
        fillStationView.update(for: indexPath.row + 1, value: displayTemp)
        
        return cell
    }
}
