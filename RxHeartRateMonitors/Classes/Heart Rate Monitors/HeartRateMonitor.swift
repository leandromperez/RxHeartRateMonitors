//
//  HeartRateMonitor.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 12/21/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import RxSwift
import RxBluetoothKit
import RxSwiftExt
import CoreBluetooth
import RxCocoa

public struct HeartRateMonitor {
    
    private weak var central : HeartRateMonitorCentral!
    private var peripheral : Peripheral
    
    init(peripheral:Peripheral, central: HeartRateMonitorCentral) {
        self.peripheral = peripheral
        self.central = central
    }
    
    public var heartRate: Observable<UInt> {
        return self.peripheral.heartRate
    }
}

extension HeartRateMonitor: BluetoothPeripheral{
    public var uuid: String{
        return self.peripheral.uuid
    }
    
    public var name: String?{
        return self.peripheral.name
    }
    
    public var state: BluetoothPeripheralState{
        return self.peripheral.state
    }
    
    public var monitoredState: Observable<BluetoothPeripheralState>{
        return self.peripheral.monitoredState
    }
    
    public func connect() -> Observable<BluetoothPeripheral> {
        self.central.save(peripheral:self)
        return self.peripheral.connect()
    }
    
    public func disconnect() -> Observable<BluetoothPeripheral> {
        return self.peripheral.disconnect()
    }
}

extension HeartRateMonitor{
    public static var requiredServicesIds : [CBUUID] {
        return [BluetoothServices.heartRateMonitor.uuid]
    }
}
