//
//  UIStoryboard.swift
//  RxHeartRateMonitors_Example
//
//  Created by Leandro Perez on 30/01/2018.
//  Copyright © 2018 Leandro Perez. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard{
    func initialViewController<T : UIViewController> () -> T{
        return self.instantiateInitialViewController() as! T
    }
}
