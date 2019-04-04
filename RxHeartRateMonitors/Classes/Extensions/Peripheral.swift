//
//  Peripheral.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 12/21/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import RxBluetoothKit
import RxSwift
import CoreBluetooth

extension Peripheral : BluetoothPeripheral {
    
    public var uuid: String {
        return self.identifier.uuidString
    }
    
    public var monitoredState: Observable<BluetoothPeripheralState> {
        return self.observeConnection().map{$0  ? .connected : .disconnected}
    }
    
    public var state: BluetoothPeripheralState {
        return BluetoothPeripheralState(cbPeripheralState: self.peripheral.state)
    }
    
    public func connect() -> Observable<BluetoothPeripheral> {
        let connection : Observable<Peripheral> = self.establishConnection()
        return connection.map{$0}
    }
    
    public func disconnect() {
        self.manager.centralManager.cancelPeripheralConnection(self.peripheral)
    }
    
    public var heartRate: Observable<UInt>{
        
        return self.observeValueUpdateAndSetNotification(for: BluetoothCharacteristics.heartRateMeasurement)
            .map { $0.value }
            .flatMap { Observable.from(optional: $0) }
            .map {$0.heartRateValue()}
    }
}


