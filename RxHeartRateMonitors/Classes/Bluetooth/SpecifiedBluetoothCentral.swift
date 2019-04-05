//
//  Bluetooth.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 12/1/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import RxSwift
import RxBluetoothKit

public protocol SpecifiedBluetoothCentral{
    associatedtype PeripheralType where PeripheralType : BluetoothPeripheral
    
    var state : Observable<BluetoothState> {get}
    
//    func connectedPeripherals() -> Observable<PeripheralType>
//    func scanPeripherals() -> Observable<PeripheralType>
//    func connectToFirstAvailablePeripheral() -> Observable<PeripheralType>

    func connect() -> Observable<BluetoothState>
    
    func save(peripheral:PeripheralType)
}

