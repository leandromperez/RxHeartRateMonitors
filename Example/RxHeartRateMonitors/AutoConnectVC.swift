//
//  AutoConnectVC.swift
//  RxHeartRateMonitors_Example
//
//  Created by Leandro Perez on 18/01/2018.
//  Copyright © 2018 Leandro Perez. All rights reserved.
//

import UIKit
import RxSwift
import RxSwiftExt
import RxHeartRateMonitors
import RxCocoa
import RxBluetoothKit

class AutoConnectVC: UIViewController {

    var central : HeartRateMonitorCentral!
    let disposeBag = DisposeBag()

    var heartRateMonitor : HeartRateMonitor?
    var monitorDisposeBag = DisposeBag()

    @IBOutlet weak var monitorName : UILabel!
    @IBOutlet weak var monitorStateLabel : UILabel!
    @IBOutlet weak var bluetoothStateLabel : UILabel!
    @IBOutlet weak var heartRateLabel : UILabel!

    //MARK: - lifecycle
    
    func setup(central: HeartRateMonitorCentral){
        self.central = central
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindBluetoothState()
        bindAutoconnectedMonitor()
    }


    //MARK: - private

    private var bluetoothState : Driver<BluetoothState> {
        return self.central.state.asDriver(onErrorJustReturn: .poweredOff)
    }

    private func bindBluetoothState(){
        bluetoothState
            .map{"Bluetooth is \($0.isOn ? "ON" : "OFF")"}
            .drive(self.bluetoothStateLabel.rx.text)
            .disposed(by: self.disposeBag)
    }

    private func bindAutoconnectedMonitor() {
        guard let central = self.central else {fatalError()}

        let bag = monitorDisposeBag

        let createMonitor : (Peripheral) -> HeartRateMonitor = { [unowned central] per in
            return HeartRateMonitor(peripheral: per, central: central)
        }

        let connectedMonitor = self.rx.autoconnectedMonitor
        let autoconnectedMonitor : Observable<HeartRateMonitor> = central.monitors
            .debug("[🐳]")
            .map{ $0.first }
            .debug("1 🐳")
            .noNils()
            .debug("last 🐳")
            .do(onNext: { monitor in
//                if monitor.state == .disconnected {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        monitor.connect()
                            .debug("📡")
                            .map(createMonitor)
                            .asDriver(onErrorDriveWith: .never())
                            .filter{$0.state == .connected}
                            .drive(connectedMonitor)
                            .disposed(by: bag)
                    })
//                }
            })
            .share()

        autoconnectedMonitor
            .debug("name")
            .map{$0.name}
            .asDriver(onErrorJustReturn: "Unknown device")
            .drive(self.monitorName.rx.text)
            .disposed(by: disposeBag)

        autoconnectedMonitor
            .flatMap{$0.monitoredState.debug("inner state")}
            .debug("state")
            .asDriver(onErrorJustReturn: .disconnected)
            .map{ $0.description }
            .drive(self.monitorStateLabel.rx.text)
            .disposed(by: disposeBag)
    }

    func observeName() {
        guard let monitor = heartRateMonitor else {fatalError()}
        guard monitor.state == .connected else {fatalError()}

        self.monitorName.text =  monitor.name
    }

    func observeHeartRate() {
        guard let monitor = heartRateMonitor else {fatalError()}
        guard monitor.state == .connected else {fatalError()}

        monitor.monitoredHeartRate
            .debug("HR inner w/ errors")
            .asDriver(onErrorJustReturn: 0)
            .debug("HR driver")
            .map{ $0.description }
            .drive(self.heartRateLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base : AutoConnectVC {
    var autoconnectedMonitor : Binder<HeartRateMonitor> {
        return Binder(base) { vc, monitor in
            print("received monitor \( monitor )")
            guard vc.heartRateMonitor == nil else {return}
            vc.heartRateMonitor = monitor
            vc.observeHeartRate()
            vc.observeName()
        }
    }
}

