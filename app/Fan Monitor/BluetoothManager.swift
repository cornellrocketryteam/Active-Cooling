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
    
    private var peripheralList: [CBPeripheral] = []
    
    let BLE_Service_UUID = CBUUID.init(string: "00000001-0000-0715-2006-853A52A41A44")
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        peripheralList = []
                
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
        
        self.currPeripheral = peripheral
        self.peripheralList.append(peripheral)
        
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
            
        }
    }

    // Sets up notifications to the app from the Feather
    // Calls didUpdateValueForCharacteristic() whenever characteristic's value changes
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
        
    // Called when peripheral.readValue(for: characteristic) is called
    // Also called when characteristic value is updated in
    // didUpdateNotificationStateFor() method
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        
        switch characteristic.uuid {
        
        default:
            print("Unknown characteristic: \(characteristic.uuid)")
        }
        
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: self)
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
}

extension Notification.Name {
    static let bluetoothDidUpdate = Notification.Name("bluetoothDidUpdate")
}
