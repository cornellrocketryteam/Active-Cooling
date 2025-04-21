//
//  FansViewController.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 4/14/25.
//

import UIKit

class FansViewController: UIViewController {

    @IBOutlet weak var modeLabel: UILabel!
    
    let fanSections = ["Fan 1", "Fan 2"]
    var fanStates: [Bool] = [true, true]
    var fanValues: [Int] = [42, 42]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func modeSwitchTapped(_ sender: UISwitch) {
        modeLabel.text = sender.isOn ? "Current mode: Controller" : "Current mode: Manual"
    }
    
}

