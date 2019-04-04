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
//    var heartRateMonitorRelay : BehaviorRelay<HeartRateMonitor?> = BehaviorRelay<HeartRateMonitor?>(value: nil)

//    var heartRateMonitor : Driver<HeartRateMonitor> {
//        return heartRateMonitorRelay.asDriver().noNils().debug("🧐").distinctUntilChanged().debug("🚵🏽‍♀️")
//    }

    var heartRateMonitor : HeartRateMonitor! {
        didSet {
            self.bindHeartRateMonitor()
        }
    }

    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var stateLabel : UILabel!
    @IBOutlet weak var bluetoothStateLabel : UILabel!
    @IBOutlet weak var heartRateLabel : UILabel!

    //MARK: - lifecycle
    
    func setup(central: HeartRateMonitorCentral){
        self.central = central
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindBluetoothState()
        scanMonitors()
    }
    
    //MARK: - private
    
    private func bindBluetoothState(){
        self.central.state.materialize().elements()
            .map{"Bluetooth is \($0.isOn ? "ON" : "OFF")"}
            .asDriver(onErrorDriveWith: .never())
            .drive(self.bluetoothStateLabel.rx.text)
            .disposed(by: self.disposeBag)
    }

    func bindHeartRateMonitor(){
        self.nameLabel.text = heartRateMonitor.name
        self.bindState()
        self.connectWhenOnline()
    }

    private func connectWhenOnline() {

        central.state.startWith(.poweredOff)
            .debug("🥊")
            .ignoreErrors()
            .debug("🍀")
            .filter{$0.isOn}
            .debug("🐳")
            .subscribe(onNext: { _ in
                self.connect()
            })
            .disposed(by: hrDisposeBag)
    }

    func connect() {
        if self.heartRateMonitor.state != .connected {
            self.heartRateMonitor.connect().debug("📱").subscribe().disposed(by: disposeBag)
        }
    }

    private func bindState(){
        let state = self.heartRateMonitor
            .monitoredState.startWith(.disconnected)
            .debug("🖼")
            .asDriver(onErrorJustReturn: .disconnected)

        state
            .map{$0.description}
            .debug("😝")
            .drive(self.stateLabel.rx.text)
            .disposed(by: self.disposeBag)

        state.asObservable()
            .distinctUntilChanged()
            .subscribeNext(weak: self, AutoConnectVC.reconnectHeartRate)
            .disposed(by: self.disposeBag)
    }

    private func reconnectHeartRate(_ state : BluetoothPeripheralState){
        if state == .connected {
            self.bindHeartRate()
        }
    }

    var hrDisposeBag = DisposeBag()

    private func bindHeartRate(){

        self.hrDisposeBag = DisposeBag()

        heartRateMonitor.heartRate.debug("💛").asDriver(onErrorJustReturn: 0).debug("💙")
            .debug("❤️")
            .map{$0.description}
            .debug("💚")
            .drive(self.heartRateLabel.rx.text)
            .disposed(by: hrDisposeBag)
    }


//    private func bindHeartRateMonitor(){
//        self.heartRateMonitor.map{ $0.name}.drive(self.nameLabel.rx.text).disposed(by: disposeBag)
//
//        heartRateMonitor
//            .flatMap{ $0.monitoredState.asDriver(onErrorJustReturn: .disconnected) }
//            .map{$0.description}
//            .debug()
//            .drive(self.stateLabel.rx.text)
//            .disposed(by: self.disposeBag)
//
//        heartRateMonitor
//            .flatMap{ $0.heartRate.map{$0.description}.asDriver(onErrorJustReturn: "N/A") }
//            .drive(self.heartRateLabel.rx.text)
//            .disposed(by: self.disposeBag)
//    }

    private func scanMonitors() {
        central.state.debug("😅").subscribe().disposed(by: disposeBag)
        central.scanPeripherals()
            .debug("💣")
            .ignoreErrors()
            .debug("🥺")
            .bind(to: self.rx.autoconnectedMonitor)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base : AutoConnectVC {
    var autoconnectedMonitor : Binder<HeartRateMonitor> {
        return Binder(base) { vc, monitor in
            vc.heartRateMonitor = monitor
        }
    }
}

