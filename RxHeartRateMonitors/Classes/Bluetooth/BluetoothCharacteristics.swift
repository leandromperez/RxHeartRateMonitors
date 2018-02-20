//
//  BluetoothCharacteristics.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 12/21/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import RxBluetoothKit
import CoreBluetooth

public enum BluetoothCharacteristics : UInt16, CharacteristicIdentifier {
    
    case deviceName             = 0x2A00
    case manufacturersName      = 0x2A29
    case heartRateMeasurement   = 0x2A37
    case sensorLocation         = 0x2A38

    public var uuid: CBUUID {
        return CBUUID(string: String(self.rawValue, radix: 16, uppercase: true))
    }
    
    public var service: ServiceIdentifier{
        switch self {
        case .deviceName:
            return BluetoothServices.deviceInformation
        case .manufacturersName:
            return BluetoothServices.deviceInformation
        case .heartRateMeasurement:
            return BluetoothServices.heartRateMonitor
        case .sensorLocation:
            return BluetoothServices.heartRateMonitor
        }
    }
}
