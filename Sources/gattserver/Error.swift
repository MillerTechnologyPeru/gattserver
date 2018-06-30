//
//  Error.swift
//  gattserver
//
//  Created by Alsey Coleman Miller on 6/29/18.
//
//

public enum CommandError: Error {
    
    /// Bluetooth controllers not availible.
    case bluetoothUnavailible
    
    /// No command specified.
    case noCommand
    
    /// Invalid command.
    case invalidCommandType(String)
    
    case invalidOption(String)
    
    case missingOption(String)
    
    case optionMissingValue(String)
    
    case invalidOptionValue(option: String, value: String)
}
