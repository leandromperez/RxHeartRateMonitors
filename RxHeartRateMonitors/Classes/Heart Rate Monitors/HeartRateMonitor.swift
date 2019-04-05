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

public class HeartRateMonitor {
    
    private weak var central : HeartRateMonitorCentral!
    private var peripheral : Peripheral

    public init(peripheral:Peripheral, central: HeartRateMonitorCentral) {
        self.peripheral = peripheral
        self.central = central
    }
    
    public var monitoredHeartRate: Observable<UInt> {
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

    public func connect() -> Observable<Peripheral> {
        self.central.save(peripheral:self)
    
        return self.peripheral.establishConnection()
    }

    public func disconnect() {
        if self.peripheral.state == .connected {
            self.central.disconnect(peripheral: self.peripheral)
        }
    }
}

extension HeartRateMonitor{
    public static var requiredServicesIds : [CBUUID] {
        return [BluetoothServices.heartRateMonitor.uuid]
    }
}

extension HeartRateMonitor : CustomStringConvertible {
    public var description: String {
        return "HR: " + (self.name ?? "unknown")
    }
}
extension HeartRateMonitor : CustomDebugStringConvertible {
    public var debugDescription: String {
        return self.description
    }
}

extension HeartRateMonitor : Equatable {
    public static func == (lhs: HeartRateMonitor, rhs: HeartRateMonitor) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
