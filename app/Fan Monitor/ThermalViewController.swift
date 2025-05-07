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

    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedUnit: UnitType = .celsius
    var thermalCameraOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.secondarySystemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        
        setupSettingsMenu()
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ThermalCell", for: indexPath) as? StatsTableViewCell else {
            return UITableViewCell()
        }
        if (indexPath.row < 3) {
            cell.titleLabel.text = "Thermometer \(indexPath.row + 1)"
        } else {
            cell.titleLabel.text = "Thermal Camera"
        }
        

        return cell
    }
}
