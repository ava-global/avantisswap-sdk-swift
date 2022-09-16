//
//  Currency.swift
//  PancakeSDK-swift
//
//  Created by IntrodexMac on 7/9/2565 BE.
//

import Foundation
import BigInt

public protocol CurrencyProtocol {
    var decimals: UInt { get }
    var symbol: String? { get }
    var name: String? { get }
    
    func equalTo(_ other: CurrencyProtocol) -> Bool
}

public class Currency: CurrencyProtocol {
    
    public static let ETHER: Currency = .init(decimals: 18,
                                              symbol: "BNB",
                                              name: "BNB")
    
    public let decimals: UInt
    public let symbol: String?
    public let name: String?
    
    public init(decimals: UInt,
                symbol: String?,
                name: String?) {
               self.decimals = decimals
               self.symbol = symbol
               self.name = name
    }

    public func equalTo(_ other: CurrencyProtocol) -> Bool {
        guard let otherCurrency = other as? Currency
        else { return false }
        
        return self == otherCurrency
    }
}

extension Currency: Equatable {
    public static func == (lhs: Currency,
                           rhs: Currency) -> Bool {
        return lhs.symbol == rhs.symbol &&
        lhs.decimals == rhs.decimals &&
        lhs.name == rhs.name
    }
}
