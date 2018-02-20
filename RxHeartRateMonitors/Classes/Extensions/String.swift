//
//  String+extensions.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 10/1/17.
//  Copyright © 2017 Leandro Manuel Perez. All rights reserved.
//

import Foundation

extension String {
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
