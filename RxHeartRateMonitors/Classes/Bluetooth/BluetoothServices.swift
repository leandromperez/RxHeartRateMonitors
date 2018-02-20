//
//  BluetoothServices.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 12/21/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxBluetoothKit

public enum BluetoothServices: UInt16, ServiceIdentifier {
    
    case deviceInformation  = 0x180A
    case heartRateMonitor   = 0x180D
    
    public var uuid: CBUUID {
        return CBUUID(string: String(self.rawValue, radix: 16, uppercase: true))
    }
}
