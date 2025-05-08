//
//  SheetControllerViewController.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 5/8/25.
//

import UIKit

class SheetControllerViewController: UIViewController {

    @IBOutlet weak var kpTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func sendButtonTapped(_ sender: Any) {
        if let kpText = kpTextField.text, !kpText.isEmpty {
            BluetoothManager.shared.write(to: BluetoothManager.shared.kpChar, value: kpText)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
