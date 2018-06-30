//
//  BatteryService.swift
//  gattserver
//
//  Created by Alsey Coleman Miller on 6/29/18.
//
//

import Foundation
import Bluetooth
import GATT

public final class GATTBatteryServiceController: GATTServiceController {
    
    public static let service: BluetoothUUID = .batteryService
    
    // MARK: - Properties
    
    public let peripheral: PeripheralManager
    
    public private(set) var batteryLevel = GATTBatteryLevel(level: .min) {
        
        didSet { peripheral[characteristic: batteryLevelHandle] = batteryLevel.data }
    }
    
    internal let serviceHandle: UInt16
    
    internal let batteryLevelHandle: UInt16
    
    internal var timer: Timer!
    
    // MARK: - Initialization
    
    public init(peripheral: PeripheralManager) throws {
        
        self.peripheral = peripheral
        
        #if os(macOS)
        let serviceUUID = BluetoothUUID()
        #else
        let serviceUUID = type(of: self).service
        #endif
        
        #if os(Linux)
        let descriptors = [GATTClientCharacteristicConfiguration().descriptor]
        #else
        let descriptors: [GATT.Descriptor] = []
        #endif
        
        let characteristics = [
            GATT.Characteristic(uuid: type(of: batteryLevel).uuid,
                                value: batteryLevel.data,
                                permissions: [.read],
                                properties: [.read, .notify],
                                descriptors: descriptors)
        ]
        
        let service = GATT.Service(uuid: serviceUUID,
                                   primary: true,
                                   characteristics: characteristics)
        
        self.serviceHandle = try peripheral.add(service: service)
        self.batteryLevelHandle = peripheral.characteristics(for: type(of: batteryLevel).uuid)[0]
        
        // update value
        self.updateBatteryLevel()
        
        // setup timer
        if #available(OSX 10.12, *) {
            self.timer = Timer(timeInterval: 1.0,
                               repeats: true,
                               block: { [unowned self] _ in self.updateBatteryLevel() })
        } else {
            self.timer = Timer(timeInterval: 1.0,
                               target: self,
                               selector: #selector(updateBatteryLevelSelector),
                               userInfo: nil,
                               repeats: true)
        }
        
        RunLoop.main.add(timer, forMode: .commonModes)
    }
    
    deinit {
        
        self.peripheral.remove(service: serviceHandle)
        
        self.timer?.invalidate()
    }
    
    // MARK: - Methods
    
    #if os(macOS)
    @objc private func updateBatteryLevelSelector() {
        
        updateBatteryLevel()
    }
    #endif
    
    private func updateBatteryLevel() {
        
        let level: GATTBatteryPercentage
        
        if UIDevice.current.batteryLevel != -1,
            let percentage = GATTBatteryPercentage(rawValue: UInt8(UIDevice.current.batteryLevel * 100)) {
            
            level = percentage
            
        } else {
            
            level = .min
        }
        
        // only change if value changed
        guard batteryLevel.level != level
            else { return }
        
        // will write to GATT DB
        self.batteryLevel = GATTBatteryLevel(level: level)
    }
}
