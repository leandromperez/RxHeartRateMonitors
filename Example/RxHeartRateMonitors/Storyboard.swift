//
//  Storyboard.swift
//  RxHeartRateMonitors_Example
//
//  Created by Leandro Perez on 4/4/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

public protocol Storyboard {
    func initialViewController<T : UIViewController> () -> T
    var name : String {get}
    var bundle : Bundle {get}
}

public extension Storyboard {
    var storyboard : UIStoryboard {
        return UIStoryboard.init(name: self.name.capitalizingFirstLetter(), bundle: self.bundle)
    }

    func initialViewController<T : UIViewController> () -> T {

        guard let vc : T = self.storyboard.instantiateInitialViewController() as? T else {fatalError()}

        return vc
    }
}

extension Storyboard where Self : RawRepresentable, Self.RawValue == String {

    public var name : String {
        return self.rawValue
    }

    public var bundle : Bundle {
        return Bundle.main
    }
}

public extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
}


enum Storyboards : String, Storyboard{
    case autoConnectVC
    case heartRateMonitorVC
    case monitorsVC
}
