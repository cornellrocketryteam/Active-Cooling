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
    
    var currentPWMs: [Int32] = [0, 0]
    
    var chartModels: [FansChartDataModel] = [
        FansChartDataModel(),
        FansChartDataModel()
    ]
    
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
        BluetoothManager.shared.write(to: BluetoothManager.shared.modeChar, value: sender.isOn ? "1" : "0")
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sheetVC: UIViewController
        
        if modeSwitch.isOn {
            sheetVC = storyboard.instantiateViewController(withIdentifier: "ControllerSettingsSheet")
            sheetVC.modalPresentationStyle = .pageSheet
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
        } else {
            sheetVC = storyboard.instantiateViewController(withIdentifier: "ManualSettingsSheet")
            sheetVC.modalPresentationStyle = .pageSheet
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
        present(sheetVC, animated: true)
    }
    
    
    @objc func updateFan1(_ notification: Notification) {
        guard let str = notification.object as? String,
              let pwm = Int32(str) else { return }
        print("here0")
        currentPWMs[0] = pwm
        chartModels[0].append(pwm)
        print("Fan 0: appended \(pwm), count: \(chartModels[0].data.count)")

        tableView.reloadData()
    }
    
    @objc func updateFan2(_ notification: Notification) {
        guard let str = notification.object as? String,
              let pwm = Int32(str) else { return }
        print("here1")
        currentPWMs[1] = pwm
        chartModels[1].append(pwm)
        print("Fan 1: appended \(pwm), count: \(chartModels[1].data.count)")

        tableView.reloadData()
    }
    
}

extension FansViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        cell.update(model: chartModels[indexPath.row], pwm: currentPWMs[indexPath.row])
        
        return cell
    }
}
