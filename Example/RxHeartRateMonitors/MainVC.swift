//
//  MainVC.swift
//  RxHeartRateMonitors_Example
//
//  Created by Leandro Perez on 18/01/2018.
//  Copyright © 2018 Leandro Perez. All rights reserved.
//

import UIKit
import RxHeartRateMonitors

class MainVC: UIViewController {

    let central = HeartRateMonitorCentral()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func openMonitors(){
        let monitorsVC : MonitorsVC = R.storyboard.monitorsVC().initialViewController()
        monitorsVC.setup(central: self.central)
        self.navigationController?.pushViewController(monitorsVC, animated: true)
    }
    
    @IBAction func openAutoConnect(){
        let autoConnectVC : AutoConnectVC = R.storyboard.autoConnectVC().initialViewController()
        autoConnectVC.setup(central: self.central)
        self.navigationController?.pushViewController(autoConnectVC, animated: true)
    }
}

