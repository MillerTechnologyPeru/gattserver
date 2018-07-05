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
    
    public private(set) var configuration: GATTIndoorPositioningConfiguration = GATTIndoorPositioningConfiguration(configurations: [.coordinates]) {
        
        didSet { peripheral[characteristic: configurationHandle] = configuration.data }
    }
    
    public private(set) var latitude: GATTLatitude = 0 {
        
        didSet { peripheral[characteristic: latitudeHandle] = latitude.data }
    }
    
    public private(set) var longitude: GATTLongitude = 0 {
        
        didSet { peripheral[characteristic: longitudeHandle] = longitude.data }
    }
    
    public private(set) var localNorthCoordinate: GATTLocalNorthCoordinate = 0 {
        
        didSet { peripheral[characteristic: localNorthCoordinateHandle] = localNorthCoordinate.data }
    }
    
    public private(set) var localEastCoordinate: GATTLocalEastCoordinate = 0 {
        
        didSet { peripheral[characteristic: localEastCoordinateHandle] = localEastCoordinate.data }
    }
    
    public private(set) var floorNumber: GATTFloorNumber = 0 {
        
        didSet { peripheral[characteristic: floorNumberHandle] = floorNumber.data }
    }
    
    public private(set) var altitude: GATTAltitude = GATTAltitude(altitude: 0) {
        
        didSet { peripheral[characteristic: altitudeHandle] = altitude.data }
    }
    
    public private(set) var uncertainty = GATTUncertainty(stationary: .stationary, updateTime: .upTo3s, precision: .lessThan10cm) {
        
        didSet { peripheral[characteristic: uncertaintyHandle] = uncertainty.data }
    }
    
    public private(set) var locationName: GATTLocationName = "" {
        
        didSet { peripheral[characteristic: locationNameHandle] = locationName.data }
    }
    
    internal let serviceHandle: UInt16
    
    internal let configurationHandle: UInt16
    internal let latitudeHandle: UInt16
    internal let longitudeHandle: UInt16
    internal let localNorthCoordinateHandle: UInt16
    internal let localEastCoordinateHandle: UInt16
    internal let floorNumberHandle: UInt16
    internal let altitudeHandle: UInt16
    internal let uncertaintyHandle: UInt16
    internal let locationNameHandle: UInt16
    
    internal let locationManager: LocationManager
    
    // MARK: - Initialization
    
    public init(peripheral: PeripheralManager) throws {
        
        self.peripheral = peripheral
        
        let serviceUUID = type(of: self).service
        
        #if os(Linux)
        let descriptors = [GATTClientCharacteristicConfiguration().descriptor]
        #else
        let descriptors: [GATT.Descriptor] = []
        #endif
        
        let characteristics = [
            GATT.Characteristic(uuid: type(of: configuration).uuid,
                                value: configuration.data,
                                permissions: [.read],
                                properties: [.read, .notify],
                                descriptors: descriptors),
            
            GATT.Characteristic(uuid: type(of: latitude).uuid,
                                value: latitude.data,
                                permissions: [.read],
                                properties: [.read, .notify],
                                descriptors: descriptors),
            
            GATT.Characteristic(uuid: type(of: longitude).uuid,
                                value: longitude.data,
                                permissions: [.read],
                                properties: [.read, .notify],
                                descriptors: descriptors),
            
            GATT.Characteristic(uuid: type(of: localNorthCoordinate).uuid,
                                value: localNorthCoordinate.data,
                                permissions: [.read],
                                properties: [.read, .notify],
                                descriptors: descriptors),
            
            GATT.Characteristic(uuid: type(of: localEastCoordinate).uuid,
                                value: localEastCoordinate.data,
                                permissions: [.read],
                                properties: [.read, .notify],
                                descriptors: descriptors),
            
            GATT.Characteristic(uuid: type(of: floorNumber).uuid,
                                value: floorNumber.data,
                                permissions: [.read],
                                properties: [.read, .notify],
                                descriptors: descriptors),
            
            GATT.Characteristic(uuid: type(of: altitude).uuid,
                                value: altitude.data,
                                permissions: [.read],
                                properties: [.read, .notify],
                                descriptors: descriptors),
            
            GATT.Characteristic(uuid: type(of: uncertainty).uuid,
                                value: uncertainty.data,
                                permissions: [.read],
                                properties: [.read, .notify],
                                descriptors: descriptors),
            
            GATT.Characteristic(uuid: type(of: locationName).uuid,
                                value: locationName.data,
                                permissions: [.read],
                                properties: [.read, .notify],
                                descriptors: descriptors)
        ]
        
        let service = GATT.Service(uuid: serviceUUID,
                                   primary: true,
                                   characteristics: characteristics)
        
        self.serviceHandle = try peripheral.add(service: service)
        self.configurationHandle = peripheral.characteristics(for: type(of: configuration).uuid)[0]
        self.latitudeHandle = peripheral.characteristics(for: type(of: latitude).uuid)[0]
        self.longitudeHandle = peripheral.characteristics(for: type(of: longitude).uuid)[0]
        self.localNorthCoordinateHandle = peripheral.characteristics(for: type(of: localNorthCoordinate).uuid)[0]
        self.localEastCoordinateHandle = peripheral.characteristics(for: type(of: localEastCoordinate).uuid)[0]
        self.floorNumberHandle = peripheral.characteristics(for: type(of: floorNumber).uuid)[0]
        self.altitudeHandle = peripheral.characteristics(for: type(of: altitude).uuid)[0]
        self.uncertaintyHandle = peripheral.characteristics(for: type(of: uncertainty).uuid)[0]
        self.locationNameHandle = peripheral.characteristics(for: type(of: locationName).uuid)[0]
        
        // start updating location
        #if os(macOS)
        self.locationManager = try DarwinLocationManager()
        self.locationManager.didUpdate = { [weak self] in self?.updateValues($0) }
        print("printing location")
        #elseif os(Linux)
        #endif
    }
    
    deinit {
        
        self.peripheral.remove(service: serviceHandle)
    }
    
    // MARK: - Methods
    
    private func updateValues(_ location: Location) {
        
        self.configuration = GATTIndoorPositioningConfiguration(configurations: [.coordinates])
        self.locationName = "Location"
        self.latitude = GATTLatitude(rawValue: Int32(location.coordinate.latitude))
        self.longitude = GATTLongitude(rawValue: Int32(location.coordinate.longitude))
    }
}
