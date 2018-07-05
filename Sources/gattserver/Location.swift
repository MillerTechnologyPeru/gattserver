//
//  LocationManager.swift
//  gattserver
//
//  Created by Carlos Duclos on 7/4/18.
//

import Foundation

/// Location Manager protocol
public protocol LocationManager: class {
    
    /// Location was updated.
    var didUpdate: ((Location) -> ())? { get set }
    
    /// Start updating location.
    func start() throws
    
    /// Stop updating location.
    func stop()
    
    /// Whether the location is updating.
    var isUpdating: Bool
    
    /// 
    var location: Location?
}

/// Location
public struct Location {
    
    public var latitude: Double
    
    public var longitude: Double
    
    public init(latitude: Double,
                longitude: Double) {
        
        self.latitude = latitude
        self.longitude = longitude
    }
}
