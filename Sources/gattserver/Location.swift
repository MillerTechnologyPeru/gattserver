//
//  LocationManager.swift
//  gattserver
//
//  Created by Carlos Duclos on 7/4/18.
//

import Foundation
import CoreLocation

public protocol LocationManagerProtocol: class {
    
    var didUpdateLocation: ((Double, Double) -> Void)? { get set }
    
    var locationServicesEnabled: Bool { get }
    
    func startUpdatingLocation()
    
    func stopUpdatingLocation()
}

extension LocationManagerProtocol {
    
    public var didUpdateLocation: ((Double, Double) -> Void)?  {
        get { return nil }
        set { }
    }
    
}
