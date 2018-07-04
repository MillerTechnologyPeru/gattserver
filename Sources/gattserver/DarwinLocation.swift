//
//  DarwinLocationManager.swift
//  gattserver
//
//  Created by Carlos Duclos on 7/4/18.
//

#if os(macOS) && swift(>=3.2)

import Foundation
import CoreLocation

public typealias LocationManager = DarwinLocation

public class DarwinLocation: NSObject, LocationManagerProtocol {
    
    internal private(set) var internalManager: CLLocationManager!
    
    public var locationServicesEnabled: Bool {
        
        return CLLocationManager.locationServicesEnabled()
    }
    
    public static var authorizationStatus: CLAuthorizationStatus {
        
        return CLLocationManager.authorizationStatus()
    }
    
    override init() {
        super.init()
        
        internalManager = CLLocationManager()
        internalManager.delegate = self
    }
    
    public func startUpdatingLocation() {
        print("startUpdatingLocation")
        internalManager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        print("stopUpdatingLocation")
        internalManager.stopUpdatingLocation()
    }
}

extension DarwinLocation: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first
            else { return }
        
        didUpdateLocation?(location.coordinate.latitude, location.coordinate.longitude)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error location", error)
    }
    
}

#endif
