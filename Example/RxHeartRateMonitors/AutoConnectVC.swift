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


    var heartRateMonitor : HeartRateMonitor!
    var monitorDisposeBag = DisposeBag()

    @IBOutlet weak var nameLabel : UILabel!
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
        let bag = monitorDisposeBag
        let autoconnectedMonitor : Observable<HeartRateMonitor> = central.monitors
            .debug("[🐳]")
            .map{ $0.first }
            .debug("1 🐳")
            .noNils()
            .debug("last 🐳")
            .distinctUntilChanged()
            .do(onNext: { monitor in
                if monitor.state == .disconnected {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        monitor.connect().debug("📡").subscribe().disposed(by: bag)
                    })
                }
            })
            .share()

        autoconnectedMonitor
            .flatMap{$0.monitoredState.debug("inner state")}
            .debug("state")
            .asDriver(onErrorJustReturn: .disconnected)
            .map{ $0.description }
            .drive(self.monitorStateLabel.rx.text)
            .disposed(by: disposeBag)

        autoconnectedMonitor
            .debug("Monitor")
            .flatMap{$0.monitoredHeartRate.debug("HR inner w/ errors")}
            .debug("HR outer")
//            .subscribe()
            .asDriver(onErrorJustReturn: 0)
            .debug("HR driver")
            .map{ $0.description }
            .drive(self.heartRateLabel.rx.text)
            .disposed(by: disposeBag)
    }

//    //MARK: - autoconnected monitor
//
//    func bindHeartRateMonitor(){
//        monitorDisposeBag = DisposeBag()
//        self.nameLabel.text = heartRateMonitor.name
//        self.bindMonitorState()
//        self.connectToMonitorWhenBluetoothIsOn()
//    }
//
//    private func connectToMonitorWhenBluetoothIsOn() {
//        self.bluetoothState.asObservable()
//            .debug("🥊")
//            .filter{$0.isOn}
//            .debug("🐳")
//            .subscribe(onNext:{[unowned self] _ in
//                self.connect()
//            })
//            .disposed(by: monitorDisposeBag)
//    }
//
//    func connect() {
//        if self.heartRateMonitor.state != .connected {
//            self.heartRateMonitor.connect().debug("🕹").subscribe().disposed(by: monitorDisposeBag)
//        }
//    }
//
//    private func bindMonitorState(){
//        let state = self.heartRateMonitor
//            .monitoredState.startWith(.disconnected)
//            .debug("🖼")
//            .asDriver(onErrorJustReturn: .disconnected)
//
//        state
//            .map{$0.description}
//            .debug("😝")
//            .drive(self.monitorStateLabel.rx.text)
//            .disposed(by: self.monitorDisposeBag)
//
//        state.asObservable()
//            .distinctUntilChanged()
//            .subscribeNext(weak: self, AutoConnectVC.reconnectHeartRate)
//            .disposed(by: self.monitorDisposeBag)
//    }
//
//    private func reconnectHeartRate(_ state : BluetoothPeripheralState){
//        if state == .connected {
//            self.bindHeartRate()
//        }
//    }
//
//
//    private func bindHeartRate(){
//
//        self.monitorDisposeBag = DisposeBag()
//
//        heartRateMonitor.heartRate.debug("💛").asDriver(onErrorJustReturn: 0).debug("💙")
//            .debug("❤️")
//            .map{$0.description}
//            .debug("💚")
//            .drive(self.heartRateLabel.rx.text)
//            .disposed(by: monitorDisposeBag)
//    }
//
//
//    private func set(monitor: HeartRateMonitor) {
//        self.heartRateMonitor = monitor
//        self.bindHeartRateMonitor()
//    }
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
}
//
//extension Reactive where Base : AutoConnectVC {
//    var autoconnectedMonitors : Binder<[HeartRateMonitor]> {
//        return Binder(base) { vc, monitors in
//            print("received monitors \( monitors )")
//            guard let newMonitor = monitors.last else {return}
//            guard vc.heartRateMonitor == nil else {return}
//            vc.heartRateMonitor = newMonitor
//            vc.bindHeartRateMonitor()
//        }
//    }
//}
//
