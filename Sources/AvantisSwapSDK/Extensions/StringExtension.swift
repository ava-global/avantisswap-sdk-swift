//
//  StringExtensions.swift
//  
//
//  Created by Peerasak Unsakon on 14/9/2565 BE.
//

import Foundation

extension String {
    
    var noHexPrefix: String {
        if hasPrefix("0x") {
            let index = index(self.startIndex,
                              offsetBy: 2)
            return String(self[index...])
        }
        return self
    }
    
    var byteArray: [UInt8] {
        get throws {
            var iterator = self.unicodeScalars.makeIterator()
            var byteArray: [UInt8] = []
            while let msn = iterator.next() {
                if let lsn = iterator.next() {
                    do {
                        let convertedMsn = try HexUtil.convert(hexDigit: msn)
                        let convertedLsn = try HexUtil.convert(hexDigit: lsn)
                        byteArray += [ (convertedMsn << 4 | convertedLsn) ]
                    } catch {
                        throw error
                    }
                } else {
                    throw HexConversionError.stringNotEven
                }
            }
            
            return byteArray
        }
    }
    
    var hexData: Data? {
        let noHexPrefix = self.noHexPrefix
        
        if let bytes = try? noHexPrefix.byteArray {
            return Data(bytes)
        }

        return nil
    }
}
