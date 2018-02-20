//
//  BluetoothCentral.swift
//  RxBluetoothKit
//
//  Created by Leandro Perez on 09/01/2018.
//

import Foundation
import RxBluetoothKit
import RxSwift
import CoreBluetooth
import SwiftyUserDefaults
import RxSwiftExt

final class BluetoothCentral : NSObject{
    
    private let disposeBag = DisposeBag()
    
    private let manager : BluetoothManager
    
    private var internalManager : CBCentralManager?
    
    private var restoredState : RestoredState? = nil
    
    //MARK: - lifecycle
    override init() {
        
        let restoreKey = CBCentralManagerOptionRestoreIdentifierKey
        let showAlertKey = CBCentralManagerOptionShowPowerAlertKey
        self.manager = BluetoothManager(queue: .main, options: [showAlertKey : false as AnyObject,
                                                                restoreKey : "rx.hr.monitors.identifiers" as AnyObject])
        
        super.init()
    }
    
    deinit {
        self.internalManager?.delegate = nil
    }
    
    //MARK: - public
    
    var state: Observable<BluetoothState> {
        
        return self.manager.rx_state
            .startWith(self.manager.state)
            .distinctUntilChanged()
    }
    
    func connectedPeripheralsWithSavedFirst(withServices services:[CBUUID]) -> Observable<Peripheral> {
        let saved = self.savedPeripheralUUIDs
        
        return self.manager
            .retrieveConnectedPeripherals(withServices: services )
            .map{ all -> [Peripheral] in
                let sorted = all.sorted(by: {a,b in saved.contains(a.uuid) ? true : false  } )
                return sorted
            }
            .flatMap{Observable.from($0)}
    }
    
    func connectedPeripherals(withServices services:[CBUUID]) -> Observable<Peripheral> {
        return self.connectedPeripheralsWithSavedFirst(withServices: services)
    }
    
    func scanPeripherals(withServices services: [CBUUID]) -> Observable<Peripheral> {
        return self.manager
            .scanForPeripherals(withServices: services)
            .map{$0.peripheral}
    }
    
    func connect() -> Observable<BluetoothState>{
        
        let showAlertKey = CBCentralManagerOptionShowPowerAlertKey
        
        //Hack: If i create another rx manager, the state will stop working, that's why I'm using this internal manager. Just creating it will prompt the user
        //It will not prompt if BT is enabled ON but not discoverable/enabled until tomorrow.
        self.internalManager?.delegate = nil
        self.internalManager = CBCentralManager(delegate: self, queue: DispatchQueue.main, options:  [showAlertKey : true as AnyObject])
        
        return self.state
    }
    
    func previouslyConnectedDevices(withServices services: [CBUUID]) -> Observable<Peripheral>{
        
        let alreadyConnected  : Observable<Peripheral>  = self.connectedPeripheralsWithSavedFirst(withServices: services)
        
        let saved = self.savedPeripheralUUIDs
        let newOnes : Observable<Peripheral> = self.manager.scanForPeripherals(withServices: services)
            .filter{saved.contains($0.peripheral.uuid)}
            .flatMap {$0.peripheral.connect().materialize()}
            .elements()
            .filter{$0.state.isConnected}
        
        return alreadyConnected.concat(newOnes)
    }
    
    func restoreState(){
        return self.manager.listenOnRestoredState()
            .subscribeNext(weak: self, BluetoothCentral.saveRestoredState)
            .disposed(by: self.disposeBag)
    }
    
    func save(peripheralUUID: String) {
        if(!self.savedPeripheralUUIDs.contains(peripheralUUID)){
            self.savedPeripheralUUIDs.append(peripheralUUID)
        }
    }
    
    //Mark: - private
    
    private var savedPeripheralUUIDs : [String] {
        get{
            return Defaults[.savedBluetoothDevicesIds]
        }
        set{
            Defaults[.savedBluetoothDevicesIds] = newValue
        }
    }

    private func remove(savedMonitor monitor: Peripheral) {
        if(self.savedPeripheralUUIDs.contains(monitor.uuid)){
            self.savedPeripheralUUIDs.remove(element:monitor.uuid)
        }
    }
    
    private func saveRestoredState(_ state : RestoredState){
        self.restoredState = state
    }
}

extension BluetoothCentral : CBCentralManagerDelegate{
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //Do nothing on purpose, just for the hack explained above
    }
}

extension DefaultsKeys {
    static let savedBluetoothDevicesIds =  DefaultsKey<[String]>("savedBluetoothDevicesIds")
}

