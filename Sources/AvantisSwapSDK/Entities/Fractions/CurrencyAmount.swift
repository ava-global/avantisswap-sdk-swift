//
//  CurrencyAmount.swift
//  PancakeSDK-swift
//
//  Created by IntrodexMac on 7/9/2565 BE.
//

import Foundation
import BigInt

public class CurrencyAmount: Fraction {
    
    public let currency: Currency
    
    var raw: BigUInt {
        return self.numerator
    }
    
    public init(currency: Currency,
                amount: BigUInt) {
        self.currency = currency
        
        super.init(numerator: amount,
                   denominator: BigUInt(10).power(Int(currency.decimals)))
    }
    
    func add(_ other: CurrencyAmount) throws -> CurrencyAmount {
        if self.currency.equalTo(other.currency) == false {
            throw CurrencyAmountError.notSameToken
        }
        
        return .init(currency: currency,
                     amount: self.raw + other.raw)
    }
    
    func subtract(_ other: CurrencyAmount) throws -> CurrencyAmount {
        if self.currency.equalTo(other.currency) == false {
            throw CurrencyAmountError.notSameToken
        }
        
        return .init(currency: currency,
                     amount: self.raw - other.raw)
    }
    
    public override func toSignificant(_ significantDigits: UInt = 6,
                                       rounding: NumberFormatter.RoundingMode? = .halfUp) throws -> String {
        return try super.toSignificant(significantDigits,
                                       rounding: rounding)
    }
    
    public override func toFixed(_ decimalPlaces: UInt? = nil,
                                 rounding: NumberFormatter.RoundingMode? = .halfUp) throws -> String {
        let decimalPlaces: UInt = decimalPlaces ?? currency.decimals
        return try super.toFixed(decimalPlaces,
                                 rounding: rounding)
    }
    
    public func toExact() -> String {
        return ""
    }
    
    public static func ether(amount: BigUInt) -> CurrencyAmount {
        return CurrencyAmount(currency: .ETHER,
                              amount: amount)
    }
}

enum CurrencyAmountError: Error,
                          LocalizedError {
    case notSameToken
    
    
    public var errorDescription: String? {
        switch self {
        case .notSameToken:
            return "TOKEN"
        }
    }
}
