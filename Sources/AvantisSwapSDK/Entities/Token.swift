//
//  Token.swift
//  PancakeSDK-swift
//
//  Created by IntrodexMac on 7/9/2565 BE.
//

import Foundation

public class Token: Currency {
    
    public let chainId: ChainId
    public let address: String
    
    public init(chainId: ChainId,
         address: String,
         decimals: UInt,
         symbols: String? = nil,
         name: String? = nil) {
        self.chainId = chainId
        self.address = address
        
        super.init(decimals: decimals,
                   symbol: symbols,
                   name: name)
    }
    
    public func equals(_ other: Token) -> Bool {
        return self == other
    }
    
    public func sortBefore(_ other: Token) throws -> Bool {
        if chainId != other.chainId {
            throw TokenError.tokenAreOnDifferentChains
        }
        else if address == other.address {
            throw TokenError.tokenHaveTheSameAddress
        }
            
        return address.lowercased() < other.address.lowercased()
    }
    
}

extension Token {
    public static func == (lhs: Token,
                           rhs: Token) -> Bool {
        if lhs === rhs {
            return true
        }
        
        return (lhs.chainId == rhs.chainId) &&
        (lhs.address == rhs.address)
    }
}

public enum TokenError: Error,
                 LocalizedError {
    case tokenHaveTheSameAddress
    case tokenAreOnDifferentChains
    
    public var errorDescription: String? {
        switch self {
        case .tokenHaveTheSameAddress:
            return "tokens have the same address"
        case .tokenAreOnDifferentChains:
            return "tokens are on different chains"
        }
    }
}
