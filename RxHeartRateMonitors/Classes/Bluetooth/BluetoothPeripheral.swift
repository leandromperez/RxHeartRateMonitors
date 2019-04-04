//
//  BluetoothPeripheral.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 12/14/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import RxSwift
import CoreBluetooth
import RxCocoa

public protocol BluetoothPeripheral{
    static var requiredServicesIds : [CBUUID] {get}
    
    var uuid : String {get}
    var name : String? {get}
    
    var state : BluetoothPeripheralState {get}
    var monitoredState : Observable<BluetoothPeripheralState> {get}
}

extension BluetoothPeripheral{
    public static var requiredServicesIds: [CBUUID] {
        assertionFailure("Implement in concrete peripherals. See HeartRateMonitor for example")
        return []
    }
}
