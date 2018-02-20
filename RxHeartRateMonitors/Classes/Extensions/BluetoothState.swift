//
//  BluetoothState.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 12/18/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import RxBluetoothKit

public extension BluetoothState{
    var isOn : Bool {
        switch self {
        case .poweredOn:
            return true
        default:
            return false
        }
    }
}

extension BluetoothState : CustomStringConvertible{
    public var description: String {
        switch self {
        case .poweredOn:
            return "PoweredOn"
        case .poweredOff:
            return "PoweredOff"
        case .resetting:
            return "Resetting"
        case .unauthorized:
            return "Unauthorized"
        case .unknown:
            return "Unknown"
        case .unsupported:
            return "Unsopported"
        }
    }
}

