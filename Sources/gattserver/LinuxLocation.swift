//
//  LinuxLocation.swift
//  gattserver
//
//  Created by Carlos Duclos on 7/4/18.
//

import Foundation

#if os(Linux)

public typealias LocationManager = LinuxLocation

public final class LinuxLocation: LocationManagerProtocol {
    
    public var locationServicesEnabled: Bool {
        
        return false
    }
    
    public func startUpdatingLocation() {
        
    }
    
    public func stopUpdatingLocation() {
        
    }
    
}

#endif
