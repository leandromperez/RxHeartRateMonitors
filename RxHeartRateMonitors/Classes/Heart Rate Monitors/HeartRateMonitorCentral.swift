//
//  HeartRateCentral.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 12/5/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import RxBluetoothKit
import RxSwift
import CoreBluetooth
import SwiftyUserDefaults

public class HeartRateMonitorCentral : NSObject{
    
    private let central = BluetoothCentral()
    
    //MARK: - private
    private var requiredServices : [CBUUID] {
        return HeartRateMonitorCentral.PeripheralType.requiredServicesIds
    }
}

extension HeartRateMonitorCentral : SpecifiedBluetoothCentral{
    
    
    public typealias PeripheralType = HeartRateMonitor
    
    //MARK: - public
    public var state: Observable<BluetoothState>{
        return self.central.state
    }
    
    private func createHeartRateMonitor(from peripheral:Peripheral) -> Observable<HeartRateMonitor>{
        return .just(HeartRateMonitor(peripheral: peripheral, central: self))
    }
    
    public func connectedPeripherals() -> Observable<HeartRateMonitor> {
        
        return self.central
            .connectedPeripherals(withServices: self.requiredServices)
            .flatMap(weak: self, HeartRateMonitorCentral.createHeartRateMonitor)
    }
    
    public func scanPeripherals() -> Observable<HeartRateMonitor> {
        let alreadyConnected = self.central.connectedPeripheralsWithSavedFirst(withServices:self.requiredServices)
            .flatMap(weak: self, HeartRateMonitorCentral.createHeartRateMonitor)
        
        let newOnes = self.central.scanPeripherals(withServices: self.requiredServices)
            .flatMap(weak: self, HeartRateMonitorCentral.createHeartRateMonitor)
        
        return Observable.of(alreadyConnected,newOnes).merge()
    }
    
    public func connectToFirstAvailablePeripheral() -> Observable<HeartRateMonitor> {
        return self.central.previouslyConnectedDevices(withServices: self.requiredServices)
            .flatMap(weak: self, HeartRateMonitorCentral.createHeartRateMonitor)
            .take(1)
    }
    
    public func whenOnlineConnectToFirstAvailablePeripheral() -> Observable<HeartRateMonitor> {
        
        let state = self.central.state
        
        return state
            .filter{$0.isOn}
            .flatMap(weak:self){me, _  in
                me.connectToFirstAvailablePeripheral().materialize()}
            .elements()
            .debug("Connected monitor")
    }
            
    public func connect() -> Observable<BluetoothState> {
        return self.central.connect()
    }
    
    public func save(peripheral: HeartRateMonitor) {
        self.central.save(peripheralUUID:peripheral.uuid)
    }
  
}

