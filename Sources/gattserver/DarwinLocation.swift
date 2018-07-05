//
//  DarwinLocationManager.swift
//  gattserver
//
//  Created by Carlos Duclos on 7/4/18.
//

#if os(macOS) && swift(>=3.2)

import Foundation
import CoreLocation

public class DarwinLocation: NSObject, LocationManager {
    
    // MARK: - Properties
    
    public var didUpdate: ((Location) -> ())?
    
    public private(set) var isUpdating: Bool = false
    
    internal let internalManager: CLLocationManager
    
    public static var isEnabled: Bool {
        
        return CLLocationManager.locationServicesEnabled()
    }
    
    public static var authorizationStatus: CLAuthorizationStatus {
        
        return CLLocationManager.authorizationStatus()
    }
    
    // MARK: - Initialization
    
    public override init() {
        
        self.internalManager = CLLocationManager()
        
        super.init()
        
        internalManager.delegate = self
    }
    
    // MARK: - Methods
    
    public func start() throws {
        
        internalManager.startUpdatingLocation()
    }
    
    public func stop() {
        
        internalManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension DarwinLocation: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        /**
         An array of CLLocation objects containing the location data. This array always contains at least one object representing the current location. If updates were deferred or if multiple locations arrived before they could be delivered, the array may contain additional entries. The objects in the array are organized in the order in which they occurred. Therefore, the most recent location update is at the end of the array.
         */
        
        guard let location = locations.last
            else { return }
        
        didUpdateLocation?(location.coordinate.latitude, location.coordinate.longitude)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error location", error)
    }
    
}

#endif
