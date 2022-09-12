//
//  Percent.swift
//  PancakeSDK-swift
//
//  Created by IntrodexMac on 7/9/2565 BE.
//

import Foundation
import BigInt

public class Percent: Fraction {
    
    public static let hundradPercent: Fraction = .init(numerator: BigUInt.hundred)
    
    public override func toSignificant(_ significantDigits: UInt = 5,
                                       rounding: NumberFormatter.RoundingMode? = .halfUp) throws -> String {
        return try self.multiply(Percent.hundradPercent).toSignificant(significantDigits,
                                                            rounding: rounding)
    }
    
    public override func toFixed(_ decimalPlaces: UInt = 2,
                                 rounding: NumberFormatter.RoundingMode? = .halfUp) throws -> String {
        return try self.multiply(Percent.hundradPercent).toFixed(decimalPlaces,
                                                                 rounding: rounding)
    }
    
}
