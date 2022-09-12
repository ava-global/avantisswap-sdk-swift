//
//  Price.swift
//  PancakeSDK-swift
//
//  Created by dAISY foto on 8/9/2565 BE.
//

import Foundation
import BigInt

public class Price: Fraction {
    public let baseCurrency: Currency
    public let quoteCurrency: Currency
    public let scalar: Fraction
    
    public init(baseCurrency: Currency,
                quoteCurrency: Currency,
                denominator: BigUInt,
                numerator: BigUInt) {
        self.baseCurrency = baseCurrency
        self.quoteCurrency = quoteCurrency
        self.scalar = Fraction(numerator: BigUInt.ten.power(Int(baseCurrency.decimals)),
                               denominator: BigUInt.ten.power(Int(quoteCurrency.decimals)))
        
        super.init(numerator: numerator,
                   denominator: denominator)
    }
    
    public var raw: Fraction {
        return Fraction(numerator: numerator,
                        denominator: denominator)
    }
    
    public var adjusted: Fraction {
        return super.multiply(scalar)
    }
    
    public override func invert() -> Price {
        return Price(baseCurrency: quoteCurrency,
                     quoteCurrency: baseCurrency,
                     denominator: numerator,
                     numerator: denominator)
    }
    
    public func multiply(by other: Price) throws -> Price {
        guard
            quoteCurrency.equalTo(other.baseCurrency)
        else {
            throw CurrencyAmountError.notSameToken
        }
        
        let fraction = super.multiply(other)
        
        return Price(baseCurrency: baseCurrency,
                     quoteCurrency: other.quoteCurrency,
                     denominator: fraction.denominator,
                     numerator: fraction.numerator)
    }
    
    public func quote(currencyAmount: CurrencyAmount) throws -> CurrencyAmount {
        guard
            quoteCurrency.equalTo(baseCurrency)
        else { throw CurrencyAmountError.notSameToken }
        
        if let token = quoteCurrency as? Token {
            return TokenAmount(token: token,
                               amount: super.multiply(currencyAmount.raw).quotient)
        }
        
        return CurrencyAmount.ether(amount: super.multiply(currencyAmount.raw).quotient)
    }
    
    public func toSignificant(significantDigits: UInt = 6,
                              rounding: NumberFormatter.RoundingMode?) throws -> String {
        return try adjusted.toSignificant(significantDigits,
                                          rounding: rounding)
    }
    
    public func toFixed(decimalPlaces: UInt = 4,
                        rounding: NumberFormatter.RoundingMode?) throws -> String {
        return try adjusted.toFixed(decimalPlaces,
                                    rounding: rounding)
    }
}

extension Price {
    public static func from(pairs: [Pair],
                            path: [Currency]) throws -> Price {
        var prices: [Price] = []
        
        for (index, pair) in pairs.enumerated() {
            let curPrice = path[index].equalTo(pair.token0)
            
            ? Price(baseCurrency: pair.reserve0.currency,
                    quoteCurrency: pair.reserve1.currency,
                    denominator: pair.reserve0.raw,
                    numerator: pair.reserve1.raw)
            
            : Price(baseCurrency: pair.reserve1.currency,
                    quoteCurrency: pair.reserve0.currency,
                    denominator: pair.reserve1.raw,
                    numerator: pair.reserve0.raw)
            
            prices.append(curPrice)
        }
        
        return try prices.dropFirst().reduce(prices[0], { (partialResult, curPrice) throws  -> Price in
            return try partialResult.multiply(by: curPrice)
        })
    }
    
    public static func from(route: Route) throws -> Price {
        return try Self.from(pairs: route.pairs,
                         path: route.path)
    }
}
