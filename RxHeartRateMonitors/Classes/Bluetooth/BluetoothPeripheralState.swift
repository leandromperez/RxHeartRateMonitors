//
//  BluetoothPerilpheralState.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 12/21/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import CoreBluetooth

public enum BluetoothPeripheralState: String {
    case connected
    case disconnected
    case connecting
    case disconnecting
    
    var isConnected : Bool {
        switch self{
        case .connected:
            return true
        default:
            return false
        }
    }
}

extension BluetoothPeripheralState : CustomStringConvertible{
    public var description: String {
        return self.rawValue.capitalizingFirstLetter()
    }
}

public extension BluetoothPeripheralState {
    init(cbPeripheralState:CBPeripheralState) {
        switch cbPeripheralState {
        case .connected:
            self = BluetoothPeripheralState.connected
        case .disconnected:
            self =  BluetoothPeripheralState.disconnected
        case .disconnecting:
            self = BluetoothPeripheralState.disconnecting
        case .connecting:
            self = BluetoothPeripheralState.connecting
        }
    }
}
