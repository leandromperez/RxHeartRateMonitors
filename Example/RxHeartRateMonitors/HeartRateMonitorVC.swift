//
//  HeartRateMonitorVC.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 12/13/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt
import RxHeartRateMonitors
import RxCocoa

final class HeartRateMonitorVC: UIViewController{
    private var hrDisposeBag = DisposeBag()
    private let disposeBag = DisposeBag()
    
    private var central : HeartRateMonitorCentral!
    private var heartRateMonitor : HeartRateMonitor!
    
    func setup(withCentral central : HeartRateMonitorCentral, heartRateMonitor : HeartRateMonitor) {
        self.central = central
        self.heartRateMonitor = heartRateMonitor
    }

    //MARK: - Outlets
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var stateLabel : UILabel!
    @IBOutlet weak var connectButton : UIButton!
    @IBOutlet weak var heartRateLabel : UILabel!
    
    //MARK: - Binding
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(self.nameLabel != nil)
        assert(self.stateLabel != nil)
        assert(self.connectButton != nil)
        assert(self.heartRateLabel != nil)
        assert(self.central != nil)
        assert(self.heartRateMonitor != nil)
        
        self.bindHeartRate()
        self.bindState()
        self.bindConnectButton()
        self.bindName()
    }
    
    private func toogleConnection(dependingOn state:BluetoothPeripheralState) -> Observable<BluetoothPeripheral>{
        if state != .connected{
            return self.heartRateMonitor.connect()
        }
        else{
            return self.heartRateMonitor.disconnect()
        }
    }
    
    private func bindState(){
        let state = self.heartRateMonitor
            .monitoredState
            .asDriver(onErrorJustReturn: .disconnected)
        
        state
            .map{$0.description}
            .debug()
            .drive(self.stateLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        state
            .map{ s in
                switch s {
                case .disconnected :
                    return "Connect"
                case .connected :
                    return "Disconnect"
                default:
                    return "Working"
                }
            }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.connectButton.rx.title())
            .disposed(by: self.disposeBag)
        
        state
            .map{ s in
                switch s {
                case .disconnected, .connected :
                    return true
                    
                default:
                    return false
                }
            }
            .drive(self.connectButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        state.asObservable()
            .distinctUntilChanged()
            .subscribeNext(weak: self, HeartRateMonitorVC.reconnectHeartRate)
            .disposed(by: self.disposeBag)
    }
    
    private func reconnectHeartRate(_ state : BluetoothPeripheralState){
        if state == .connected{
            self.bindHeartRate()
        }
    }
    
    private func bindHeartRate(){
        
        self.hrDisposeBag = DisposeBag()
    
        self.heartRateMonitor.heartRate
            .map{$0.description}
            .asDriver(onErrorJustReturn: "N/A")
            .drive(self.heartRateLabel.rx.text)
            .disposed(by: self.hrDisposeBag)
    }
    
    private func bindName(){
        
        Driver.from(optional: self.heartRateMonitor.name)
            .startWith("Unknown device")
            .drive(self.nameLabel.rx.text)
            .disposed(by: self.disposeBag)
    }
    
    private func bindConnectButton(){
        let state = self.heartRateMonitor.monitoredState.startWith(.disconnected)
        
        self.connectButton.rx.tap
            .asObservable()
            .debounce(0.5, scheduler:MainScheduler.instance)
            .withLatestFrom(state)
            .flatMapLatest{[unowned self] state in
                self.toogleConnection(dependingOn: state)
                    .materialize()
            }
            .asObservable()
            .publish().connect()
            .disposed(by: disposeBag)
    }
}


