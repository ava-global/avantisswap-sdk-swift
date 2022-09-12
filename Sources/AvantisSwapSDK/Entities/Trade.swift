//
//  Trade.swift
//  PancakeSDK-swift
//
//  Created by Peerasak Unsakon on 9/9/2565 BE.
//

import Foundation
import BigInt
import CoreVideo

public class Trade {
    
    public let route: Route
    public let tradeType: TradeType
    public let inputAmount: TokenAmount
    public let outputAmount: TokenAmount
    public let executionPrice: Price
    public let nextMidPrice: Price
    public let priceImpact: Percent
    
    public init(route: Route,
                amount: TokenAmount,
                tradeType: TradeType) throws {
        var amounts = [TokenAmount?](repeating: nil,
                                     count: route.path.count)
        
        var nextPairs = [Pair?](repeating: nil,
                                count: route.pairs.count)
        
        if tradeType == .exactInput {
            guard amount.currency.equalTo(route.input) else { throw RouteError.invalidInput}
            amounts[0] = amount
            for index in 0...(route.path.count - 2) {
                guard let curAmount = amounts[index] else { throw RouteError.invalidInput }
                let pair = route.pairs[index]
                let outputResult = try pair.getOutputAmount(inputAmount: curAmount)
                
                amounts[index + 1] = outputResult.tokenAmount
                nextPairs[index] = outputResult.nextPair
            }
        } else {
            guard amount.currency.equalTo(route.output) else { throw RouteError.invalidOutput}
            amounts[amounts.count - 1] = amount
            
            for index in (1...(route.path.count - 1)).reversed() {
                guard let curAmount = amounts[index] else { throw RouteError.invalidOutput }
                let pair = route.pairs[index - 1]
                let inputResult = try pair.getInputAmount(outputAmount: curAmount)
                
                amounts[index - 1] = inputResult.tokenAmount
                nextPairs[index - 1] = inputResult.nextPair
            }
        }
        
        let wrappedAmounts = amounts.compactMap({ $0 })
        let wrappedNextPairs = nextPairs.compactMap({ $0 })
        
        self.route = route
        self.tradeType = tradeType
        
        self.inputAmount = tradeType == .exactInput ? amount : wrappedAmounts[0]
        self.outputAmount = tradeType == .exactOutput ? amount : wrappedAmounts[wrappedAmounts.count - 1]
        
        self.executionPrice = Price(baseCurrency: inputAmount.currency,
                                    quoteCurrency: outputAmount.currency,
                                    denominator: inputAmount.raw,
                                    numerator: outputAmount.raw)
        let nextRoute = try Route(pairs: wrappedNextPairs,
                                  input: route.input)
        self.nextMidPrice = try Price.from(route: nextRoute)
        self.priceImpact = Percent(numerator: 100)
    }
}

extension Trade {
    public func minimumAmountOut(slippageTolerance: Percent) throws -> TokenAmount {
        guard !slippageTolerance.lessThan(Fraction(numerator: 0))
        else { throw TradeError.slippageTolerance }
        
        guard tradeType != .exactOutput else {
            return outputAmount
        }
        
        let slippageAdjustedAmountOut = Fraction(numerator: 1)
            .add(slippageTolerance)
            .invert()
            .multiply(outputAmount.raw).quotient
        
        return TokenAmount(token: outputAmount.token,
                           amount: slippageAdjustedAmountOut)
    }
    
    public func maximumAmountInput(slippageTolerance: Percent) throws -> TokenAmount {
        guard !slippageTolerance.lessThan(Fraction(numerator: 0))
        else { throw TradeError.slippageTolerance }
        
        guard tradeType != .exactInput else {
            return inputAmount
        }
        
        let slippageAdjustedAmountIn = Fraction(numerator: 1)
            .add(slippageTolerance)
            .multiply(inputAmount.raw).quotient
        
        return TokenAmount(token: inputAmount.token,
                           amount: slippageAdjustedAmountIn)
    }
}

extension Trade {
    static func computePriceImpact(midPrice: Price,
                                   inputAmount: TokenAmount,
                                   outputAmount: TokenAmount) -> Percent {
        let exactQuote = midPrice.raw.multiply(inputAmount.raw)
        let slippage = exactQuote.substract(outputAmount.raw).divide(exactQuote)
        
        return Percent(numerator: slippage.numerator,
                       denominator: slippage.denominator)
    }
}

extension Trade {
    public static func bestTradeExactIn(pairs: [Pair],
                                        currencyAmountIn: TokenAmount,
                                        currencyOut: Token,
                                        maxNumResults: Int = 3,
                                        maxHops: Int = 3,
                                        currentPairs: [Pair] = [],
                                        originalAmountIn: TokenAmount,
                                        bestTrades: [Trade] = []) throws -> [Trade] {
        
        guard pairs.count > 0 else { throw TradeError.emptyPairs }
        guard maxHops > 0 else { throw TradeError.zeroMaxHop }
        guard
            originalAmountIn == currencyAmountIn || currentPairs.count > 0
        else { throw TradeError.invalideRecursion }
        
        let amountIn = currencyAmountIn
        let tokenOut = currencyOut
        var newBestTrades: [Trade] = bestTrades
        
        for pair in pairs {
            if !pair.token0.equals(amountIn.token) && !pair.token1.equals(amountIn.token) { continue }
            if pair.reserve0.equalTo(.zero) || pair.reserve1.equalTo(.zero) { continue }
            
            let amountOut: TokenAmount
            
            do {
                let outputResult = try pair.getOutputAmount(inputAmount: amountIn)
                amountOut = outputResult.tokenAmount
            } catch PancakeSwapError.insufficientInputAmount {
                continue
            } catch {
                throw error
            }
            
            if amountOut.token.equals(tokenOut) {
                let newTrade = try Trade(route: try Route(pairs: currentPairs + [pair],
                                                          input: originalAmountIn.token,
                                                          output: tokenOut),
                                         amount: originalAmountIn,
                                         tradeType: .exactInput)
                
                let tradeIndex = bestTrades.insertionIndexOf(newTrade,
                                                            isOrderedBefore: (<))
                newBestTrades.insert(newTrade,
                                     at: tradeIndex)
            } else if maxHops > 1 && pairs.count > 1 {
                let pairsExcludingThisPair = pairs.filter({ pair != $0 })
                
                newBestTrades = try Trade.bestTradeExactIn(pairs: pairsExcludingThisPair,
                                                           currencyAmountIn: amountOut,
                                                           currencyOut: tokenOut,
                                                           maxNumResults: maxNumResults,
                                                           maxHops: maxHops - 1,
                                                           currentPairs: currentPairs + [pair],
                                                           originalAmountIn: originalAmountIn,
                                                           bestTrades: newBestTrades)
            }
        }
        
        newBestTrades = Array(newBestTrades.prefix(maxNumResults))
        
        return newBestTrades
    }
    
    public static func bestTradeExactOut(pairs: [Pair],
                                         currencyIn: Token,
                                         currencyAmountOut: TokenAmount,
                                         maxNumResults: Int = 3,
                                         maxHops: Int = 3,
                                         currentPairs: [Pair] = [],
                                         originalAmountOut: TokenAmount,
                                         bestTrades: [Trade] = []) throws -> [Trade] {
        
        guard pairs.count > 0 else { throw TradeError.emptyPairs }
        guard maxHops > 0 else { throw TradeError.zeroMaxHop }
        guard
            originalAmountOut == currencyAmountOut || currentPairs.count > 0
        else { throw TradeError.invalideRecursion }
        
        let amountOut = currencyAmountOut
        let tokenIn = currencyIn
        var newBestTrades: [Trade] = bestTrades
        
        for pair in pairs {
            if !pair.token0.equals(amountOut.token) && !pair.token1.equals(amountOut.token) { continue }
            if pair.reserve0.equalTo(.zero) || pair.reserve1.equalTo(.zero) { continue }
            
            let amountIn: TokenAmount
            
            do {
                let inputResult = try pair.getInputAmount(outputAmount: amountOut)
                amountIn = inputResult.tokenAmount
            } catch PancakeSwapError.insufficientReserves {
                continue
            } catch {
                throw error
            }
            
            if amountIn.token.equals(tokenIn) {
                let newTrade = try Trade(route: try Route(pairs: [pair] + currentPairs,
                                                          input: tokenIn,
                                                          output: originalAmountOut.token),
                                         amount: originalAmountOut,
                                         tradeType: .exactOutput)
                
                let tradeIndex = bestTrades.insertionIndexOf(newTrade,
                                                            isOrderedBefore: (<))
                newBestTrades.insert(newTrade,
                                     at: tradeIndex)
                
            } else if maxHops > 1 && pairs.count > 1 {
                let pairsExcludingThisPair = pairs.filter({ pair != $0 })
                
                newBestTrades = try Trade.bestTradeExactOut(pairs: pairsExcludingThisPair,
                                                            currencyIn: tokenIn,
                                                            currencyAmountOut: amountIn,
                                                            maxNumResults: 3,
                                                            maxHops: 3,
                                                            currentPairs: [pair] + currentPairs,
                                                            originalAmountOut: originalAmountOut,
                                                            bestTrades: newBestTrades)
            }
        }
        
        newBestTrades = Array(newBestTrades.prefix(maxNumResults))
        
        return newBestTrades
    }
}

extension Trade: Comparable {
    public static func < (lhs: Trade,
                          rhs: Trade) -> Bool {
        if lhs.outputAmount != rhs.outputAmount {
            return lhs.outputAmount > rhs.outputAmount
        }
        
        if lhs.inputAmount != rhs.inputAmount {
            return lhs.inputAmount < rhs.inputAmount
        }
        
        if lhs.priceImpact != rhs.priceImpact {
            return lhs.priceImpact < rhs.priceImpact
        }
        
        return lhs.route.path.count < rhs.route.path.count
    }
    
    public static func == (lhs: Trade,
                           rhs: Trade) -> Bool {
        lhs.outputAmount == rhs.outputAmount &&
        lhs.inputAmount == rhs.inputAmount &&
        lhs.priceImpact == rhs.priceImpact &&
        lhs.route.path.count == rhs.route.path.count
    }
}

public enum TradeError: Error,
                 LocalizedError {
    case slippageTolerance
    case emptyPairs
    case zeroMaxHop
    case invalideRecursion
}

extension Array {
    func insertionIndexOf(_ elem: Element,
                          isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
}
