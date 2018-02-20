//
//  Data + HeartRate.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 12/21/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation

extension Data {
    func heartRateValue() -> UInt{
        
        var buffer = [UInt8](repeating: 0x00, count: self.count)
        self.copyBytes(to: &buffer, count: buffer.count)
        
        var bpm:UInt16?
        if (buffer.count >= 2){
            if (buffer[0] & 0x01 == 0){
                bpm = UInt16(buffer[1]);
            }
            else {
                bpm = UInt16(buffer[1]) << 8
                bpm =  bpm! | UInt16(buffer[2])
            }
        }
        
        return bpm != nil ? UInt(bpm!) : 0
    }
}
