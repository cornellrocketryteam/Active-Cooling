//
//  FansViewController.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 4/14/25.
//

import UIKit

class FansViewController: UIViewController {

    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var modeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.secondarySystemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFan1(_:)), name: .fan1DidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateFan2(_:)), name: .fan2DidUpdate, object: nil)
    }
    
    
    @IBAction func modeSwitchTapped(_ sender: UISwitch) {
        modeLabel.text = sender.isOn ? "Current mode: Controller" : "Current mode: Manual"
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sheetVC: UIViewController
        
        if modeSwitch.isOn {
            sheetVC = storyboard.instantiateViewController(withIdentifier: "ControllerSettingsSheet")
            
            if let sheet = sheetVC.sheetPresentationController {
                sheet.detents = [
                        .custom { context in
                            return 150
                        }
                    ]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.preferredCornerRadius = 20
            }
        } else {
            sheetVC = storyboard.instantiateViewController(withIdentifier: "ManualSettingsSheet")

            if let sheet = sheetVC.sheetPresentationController {
                sheet.detents = [
                        .custom { context in
                            return 200
                        }
                    ]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.preferredCornerRadius = 20
            }
        }
        
        sheetVC.modalPresentationStyle = .pageSheet
        present(sheetVC, animated: true)
    }
    
    
    @objc func updateFan1(_ notification: Notification) {
        
    }
    
    @objc func updateFan2(_ notification: Notification) {
        
    }
    
}

extension FansViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let detailVC = storyboard.instantiateViewController(withIdentifier: "ThermalDetailViewController") as? ThermalDetailViewController {
//            navigationController?.pushViewController(detailVC, animated: true)
//        }
    }
}

extension FansViewController: UITableViewDataSource {
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FansCell", for: indexPath) as? FansTableViewCell else {
            return UITableViewCell()
        }
        
        cell.titleLabel.text = "Fan \(indexPath.row + 1)"
        
        return cell
    }
}
