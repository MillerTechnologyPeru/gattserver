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
    
    /// Last reported location.
    var location: Location? { get }
}

public struct Location {
    
    public var coordinate: Coordinate
    
    public init(coordinate: Coordinate) {
        
        self.coordinate = coordinate
    }
}

public extension Location {
    
    public typealias Coordinate = LocationCoordinate
}

/*
 *  LocationCoordinate
 *
 *  Discussion:
 *    A structure that contains a geographical coordinate.
 *
 *  Fields:
 *    latitude:
 *      The latitude in degrees.
 *    longitude:
 *      The longitude in degrees.
 */
public struct LocationCoordinate {
    
    public typealias Degrees = Double
    
    /// The latitude in degrees.
    public var latitude: Degrees
    
    /// The longitude in degrees.
    public var longitude: Degrees
    
    public init(latitude: Degrees,
                longitude: Degrees) {
        
        self.latitude = latitude
        self.longitude = longitude
    }
}
