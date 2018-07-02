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
    public private(set) var manufacturerName: GATTManufacturerNameString = ""
    public private(set) var firmwareRevision: GATTFirmwareRevisionString = ""
    public private(set) var softwareRevision: GATTSoftwareRevisionString = ""
    
    internal let serviceHandle: UInt16
    
    internal let modelNumberHandle: UInt16
    internal let manufacturerNameHandle: UInt16
    internal let firmwareRevisionHandle: UInt16
    internal let softwareRevisionHandle: UInt16
    
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
                                descriptors: descriptors),
            
            GATT.Characteristic(uuid: type(of: manufacturerName).uuid,
                                value: manufacturerName.data,
                                permissions: [.read],
                                properties: [.read],
                                descriptors: descriptors),
            
            GATT.Characteristic(uuid: type(of: firmwareRevision).uuid,
                                value: firmwareRevision.data,
                                permissions: [.read],
                                properties: [.read],
                                descriptors: descriptors),
            
            GATT.Characteristic(uuid: type(of: softwareRevision).uuid,
                                value: softwareRevision.data,
                                permissions: [.read],
                                properties: [.read],
                                descriptors: descriptors)
        ]
        
        let service = GATT.Service(uuid: serviceUUID,
                                   primary: true,
                                   characteristics: characteristics)
        
        self.serviceHandle = try peripheral.add(service: service)
        self.modelNumberHandle = peripheral.characteristics(for: type(of: modelNumber).uuid)[0]
        self.manufacturerNameHandle = peripheral.characteristics(for: type(of: manufacturerName).uuid)[0]
        self.firmwareRevisionHandle = peripheral.characteristics(for: type(of: firmwareRevision).uuid)[0]
        self.softwareRevisionHandle = peripheral.characteristics(for: type(of: softwareRevision).uuid)[0]
        
        updateValues()
    }
    
    deinit {
        
        self.peripheral.remove(service: serviceHandle)
        
        self.timer?.invalidate()
    }
    
    // MARK: - Methods
    
    func updateValues() {
        
        modelNumber = "MacBookPro14.3"
        manufacturerName = "MacBookProcito"
        firmwareRevision = "Firmware revision string"
        softwareRevision = "Software revision string"
        
        peripheral[characteristic: modelNumberHandle] = modelNumber.data
        peripheral[characteristic: manufacturerNameHandle] = manufacturerName.data
        peripheral[characteristic: firmwareRevisionHandle] = firmwareRevision.data
        peripheral[characteristic: softwareRevisionHandle] = softwareRevision.data
    }
}
