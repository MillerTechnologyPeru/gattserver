//
//  DarwinLocationManager.swift
//  gattserver
//
//  Created by Carlos Duclos on 7/4/18.
//

//#if os(macOS)

import Foundation
import CoreLocation

public final class DarwinLocationManager: LocationManager {
    
    // MARK: - Properties
    
    public var didUpdate: ((Location) -> ())?
    
    private var _location: Location?  {
        
        didSet { if let location = self.location { didUpdate?(location) } }
    }
    
    public fileprivate(set) var location: Location? {
        
        get { return accessQueue.sync { [unowned self] in return self._location } }
        
        set { accessQueue.sync { [unowned self] in self._location = newValue } }
    }
    
    internal let internalManager: CLLocationManager
    
    internal let delegate: InternalDelegate
    
    internal var internalState = InternalState()
    
    internal lazy var accessQueue: DispatchQueue = DispatchQueue(label: "\(type(of: self)) Access Queue", attributes: [])
    
    public static var isEnabled: Bool {
        
        return CLLocationManager.locationServicesEnabled()
    }
    
    public static var authorizationStatus: CLAuthorizationStatus {
        
        return CLLocationManager.authorizationStatus()
    }
    
    // MARK: - Initialization
    
    public init(didUpdate: ((Location) -> ())? = nil) throws {
        
        // initialize properties
        self.internalManager = CLLocationManager()
        self.delegate = InternalDelegate()
        self.didUpdate = didUpdate
        
        // set delegate
        self.delegate.locationManager = self
        internalManager.delegate = self.delegate
        
        // start updating location
        try start()
    }
    
    deinit {
        
        stop()
    }
    
    // MARK: - Methods
    
    // only call once
    private func start() throws {
        
        let semaphore = Semaphore(timeout: 30, operation: .startUpdatingLocation)
        accessQueue.sync { [unowned self] in self.internalState.start.semaphore = semaphore }
        defer { accessQueue.sync { [unowned self] in self.internalState.start.semaphore = nil } }
        
        internalManager.startUpdatingLocation()
        
        try semaphore.wait()
    }
    
    private func stop() {
        
        internalManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension DarwinLocationManager {
    
    @objc(DarwinLocationManagerInternalDelegate)
    final class InternalDelegate: NSObject {
        
        weak var locationManager: DarwinLocationManager?
    }
}

extension DarwinLocationManager.InternalDelegate: CLLocationManagerDelegate {
    
    @objc
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        /**
         An array of CLLocation objects containing the location data. This array always contains at least one object representing the current location. If updates were deferred or if multiple locations arrived before they could be delivered, the array may contain additional entries. The objects in the array are organized in the order in which they occurred. Therefore, the most recent location update is at the end of the array.
         */
        
        guard let location = locations.last
            else { assertionFailure("Array always contains at least one object representing the current location."); return }
        
        self.locationManager?.accessQueue.async { [weak self] in
            self?.locationManager?.location = Location(location)
        }
    }
    
    @objc
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // check for pending operations
        self.locationManager?.accessQueue.sync { [weak self] in
            
            // return error when starting updating locations
            if let semaphore = self?.locationManager?.internalState.start.semaphore {
                
                semaphore.stopWaiting(error) // throw error
                self?.locationManager?.internalState.start.semaphore = nil // stop waiting
            }
        }
    }
}

internal extension Location {
    
    init(_ location: CLLocation) {
        
        self.init(coordinate: Coordinate(location.coordinate))
    }
}

internal extension LocationCoordinate {
    
    init(_ location: CLLocationCoordinate2D) {
        
        self.init(latitude: location.latitude, longitude: location.longitude)
    }
}

// MARK: - Supporting Types

public enum DarwinLocationError: Error {
    
    case timeout
}

internal extension DarwinLocationManager {
    
    struct InternalState {
        
        fileprivate init() { }
        
        struct Start {
            
            var semaphore: Semaphore?
        }
        
        var start = Start()
    }
    
    enum Operation {
        
        case startUpdatingLocation
    }
    
    final class Semaphore {
        
        let operation: Operation
        let semaphore: DispatchSemaphore
        let timeout: TimeInterval
        var error: Swift.Error?
        
        init(timeout: TimeInterval,
             operation: Operation) {
            
            self.operation = operation
            self.timeout = timeout
            self.semaphore = DispatchSemaphore(value: 0)
            self.error = nil
        }
        
        func wait() throws {
            
            let dispatchTime: DispatchTime = .now() + timeout
            
            let success = semaphore.wait(timeout: dispatchTime) == .success
            
            if let error = self.error {
                
                throw error
            }
            
            guard success else { throw DarwinLocationError.timeout }
        }
        
        func stopWaiting(_ error: Swift.Error? = nil) {
            
            // store signal
            self.error = error
            
            // stop blocking
            semaphore.signal()
        }
    }
}

//#endif
