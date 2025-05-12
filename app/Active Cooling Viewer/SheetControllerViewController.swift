//
//  SheetControllerViewController.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 5/8/25.
//

import UIKit

class SheetControllerViewController: UIViewController {

    @IBOutlet weak var kpTextField: UITextField!
    @IBOutlet weak var desiredTempTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func sendButtonTapped(_ sender: Any) {
        if let kpText = kpTextField.text, !kpText.isEmpty {
            BluetoothManager.shared.write(to: BluetoothManager.shared.kpChar, value: kpText)
        }
        
        if let desiredTempText = desiredTempTextField.text, !desiredTempText.isEmpty {
            BluetoothManager.shared.write(to: BluetoothManager.shared.desiredTempChar, value: desiredTempText)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
