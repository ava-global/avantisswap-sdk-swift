//
//  DataExtensions.swift
//  
//
//  Created by Peerasak Unsakon on 14/9/2565 BE.
//

import Foundation
import keccaktiny

extension Data {
    init?(hex: String) {
        if let byteArray = try? hex.noHexPrefix.byteArray {
            self.init(bytes: byteArray, count: byteArray.count)
        } else {
            return nil
        }
    }
    
    var hexString: String {
        let bytes = Array<UInt8>(self)
        return "0x" + bytes.map { String(format: "%02hhx", $0) }.joined()
    }
    
    var keccak256: Data {
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
        defer {
            result.deallocate()
        }
        let nsData = self as NSData
        let input = nsData.bytes.bindMemory(to: UInt8.self,
                                            capacity: self.count)
        keccak_256(result, 32, input, self.count)
        return Data(bytes: result, count: 32)
    }
}
