//
//  Constants.swift
//  PancakeSDK-swift
//
//  Created by IntrodexMac on 7/9/2565 BE.
//

import Foundation
import BigInt

public enum ChainId: Int {
    case mainnet = 56
    case testnet = 97
}

public enum TradeType {
    case exactInput
    case exactOutput
}

public struct Constant {
    
    public static let factoryAddress = "0xddA609F8D433A8D2464B14De42CCe5ADc023733B"
    
    public static let factoryAddressMap: [ChainId: String] = [
        ChainId.mainnet: factoryAddress ,
        ChainId.testnet: "0x902Cc3BF57e9077e30248b5E6Ef78d0C62C9996E"
    ]
    
    public static let initCodeHash: String = "0x568da50ca8d8084b9f3b22f341e3f523a51d11309707af8f114037d575133ad9"
    
    public static let initCodeHashMap: [ChainId: String] = [
        ChainId.mainnet: initCodeHash ,
        ChainId.testnet: "0x568da50ca8d8084b9f3b22f341e3f523a51d11309707af8f114037d575133ad9"
    ]
    
    public static let minimumLiquidity: BigUInt = BigUInt(1_000)
             
    public static let feeNumerator: BigUInt = BigUInt(9975)
    public static let feeDenominator: BigUInt = BigUInt(10000)
    
    public static let wETH: [ChainId: Token] = [
        ChainId.mainnet: Token(chainId: ChainId.mainnet,
                               address: "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c",
                               decimals: 18,
                               symbols: "WBNB",
                               name: "Wrapped BNB"),
        ChainId.testnet: Token(chainId: ChainId.testnet,
                               address: "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd",
                               decimals: 18,
                               symbols: "WBNB",
                               name: "Wrapped BNB")
    ]
}

extension BigUInt {
    public static let zero: BigUInt = BigUInt(0)
    public static let one: BigUInt = BigUInt(1)
    public static let two: BigUInt = BigUInt(2)
    public static let three: BigUInt = BigUInt(3)
    public static let five: BigUInt = BigUInt(5)
    public static let ten: BigUInt = BigUInt(10)
    public static let hundred: BigUInt = BigUInt(100)
}

