//
//  MonitorsVC.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 01/07/2018.
//  Copyright (c) 2018 Leandro Perez. All rights reserved.
//

import UIKit
import RxSwift
import RxHeartRateMonitors


class MonitorsVC: UIViewController {

    @IBOutlet weak var table : UITableView!
    @IBOutlet weak var stateLabel : UILabel!
    
    let disposeBag = DisposeBag()

    var central : HeartRateMonitorCentral!
    
    //MARK: - lifecycle
    
    func setup(central: HeartRateMonitorCentral){
        self.central = central
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(self.table != nil)
        assert(self.central != nil)
        
        self.bindBluetoothState()
        self.bindMonitors()
    }
    
    //MARK: - private
    
    private func bindBluetoothState(){
        self.central.state
            .map{"Bluetooth is \($0.isOn ? "ON" : "OFF")"}
            .asDriver(onErrorDriveWith: .never())
            .drive(self.stateLabel.rx.text)
            .disposed(by: self.disposeBag)
    }
   
    private func bindMonitors(){
        
        let cellProvider : CellProvider<HeartRateMonitorCell> = CellProvider()
        cellProvider.registerCell(for: self.table, automaticRowHeight: true)
        
        self.central.monitors
            .debug("monitors")
            .bind(to: self.table.rx.items) { (table, row, heartRateMonitor) in
                let cell = cellProvider.cell(for: table, at: row)
                cell.setup(with: heartRateMonitor)
                return cell
            }
            .disposed(by: self.disposeBag)
        
        self.table.rx
            .modelSelected(HeartRateMonitor.self)
            .subscribeNext(weak: self, MonitorsVC.openDetails)
            .disposed(by: self.disposeBag)
    }
    
  
    
    private func openDetails(of monitor:HeartRateMonitor){
    
        let details : HeartRateMonitorVC = Storyboards.heartRateMonitorVC.initialViewController()
        details.setup(withCentral: self.central, heartRateMonitor: monitor)
        
        self.navigationController?.pushViewController(details, animated: true)
    }
}

