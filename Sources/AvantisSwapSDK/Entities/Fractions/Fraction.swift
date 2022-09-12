//
//  Fraction.swift
//  PancakeSDK-swift
//
//  Created by IntrodexMac on 7/9/2565 BE.
//

import Foundation
import BigInt

public class Fraction {
    public let numerator: BigUInt
    public let denominator: BigUInt
    
    public var quotient: BigUInt {
        return numerator.quotientAndRemainder(dividingBy: denominator).quotient
    }
    
    public var remainder: Fraction {
        return .init(numerator: numerator.quotientAndRemainder(dividingBy: denominator).remainder,
                     denominator: denominator)
    }
    
    public var asFraction: Fraction {
        return .init(numerator: numerator,
                     denominator: denominator)
    }
    
    public init(numerator: BigUInt,         
                denominator: BigUInt = BigUInt(1)) {
        self.numerator = numerator
        self.denominator = denominator        
    }
    
    public func lessThan(_ other: Fraction) -> Bool {
        return self < other
    }
    
    public func equalTo(_ other: Fraction) -> Bool {
        return self == other
    }
    
    public func greaterThan(_ other: Fraction) -> Bool {
        return self > other
    }
    
    public func invert() -> Fraction {
        return .init(numerator: denominator,
                     denominator: numerator)
    }
    
    public func add(_ other: Fraction) -> Fraction {
        if denominator == other.denominator {
            return .init(numerator: numerator + other.numerator,
                         denominator: denominator)
        }
        let num1 = numerator.multiplied(by: other.denominator)
        let num2 = other.numerator.multiplied(by: denominator)
        let deno = denominator.multiplied(by: other.denominator)
        return .init(numerator: num1 + num2,
                     denominator: deno)
    }
    
    public func add(_ other: BigUInt) -> Fraction {
        let otherFraction = Fraction(numerator: other)
        
        return self.add(otherFraction)
    }
    
    // not support sign integer
    public func substract(_ other: Fraction) -> Fraction {
        if denominator == other.denominator {
            return .init(numerator: numerator - other.numerator,
                         denominator: denominator)
        }
        let num1 = numerator.multiplied(by: other.denominator)
        let num2 = other.numerator.multiplied(by: denominator)
        let deno = denominator.multiplied(by: other.denominator)
        return .init(numerator: num1 - num2,
                     denominator: deno)
    }
    
    public func substract(_ other: BigUInt) -> Fraction {
        let otherFaction = Fraction(numerator: other)
        return self.substract(otherFaction)
    }
    
    public func multiply(_ other: Fraction) -> Fraction {
        return .init(numerator: numerator * other.numerator,
                     denominator: denominator * other.denominator)
    }
    
    public func multiply(_ other: BigUInt) -> Fraction {
        let fraction = Fraction(numerator: other)
        
        return self.multiply(fraction)
    }
    
    public func divide(_ other: Fraction) -> Fraction {
        return .init(numerator: numerator * other.denominator,
                     denominator: denominator * other.numerator)
    }
    
    
    public func toSignificant(_ significantDigits: UInt,
                       rounding: NumberFormatter.RoundingMode? = .halfUp) throws -> String {
        if significantDigits == 0 {
            throw FractionError.isNotPositive(significantDigits: significantDigits)
        }
                        
        let deNum = Decimal(string: numerator.description)!
        let deDeno = Decimal(string: denominator.description)!
        
        let quotient = deNum / deDeno
        return quotient.toSignificants(Int(significantDigits),
                                       rounding: rounding ?? .halfUp)
    }
    
    public func toFixed(_ decimalPlaces: UInt,
                        rounding: NumberFormatter.RoundingMode? = .halfUp) throws -> String {
                            
        let deNum = Decimal(string: numerator.description)!
        let deDeno = Decimal(string: denominator.description)!
        
        let quotient = deNum / deDeno
        return quotient.toFractionDigits(Int(decimalPlaces),
                                         rounding: rounding ?? .halfUp)
    }
    
}

public extension Fraction {
    
    enum FractionError: Error, LocalizedError {
        case isNotPositive(significantDigits: UInt)
        
        public var errorDescription: String? {
            switch self {
            case .isNotPositive(let significantDigits):
                return "\(significantDigits) is not positive."
            }
        }
    }
    
}
    
extension Fraction: Comparable {
    
    public static func < (lhs: Fraction,
                          rhs: Fraction) -> Bool {
        return lhs.numerator.multiplied(by: rhs.denominator) < rhs.numerator.multiplied(by: lhs.denominator)
    }
    
    public static func == (lhs: Fraction,
                           rhs: Fraction) -> Bool {
        return lhs.numerator.multiplied(by: rhs.denominator) == rhs.numerator.multiplied(by: lhs.denominator)
    }
        
}

extension Fraction {
    public static var zero: Fraction {
        return Fraction(numerator: 0)
    }
    
    public static var one: Fraction {
        return Fraction(numerator: 1)
    }
}

extension Decimal {
    func toSignificants(_ significantDigits: Int,
                        rounding: NumberFormatter.RoundingMode) -> String {
        let numberFormatter = NumberFormatter()

        numberFormatter.numberStyle = .decimal
        numberFormatter.usesSignificantDigits = true
        numberFormatter.minimumSignificantDigits = 0
        numberFormatter.maximumSignificantDigits = significantDigits
        numberFormatter.roundingMode = rounding

        return numberFormatter.string(from: self as NSNumber) ?? ""
    }
    
    func toFractionDigits(_ fractionDigits: Int,
                          rounding: NumberFormatter.RoundingMode) -> String {
        let numberFormatter = NumberFormatter()

        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = fractionDigits
        numberFormatter.maximumFractionDigits = fractionDigits
        numberFormatter.roundingMode = rounding

        return numberFormatter.string(from: self as NSNumber) ?? ""
    }
}

