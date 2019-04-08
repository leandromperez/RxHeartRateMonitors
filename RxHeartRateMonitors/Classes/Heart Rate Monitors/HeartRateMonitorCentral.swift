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
import RxCocoa

public class HeartRateMonitorCentral : NSObject{

    private let central = BluetoothCentral()
    let autoconnectedMonitor = PublishSubject<HeartRateMonitor>()

    //MARK: - private
    private var requiredServices : [CBUUID] {
        return HeartRateMonitorCentral.PeripheralType.requiredServicesIds
    }

    func disconnect(peripheral: Peripheral) {
        self.central.disconnect(peripheral: peripheral)
    }
}

extension HeartRateMonitorCentral : SpecifiedBluetoothCentral{

    public typealias PeripheralType = HeartRateMonitor
    
    //MARK: - public
    public var peripherals : Observable<[HeartRateMonitor]> {

        return self.state
            .debug("central state")
            .filter{$0 == .poweredOn}
            .flatMap(weak: self){me,_ in me.scanPeripherals().materialize().debug("materialized scan")}
            .elements()
            .scan([], accumulator: appendMonitor)
            .distinctUntilChanged()
            .share()
    }
    
    public var state: Observable<BluetoothState>{
        return self.central.state
    }

    public func connect() -> Observable<BluetoothState> {
        return self.central.connect()
    }

    public func save(peripheral monitor: HeartRateMonitor) {
        self.central.save(peripheral:monitor.peripheral)
    }

    public func remove(peripheral monitor: HeartRateMonitor) {
        self.central.save(peripheral:monitor.peripheral)
    }

    public func hasSaved(peripheral: HeartRateMonitor) -> Bool {
        return self.central.has(saved: peripheral.peripheral)
    }

    public func connectToLastSavedMonitor() -> Observable<HeartRateMonitor> {

        let savedList = self.central.savedPeripheralUUIDs

        return self.peripherals
            .map{ monitors -> HeartRateMonitor? in
                return monitors.last{ savedList.contains($0.uuid) }
            }
            .noNils()
            .debug("found monitor 🐳")
            .flatMap(weak: self, HeartRateMonitorCentral.connect(monitor:))
    }

    private func connect(monitor: HeartRateMonitor) -> Observable<HeartRateMonitor> {
        let createMonitor : (Peripheral) -> HeartRateMonitor? = { [weak self] per in
            guard let central = self else {return nil}
            return HeartRateMonitor(peripheral: per, central: central)
        }

        if monitor.state == .disconnected {
            return monitor.connect()
                .map(createMonitor)
                .noNils()
                .filter{$0.state == .connected}
        } else {
            return .just(monitor)
        }
    }


    //MARK: - private

    private func createHeartRateMonitor(from peripheral:Peripheral) -> Observable<HeartRateMonitor>{
        return .just(HeartRateMonitor(peripheral: peripheral, central: self))
    }

    private func scanPeripherals() -> Observable<HeartRateMonitor> {

        let alreadyConnected = self.central.connectedPeripheralsWithSavedFirst(withServices:self.requiredServices)
            .flatMap(weak: self, HeartRateMonitorCentral.createHeartRateMonitor)


        let newOnes = self.central.scanPeripherals(withServices: self.requiredServices)
            .flatMap(weak: self, HeartRateMonitorCentral.createHeartRateMonitor)

        return Observable.of(alreadyConnected,newOnes).merge()
    }

}

private func appendMonitor(to accumulated:[HeartRateMonitor], newMonitor:HeartRateMonitor) -> [HeartRateMonitor]{
    var result = accumulated
    if !accumulated.contains(where: { $0.uuid == newMonitor.uuid}){
        result.append(newMonitor)
    }
    return result
}
