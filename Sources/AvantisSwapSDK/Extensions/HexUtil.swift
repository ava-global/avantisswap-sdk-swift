//
//  HexUtil.swift
//  
//
//  Created by Peerasak Unsakon on 14/9/2565 BE.
//

import Foundation

enum HexConversionError: Error {
    case invalidDigit
    case stringNotEven
}

class HexUtil {
    
    static func convert(hexDigit digit: UnicodeScalar) throws -> UInt8 {
        switch digit {
            
        case UnicodeScalar(unicodeScalarLiteral:"0")...UnicodeScalar(unicodeScalarLiteral:"9"):
            return UInt8(digit.value - UnicodeScalar(unicodeScalarLiteral:"0").value)
            
        case UnicodeScalar(unicodeScalarLiteral:"a")...UnicodeScalar(unicodeScalarLiteral:"f"):
            return UInt8(digit.value - UnicodeScalar(unicodeScalarLiteral:"a").value + 0xa)
            
        case UnicodeScalar(unicodeScalarLiteral:"A")...UnicodeScalar(unicodeScalarLiteral:"F"):
            return UInt8(digit.value - UnicodeScalar(unicodeScalarLiteral:"A").value + 0xa)
            
        default:
            throw HexConversionError.invalidDigit
        }
    }
    
}

