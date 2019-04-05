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

    private let disposeBag = DisposeBag()
    private let central = BluetoothCentral()
    private let autoconnectedMonitor = PublishRelay<HeartRateMonitor>()

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
    public var monitors : Observable<[HeartRateMonitor]> {
        return self.state
            .filter{$0 == .poweredOn}
            .flatMap(weak: self){me,_ in me.scanPeripherals().materialize()}
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

    public func save(peripheral: HeartRateMonitor) {
        self.central.save(peripheralUUID:peripheral.uuid)
    }

    public func has(saved monitor: HeartRateMonitor) -> Bool {
        return self.central.has(saved: monitor.uuid)
    }

    public func connectToLastSavedMonitor() -> Observable<HeartRateMonitor> {
        DispatchQueue.main.async {
            self.monitors
                .map{ $0.first }
                .noNils()
                .debug("[🐳]")
                .subscribeNext(weak: self, HeartRateMonitorCentral.connect(to:))
                .disposed(by: self.disposeBag)
        }

        return self.autoconnectedMonitor.asObservable()
    }

    func connect(to monitor:HeartRateMonitor) {

        let createMonitor : (Peripheral) -> HeartRateMonitor? = { [weak self] per in
            guard let central = self else {return nil}
            return HeartRateMonitor(peripheral: per, central: central)
        }

        let connectedMonitor = self.autoconnectedMonitor

        if monitor.state == .disconnected {
            monitor.connect()
                .debug("📡")
                .map(createMonitor)
//                .asDriver(onErrorRecover: { (error) -> SharedSequence<DriverSharingStrategy, HeartRateMonitor?> in
//                    connectedMonitor.onError(error)
//                    return .never()
//                })
                .noNils()
                .filter{$0.state == .connected}
                .bind(to: connectedMonitor)
//                .drive(connectedMonitor)
                .disposed(by: disposeBag)
        } else {
            connectedMonitor.accept(monitor)
        }
    }


    private func createHeartRateMonitor(from peripheral:Peripheral) -> Observable<HeartRateMonitor>{
        return .just(HeartRateMonitor(peripheral: peripheral, central: self))
    }
    
//    public func connectedPeripherals() -> Observable<HeartRateMonitor> {
//
//        return self.central
//            .connectedPeripherals(withServices: self.requiredServices)
//            .flatMap(weak: self, HeartRateMonitorCentral.createHeartRateMonitor)
//    }

    private func scanPeripherals() -> Observable<HeartRateMonitor> {
        let alreadyConnected = self.central.connectedPeripheralsWithSavedFirst(withServices:self.requiredServices)
            .flatMap(weak: self, HeartRateMonitorCentral.createHeartRateMonitor)

        let newOnes = self.central.scanPeripherals(withServices: self.requiredServices)
            .flatMap(weak: self, HeartRateMonitorCentral.createHeartRateMonitor)

        return Observable.of(alreadyConnected,newOnes).merge()
    }

//    public func connectToFirstAvailablePeripheral() -> Observable<HeartRateMonitor> {
//        return self.central.previouslyConnectedDevices(withServices: self.requiredServices)
//            .flatMap(weak: self, HeartRateMonitorCentral.createHeartRateMonitor)
//            .take(1)
//    }
//
//    public func whenOnlineConnectToFirstAvailablePeripheral() -> Observable<HeartRateMonitor> {
//
//        let state = self.central.state
//
//        return state
//            .filter{$0.isOn}
//            .flatMap(weak:self){me, _  in
//                me.connectToFirstAvailablePeripheral().materialize()}
//            .elements()
//            .debug("Connected monitor")
//    }



}

private func appendMonitor(to accumulated:[HeartRateMonitor], newMonitor:HeartRateMonitor) -> [HeartRateMonitor]{
    var result = accumulated
    if !accumulated.contains(where: { $0.uuid == newMonitor.uuid}){
        result.append(newMonitor)
    }
    return result
}
