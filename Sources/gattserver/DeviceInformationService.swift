//
//  DeviceInformationService.swift
//  gattserver
//
//  Created by Carlos Duclos on 7/2/18.
//

import Foundation
import Bluetooth
import GATT

public final class GATTDeviceInformationServiceController: GATTServiceController {
    
    public static let service: BluetoothUUID = .deviceInformation
    
    // MARK: - Properties
    
    public let peripheral: PeripheralManager
    
    public private(set) var modelNumber: GATTModelNumber = ""
    
    internal let serviceHandle: UInt16
    
    internal let modelNumberHandle: UInt16
    
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
            GATT.Characteristic(uuid: type(of: modelNumber).uuid,
                                value: modelNumber.data,
                                permissions: [.read],
                                properties: [.read],
                                descriptors: descriptors)
        ]
        
        let service = GATT.Service(uuid: serviceUUID,
                                   primary: true,
                                   characteristics: characteristics)
        
        self.serviceHandle = try peripheral.add(service: service)
        self.modelNumberHandle = peripheral.characteristics(for: type(of: modelNumber).uuid)[0]
        
        updateValue()
    }
    
    deinit {
        
        self.peripheral.remove(service: serviceHandle)
        
        self.timer?.invalidate()
    }
    
    // MARK: - Methods
    
    func updateValue() {
        
        self.modelNumber = "MacBookPro14.3"
        
        peripheral[characteristic: modelNumberHandle] = modelNumber.data
    }
}
