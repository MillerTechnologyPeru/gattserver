//
//  GATTServiceController.swift
//  gattserver
//
//  Created by Alsey Coleman Miller on 6/30/18.
//
//

import Foundation
import Bluetooth
import GATT

public protocol GATTServiceController: class {
    
    static var service: BluetoothUUID { get }
    
    var peripheral: PeripheralManager { get }
    
    init(peripheral: PeripheralManager) throws
}

internal let serviceControllers: [GATTServiceController.Type] = [
    GATTBatteryServiceController.self,
    GATTDeviceInformationServiceController.self
]
