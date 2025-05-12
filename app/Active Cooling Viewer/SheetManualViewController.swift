//
//  SheetManualViewController.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 5/8/25.
//

import UIKit
import CoreBluetooth

class SheetManualViewController: UIViewController {

    @IBOutlet weak var fan1TextField: UITextField!
    @IBOutlet weak var fan2TextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        if let fan1Text = fan1TextField.text, !fan1Text.isEmpty {
            BluetoothManager.shared.write(to: BluetoothManager.shared.fan1Char, value: fan1Text)
        }
        if let fan2Text = fan2TextField.text, !fan2Text.isEmpty {
            BluetoothManager.shared.write(to: BluetoothManager.shared.fan2Char, value: fan2Text)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
