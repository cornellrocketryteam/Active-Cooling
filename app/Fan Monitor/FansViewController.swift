//
//  FansViewController.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 4/14/25.
//

import UIKit

class FansViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var modeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.secondarySystemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    @IBAction func modeSwitchTapped(_ sender: UISwitch) {
        modeLabel.text = sender.isOn ? "Current mode: Controller" : "Current mode: Manual"
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
