//
//  main.swift
//  gattserver
//
//  Created by Alsey Coleman Miller on 6/29/18.
//
//

import Foundation
import CoreFoundation
import Bluetooth
import GATT

#if os(Linux)
import BluetoothLinux
#endif

var serviceController: GATTServiceController?

func run(arguments: [String] = CommandLine.arguments) throws {
    
    //  first argument is always the current directory
    let arguments = Array(arguments.dropFirst())
    
    #if os(Linux)
    guard let controller = HostController.default
        else { throw CommandError.bluetoothUnavailible }
        
    print("Bluetooth Controller: \(controller.address)")
    
    //let beacon = AppleBeacon(uuid: UUID(), major: 0, minor: 0, rssi: -29)
        
    //let flags = GAPFlags(flags: [.lowEnergyGeneralDiscoverableMode])
        
    //try controller.iBeacon(beacon, flags: flags)
        
    let peripheral = PeripheralManager(controller: controller)
    #else
    let peripheral = PeripheralManager()
    #endif
    
    peripheral.log = { print("PeripheralManager:", $0) }
    
    #if os(macOS)
    while peripheral.state != .poweredOn { sleep(1) }
    #endif
    
    guard let serviceUUIDString = arguments.first
        else { throw CommandError.noCommand }
    
    guard let service = BluetoothUUID(rawValue: serviceUUIDString),
        let controllerType = serviceControllers.first(where: { $0.service == service })
        else { throw CommandError.invalidCommandType(serviceUUIDString) }
    
    serviceController = try controllerType.init(peripheral: peripheral)
    
    try peripheral.start()
    
    while true {
        #if os(Linux)
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.001, true)
        #elseif os(macOS)
            CFRunLoopRunInMode(.defaultMode, 0.001, true)
        #endif
    }
}

do { try run() }
    
catch {
    print("\(error)")
    exit(1)
}
