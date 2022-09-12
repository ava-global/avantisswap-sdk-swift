//
//  TokenAmount.swift
//  PancakeSDK-swift
//
//  Created by dAISY foto on 8/9/2565 BE.
//

import Foundation
import BigInt

public class TokenAmount: CurrencyAmount {
    public let token: Token
    
    public init(token: Token, amount: BigUInt) {
        self.token = token
        
        super.init(currency: token,
                   amount: amount)
    }
    
    public func add(other: TokenAmount) throws -> TokenAmount {
        guard
            token.equals(other.token)
        else { throw CurrencyAmountError.notSameToken }
        
        return TokenAmount(token: token,
                           amount: raw + other.raw)
    }
    
    public func subtract(other: TokenAmount) throws -> TokenAmount {
        guard
            token.equals(other.token)
        else { throw CurrencyAmountError.notSameToken }
        
        return TokenAmount(token: token,
                           amount: raw - other.raw)
    }
}

extension TokenAmount {
    public static func < (lhs: TokenAmount,
                          rhs: TokenAmount) -> Bool {
        lhs.asFraction < rhs.asFraction
    }
    
    public static func <= (lhs: TokenAmount,
                           rhs: TokenAmount) -> Bool {
        lhs.asFraction <= rhs.asFraction
    }
    
    public static func > (lhs: TokenAmount,
                          rhs: TokenAmount) -> Bool {
        lhs.asFraction > rhs.asFraction
    }
    
    public static func >= (lhs: TokenAmount,
                           rhs: TokenAmount) -> Bool {
        lhs.asFraction >= rhs.asFraction
    }
    
    public static func == (lhs: TokenAmount,
                           rhs: TokenAmount) -> Bool {
        lhs.asFraction == rhs.asFraction
    }
    
}
