//
//  IndoorPositioningService.swift
//  gattserver
//
//  Created by Carlos Duclos on 7/4/18.
//

import Foundation
import Bluetooth
import GATT

public final class GATTIndoorPositioningnServiceController: GATTServiceController {
    
    public static let service: BluetoothUUID = .indoorPositioning
    
    // MARK: - Properties
    
    public let peripheral: PeripheralManager
    
    public private(set) var latitude: GATTLatitude = 0
    
    internal let serviceHandle: UInt16
    
    internal let latitudeHandle: UInt16
    
    internal let locationManager: LocationManager
    
    // MARK: - Initialization
    
    public init(peripheral: PeripheralManager) throws {
        
        self.peripheral = peripheral
        
        self.locationManager = LocationManager()
        
        let serviceUUID = type(of: self).service
        
        #if os(Linux)
        let descriptors = [GATTClientCharacteristicConfiguration().descriptor]
        #else
        let descriptors: [GATT.Descriptor] = []
        #endif
        
        let characteristics = [
            GATT.Characteristic(uuid: type(of: latitude).uuid,
                                value: latitude.data,
                                permissions: [.read],
                                properties: [.read, .notify],
                                descriptors: descriptors)
        ]
        
        let service = GATT.Service(uuid: serviceUUID,
                                   primary: true,
                                   characteristics: characteristics)
        
        self.serviceHandle = try peripheral.add(service: service)
        self.latitudeHandle = peripheral.characteristics(for: type(of: latitude).uuid)[0]
        
        locationManager.didUpdateLocation = { latitude, longitude in
            print("latitude", latitude)
            print("longitude", longitude)
        }
        
        locationManager.startUpdatingLocation()
        
        updateValues()
    }
    
    deinit {
        
        self.peripheral.remove(service: serviceHandle)
    }
    
    // MARK: - Methods
    
    func updateValues() {
        
        latitude = GATTLatitude(rawValue: 123)
        
        peripheral[characteristic: latitudeHandle] = latitude.data
        
//        UIDevice.current.
    }
}
