//
//  Array.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 12/12/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation

extension Array{
    
    static func +(all:Array, element:Element) -> Array {
        var r = all
        r.append(element)
        return r
    }
    
    mutating func remove(where predicate:  ( Element) -> Bool) {
        self = self.filter{ !predicate($0)}
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `element`:
    mutating func remove(element: Element) {
        if let index = index(of: element) {
            remove(at: index)
        }
    }
}

