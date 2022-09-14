//
//  Pair.swift
//  PancakeSDK-swift
//
//  Created by dAISY foto on 8/9/2565 BE.
//

import Foundation
import BigInt

public class Pair {
    public let liquidityToken: Token
    
    //TODO: Refactor should we separate tokenAmount0 and tokenAmount1
    private let tokenAmounts: (token0: TokenAmount,
                               token1: TokenAmount)
    
    public init(tokenAmountA: TokenAmount,
                tokenAmountB: TokenAmount) throws {
        let tokenAmounts = (try tokenAmountA.token.sortBefore(tokenAmountB.token))
        ? [tokenAmountA, tokenAmountB]
        : [tokenAmountB, tokenAmountA]
        
        self.liquidityToken = Token(chainId: tokenAmounts[0].token.chainId,
                                    address: try Pair.getAddress(tokenA: tokenAmounts[0].token,
                                                                 tokenB: tokenAmounts[1].token),
                                    decimals: 18,
                                    symbols: "Cake-LP",
                                    name: "Pancake LPs")
        self.tokenAmounts = (tokenAmounts[0],
                             tokenAmounts[1])
    }
    
    public static func getAddress(tokenA: Token,
                                  tokenB: Token) throws -> String {
        let (token0, token1) = (try tokenA.sortBefore(tokenB))
        ? (tokenA, tokenB)
        : (tokenB, tokenA)
        
        guard
            let hashCode = Constant.initCodeHashMap[token0.chainId],
            let factoryAddress = Constant.factoryAddressMap[token0.chainId],
            let token0AddressData = token0.address.hexData,
            let token1AddressData = token1.address.hexData,
            let prefixData = Data(hex: "ff"),
            let factoryAddressData = Data(hex: factoryAddress),
            let hashCodeData = Data(hex: hashCode)
        else {
            throw PancakeSwapError.notSameChain
        }
        
        let addressHash = (token0AddressData + token1AddressData).keccak256
        let data = prefixData + factoryAddressData + addressHash + hashCodeData
        let addressString = data.keccak256.suffix(20).hexString
        
        return addressString
    }
}

// MARK: - Computed properties
extension Pair {
    public var chainID: ChainId {
        return token0.chainId
    }
    
    public var token0: Token {
        return tokenAmounts.token0.token
    }
    
    public var token1: Token {
        return tokenAmounts.token1.token
    }
    
    public var reserve0: TokenAmount {
        return tokenAmounts.token0
    }
    
    public var reserve1: TokenAmount {
        return tokenAmounts.token1
    }
    
    public var token0Price: Price {
        return Price(baseCurrency: token0,
                     quoteCurrency: token1,
                     denominator: tokenAmounts.token0.raw,
                     numerator: tokenAmounts.token1.raw)
    }
    
    public var token1Price: Price {
        return Price(baseCurrency: token1,
                     quoteCurrency: token0,
                     denominator: tokenAmounts.token1.raw,
                     numerator: tokenAmounts.token0.raw)
    }
}

// MARK: - Functions

extension Pair {
    public typealias TokenAmountPair = (tokenAmount: TokenAmount,
                                        nextPair: Pair)
    
    public func involvesToken(token: Token) -> Bool {
        return token.equals(token0) || token.equals(token1)
    }
    
    public func otherToken(token: Token) throws -> Token {
        guard involvesToken(token: token) else { throw PancakeSwapError.notInPair }
        return token.equals(token0) ? token1 : token0
    }
    
    public func priceOf(token: Token) throws -> Price {
        guard involvesToken(token: token) else { throw PancakeSwapError.notInPair }
        return token.equals(token0) ? token0Price : token1Price
    }
    
    public func reserveOf(token: Token) throws -> TokenAmount {
        guard involvesToken(token: token) else { throw PancakeSwapError.notInPair }
        return token.equals(token0) ? reserve0 : reserve1
    }

}

// MARK: - AMM Functions

extension Pair {
    public func getOutputAmount(inputAmount: TokenAmount) throws -> TokenAmountPair {
        guard involvesToken(token: inputAmount.token) else { throw PancakeSwapError.notInPair }
        guard reserve0.raw > BigUInt.zero || reserve1.raw > BigUInt.zero else { throw PancakeSwapError.insufficientReserves }
        
        let otherToken = try otherToken(token: inputAmount.token)
        let inputReserve = try reserveOf(token: inputAmount.token)
        let outputReserve = try reserveOf(token: otherToken)
        let inputAmountWithFee = inputAmount.raw * Constant.feeNumerator
        let numerator = inputAmountWithFee * outputReserve.raw
        let denominator = inputReserve.raw.multiplied(by: Constant.feeDenominator).advanced(by: BigInt(inputAmountWithFee))
        let outputAmount = TokenAmount(token: otherToken,
                                       amount: numerator.quotientAndRemainder(dividingBy: denominator).quotient)
        
        guard outputAmount.raw > BigUInt.zero else { throw PancakeSwapError.insufficientInputAmount }
        
        let tokenAmountA = try inputReserve.add(other: inputAmount)
        let tokenAmountB = try outputReserve.subtract(other: outputReserve)
        let nextPair = try Pair(tokenAmountA: tokenAmountA,
                                tokenAmountB: tokenAmountB)
        
        return TokenAmountPair(outputAmount, nextPair)
    }
    
    public func getInputAmount(outputAmount: TokenAmount) throws -> TokenAmountPair {
        guard involvesToken(token: outputAmount.token) else { throw PancakeSwapError.notInPair }
        guard
            reserve0.raw > BigUInt.zero || reserve1.raw > BigUInt.zero,
            outputAmount.raw < (try reserveOf(token: outputAmount.token)).raw
        else { throw PancakeSwapError.insufficientReserves }
        
        let inputToken = try otherToken(token: outputAmount.token)
        let outputReserve = try reserveOf(token: outputAmount.token)
        let inputReserve = try reserveOf(token: inputToken)
        
        let numerator = inputReserve.raw
            .multiplied(by: outputAmount.raw)
            .multiplied(by: Constant.feeDenominator)
        let denominator = outputReserve.raw
            .subtracting(outputAmount.raw)
            .multiplied(by: Constant.feeNumerator)
        let newAmount = numerator.quotientAndRemainder(dividingBy: denominator).quotient
            .advanced(by: BigInt(BigUInt.one))
        
        let inputAmount = TokenAmount(token: inputToken,
                                      amount: newAmount)
        
        let tokenAmountA = try inputReserve.add(other: inputAmount)
        let tokenAmountB = try outputReserve.subtract(other: outputAmount)
        
        let nextPair = try Pair(tokenAmountA: tokenAmountA,
                                tokenAmountB: tokenAmountB)
        
        return TokenAmountPair(inputAmount, nextPair)
    }
}

extension Pair: Equatable {
    public static func == (lhs: Pair,
                           rhs: Pair) -> Bool {
        
        let isSameToken0 = lhs.token0.equalTo(rhs.token0)
        let isSameToken1 = lhs.token1.equalTo(rhs.token1)
        let isSameReserve0 = lhs.reserve0.equalTo(rhs.reserve0)
        let isSameReserve1 = lhs.reserve1.equalTo(rhs.reserve1)
        
        return [isSameToken0,
                isSameToken1,
                isSameReserve0,
                isSameReserve1].allSatisfy({ $0 == true })
    }
}

public enum PancakeSwapError: Error,
                       LocalizedError {
    case notSameChain
    case notInPair
    case insufficientReserves
    case insufficientInputAmount
}
