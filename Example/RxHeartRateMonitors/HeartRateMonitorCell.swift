//
//  HeartRateMonitorCell.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 12/12/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxHeartRateMonitors
import RxSwiftExt

class HeartRateMonitorCell: UITableViewCell {

    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var statusLabel : UILabel!
    
    private var monitor : HeartRateMonitor!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        assert(self.nameLabel != nil)
        assert(self.statusLabel != nil)
    }
    
    func setup(with model:HeartRateMonitor){
        self.monitor = model
        self.nameLabel.text = model.name
        
        model.monitoredState
            .map{$0.description}
            .asDriver(onErrorJustReturn: "N/A")
            .drive(self.statusLabel.rx.text)
            .disposed(by: self.rx.disposeBag)
    }
    
  
}
