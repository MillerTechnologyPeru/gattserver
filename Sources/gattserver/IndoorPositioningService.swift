//
//  IndoorPositioningService.swift
//  gattserver
//
//  Created by Carlos Duclos on 7/4/18.
//

import Foundation

import Foundation
import Bluetooth
import GATT

public final class GATTIndoorPositioningServiceController: GATTServiceController {
    
    public static let service: BluetoothUUID = .indoorPositioning
    
    // MARK: - Properties
    
    public let peripheral: PeripheralManager
    
//    public private(set) var indoorPositioningConfiguration = gattindoor(level: .min)
    
    internal let serviceHandle: UInt16
    
//    internal let indoorPositioningConfigurationHandle: UInt16
    
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
        
        let characteristics: [GATT.Characteristic] = [
//            GATT.Characteristic(uuid: type(of: batteryLevel).uuid,
//                                value: batteryLevel.data,
//                                permissions: [.read],
//                                properties: [.read, .notify],
//                                descriptors: descriptors)
        ]
        
        let service = GATT.Service(uuid: serviceUUID,
                                   primary: true,
                                   characteristics: characteristics)
        
        self.serviceHandle = try peripheral.add(service: service)
//        self.indoorPositioningConfigurationHandle = peripheral.characteristics(for: type(of: batteryLevel).uuid)[0]
        
        // update value
        self.update()
    }
    
    deinit {
        
        self.peripheral.remove(service: serviceHandle)
    }
    
    // MARK: - Methods
    
    private func update() {
        
    }
}
