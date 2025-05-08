//
//  BluetoothManager.swift
//  Fan Monitor
//
//  Created by Cameron Goddard on 4/29/25.
//

import Foundation
import CoreBluetooth


class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    static let shared = BluetoothManager()
    
    private var centralManager: CBCentralManager!
    
    var currPeripheral: CBPeripheral?
    var rssiList = [NSNumber]()
        
    let BLE_Service_UUID = CBUUID.init(string: "00000001-0000-0715-2006-853A52A41A44")

    let Temp1_Char_UUID = CBUUID(string: "00000002-0000-0715-2006-853A52A41A44")
    let Temp2_Char_UUID = CBUUID(string: "00000003-0000-0715-2006-853A52A41A44")
    let Temp3_Char_UUID = CBUUID(string: "00000004-0000-0715-2006-853A52A41A44")
    let Fan1_Char_UUID = CBUUID(string: "00000005-0000-0715-2006-853A52A41A44")
    let Fan2_Char_UUID = CBUUID(string: "00000006-0000-0715-2006-853A52A41A44")
    let Kp_Char_UUID = CBUUID(string: "00000007-0000-0715-2006-853A52A41A44")
    
    private var temp1Char: CBCharacteristic?
    private var temp2Char: CBCharacteristic?
    private var temp3Char: CBCharacteristic?
    
    var fan1Char: CBCharacteristic?
    var fan2Char: CBCharacteristic?
    var kpChar: CBCharacteristic?
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        print("Scanning...")
        centralManager?.scanForPeripherals(withServices: [BLE_Service_UUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        // Check to see if Bluetooth is enabled
        if central.state == CBManagerState.poweredOn {
            startScan()
        } else {
            print("Error: Bluetooth is not turned on")
        }
    }
    
    // Called when a peripheral is found
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Peripheral Found: \(peripheral.name ?? "Unknown"))")
        self.currPeripheral = peripheral
        
        self.rssiList.append(RSSI)
        peripheral.delegate = self

        if self.currPeripheral != nil {
            centralManager?.connect(currPeripheral!, options: nil)
        }
    }
    
    // Called when the central manager successfully connects with the peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        self.centralManager?.stopScan()
        
        peripheral.delegate = self
        peripheral.discoverServices([BLE_Service_UUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
            
        if error != nil {
            print("Error: Failed to connect to peripheral")
            return
        }
    }
        
    // Called when the central manager disconnects from the peripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("Peripheral disconnected")
        startScan()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        // Check for any errors in discovery
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }

        // Store the discovered services in a variable. If no services are there, return
        guard let services = peripheral.services else {
            return
        }
        
        print("Discovered Services: \(services)")

        for service in services {
            // If service's UUID matches with our specified one...
            if service.uuid == BLE_Service_UUID {
                print("BLE service found")
                
                // Search for the characteristics of the service
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
        
    // Called when the characteristics we specified are discovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        // Check if there was an error
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        // Store the discovered characteristics in a variable. If no characteristics, then return
        guard let characteristics = service.characteristics else {
            return
        }
        
        // Print to console for debugging purposes
        print("Found \(characteristics.count) characteristics!")
        
        // For every characteristic found...
        for characteristic in characteristics {
            switch characteristic.uuid {
            case Fan1_Char_UUID:
                fan1Char = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            case Fan2_Char_UUID:
                fan2Char = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            case Temp1_Char_UUID:
                temp1Char = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            case Temp2_Char_UUID:
                temp2Char = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            case Temp3_Char_UUID:
                temp3Char = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            default:
                print("Unknown characteristic: \(characteristic.uuid)")
            }
        }

    }
        
    // Called when peripheral.readValue(for: characteristic) is called
    // Also called when characteristic value is updated in
    // didUpdateNotificationStateFor() method
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let value = characteristic.value else { return }
        
        let stringValue = String(decoding: value, as: UTF8.self)
//        
        print("Characteristic uuid: \(characteristic.uuid), value: \(stringValue)")
        
        
        switch characteristic.uuid {
        case Fan1_Char_UUID:
            NotificationCenter.default.post(name: .fan1DidUpdate, object: stringValue)
        case Fan2_Char_UUID:
            NotificationCenter.default.post(name: .fan2DidUpdate, object: stringValue)
        case Temp1_Char_UUID:
            print("Temp 1")
            NotificationCenter.default.post(name: .temp1DidUpdate, object: stringValue)
        case Temp2_Char_UUID:
            NotificationCenter.default.post(name: .temp2DidUpdate, object: stringValue)
        case Temp3_Char_UUID:
            NotificationCenter.default.post(name: .temp3DidUpdate, object: stringValue)
        default:
            print("Unhandled characteristic: \(characteristic.uuid)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")

        // Check if subscription was successful
        if (error != nil) {
            print("Error changing notification state:\(String(describing: error?.localizedDescription))")

        } else {
            print("Characteristic's value subscribed")
        }

        // Print message for debugging purposes
        if (characteristic.isNotifying) {
            print("Subscribed. Notification has begun for: \(characteristic.uuid)")
        }
    }

    
    // Called when app wants to send a message to peripheral
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        print("Message sent")
    }

    // Called when descriptors for a characteristic are found
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            print("\(error.debugDescription)")
            return
        }
        
        // Store descriptors in a variable. Return if nonexistent.
        guard let descriptors = characteristic.descriptors else { return }
            
        // For every descriptor, print its description for debugging purposes
        descriptors.forEach { descript in
            print("function name: DidDiscoverDescriptorForChar \(String(describing: descript.description))")
        }
    }
    
    func write(to characteristic: CBCharacteristic?, value: String) {
        guard let peripheral = currPeripheral,
              let characteristic = characteristic else { return }

        if let data = value.data(using: .utf8) {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
}

extension Notification.Name {
    static let fan1DidUpdate = Notification.Name("fan1DidUpdate")
    static let fan2DidUpdate = Notification.Name("fan2DidUpdate")
    static let temp1DidUpdate = Notification.Name("temp1DidUpdate")
    static let temp2DidUpdate = Notification.Name("temp2DidUpdate")
    static let temp3DidUpdate = Notification.Name("temp3DidUpdate")
}
