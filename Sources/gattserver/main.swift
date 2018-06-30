//
//  main.swift
//  gattserver
//
//  Created by Alsey Coleman Miller on 6/29/18.
//
//

import Foundation
import Bluetooth
import GATT

#if os(Linux)
import BluetoothLinux
#endif

func run(arguments: [String] = CommandLine.arguments) throws {
    
    //  first argument is always the current directory
    let arguments = Array(arguments.dropFirst())
    
    #if os(Linux)
    guard let controller = HostController
        else { throw CommandError.bluetoothUnavailible }
        
    print("Bluetooth Controller: \(controller.address)")
    #endif
    
    let peripheral = PeripheralManager()
    peripheral.log = { print("PeripheralManager:", $0) }
    
    #if os(macOS)
    while peripheral.state != .poweredOn { sleep(1) }
    #endif
    
    let controller = try GATTBatteryServiceController(peripheral: peripheral)
    
    //let command = try Command(arguments: arguments)
    
    //try command.execute(controller: controller)
    
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
