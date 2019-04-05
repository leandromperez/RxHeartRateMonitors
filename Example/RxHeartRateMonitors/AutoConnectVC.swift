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

        let monitor = central.connectToLastSavedMonitor().debug("got monitor 👩🏻‍🚀").share().debug("got replay 👩🏻‍🚀")

        monitor.flatMap{$0.monitoredState}
            .debug("state")
            .asDriver(onErrorJustReturn: .disconnected)
            .map{ $0.description }
            .drive(self.monitorStateLabel.rx.text)
            .disposed(by: disposeBag)

        monitor.map{$0.name}
            .asDriver(onErrorJustReturn: "Unknown device")
            .drive(self.monitorName.rx.text)
            .disposed(by: disposeBag)

        monitor.flatMap{ $0.monitoredHeartRate}
            .debug("HR inner w/ errors")
            .asDriver(onErrorJustReturn: 0)
            .debug("HR driver")
            .map{ $0.description }
            .drive(self.heartRateLabel.rx.text)
            .disposed(by: disposeBag)

    }

}
