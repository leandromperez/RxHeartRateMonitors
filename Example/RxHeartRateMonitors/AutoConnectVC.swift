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
    
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var bluetoothStateLabel : UILabel!
    @IBOutlet weak var heartRateLabel : UILabel!

    //MARK: - lifecycle
    
    func setup(central: HeartRateMonitorCentral){
        self.central = central
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bindBluetoothState()
        self.bindAutoConnectedMonitor()
    }
    
    //MARK: - private
    
    private func bindBluetoothState(){
        self.central.state
            .map{"Bluetooth is \($0.isOn ? "ON" : "OFF")"}
            .asDriver(onErrorDriveWith: .never())
            .drive(self.bluetoothStateLabel.rx.text)
            .disposed(by: self.disposeBag)
    }

    private func bindAutoConnectedMonitor(){
        //Name
        let monitor : Observable<HeartRateMonitor> = self.central.whenOnlineConnectToFirstAvailablePeripheral()
//            .debug("A")
//            .flatMap{ $0.connect().materialize().debug("mm").elements().map{$0 as! HeartRateMonitor} }
//            .debug("B")
//            .debug("B")
//            .map{$0 as? HeartRateMonitor}
//            .debug("C")
//            .noNils()
//            .debug("D")
//            .share()
//            .debug("Auto connected monitor")

        
        monitor.map{$0.name}
            .asDriver(onErrorJustReturn: "No device connected")
            .drive(self.nameLabel.rx.text)
            .disposed(by: self.disposeBag)

        //Heart Rate depending on BT state
        let heartRate : Driver<UInt> = monitor.flatMap{$0.heartRate.debug("❤️")}
            .catchErrorAndRetry {_ in } //When disconnected it generates an error that terminates the stream
            .asDriver(onErrorJustReturn: 0)
            .debug("Heart Rate Driver")

        let bluetoothState : Driver<BluetoothState> = self.central.state.asDriver(onErrorJustReturn: .poweredOff)

        let heartRateConsideringState = Driver.combineLatest(bluetoothState, heartRate){  state, hr -> UInt in
            print(state)
            print(hr)
            if state.isOn {
                return hr
            }
            return 0
        }

        heartRateConsideringState
            .debug("Heart rate considering state")
            .map{"\($0) bpm"}
            .drive(self.heartRateLabel.rx.text)
            .disposed(by: self.disposeBag)
    }

}

