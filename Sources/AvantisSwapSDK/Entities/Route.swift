//
//  Route.swift
//  PancakeSDK-swift
//
//  Created by Peerasak Unsakon on 8/9/2565 BE.
//

import Foundation
import BigInt

public enum RouteError: Error,
                        LocalizedError {
    case noPair
    case invalidChain
    case invalidInput
    case invalidOutput
    case invalidPath
}

public class Route {
    public let pairs: [Pair]
    public let path: [Currency]
    public let input: Currency
    public let output: Currency
    public let midPrice: Price
    
    public init(pairs: [Pair],
                input: CurrencyProtocol,
                output: CurrencyProtocol? = nil) throws {
        
        guard pairs.count > 0 else { throw RouteError.noPair }
        guard
            pairs.allSatisfy({ $0.chainID == pairs[0].chainID }),
            let wETH = Constant.wETH[pairs[0].chainID]
        else {
            throw RouteError.invalidChain
        }
        
        if let inputToken = input as? Token {
            guard pairs[0].involvesToken(token: inputToken) else { throw RouteError.invalidInput}
        } else if let ethInput = input as? Currency {
            guard
                ethInput.equalTo(Currency.ETHER),
                pairs[0].involvesToken(token: wETH)
            else {
                throw RouteError.invalidInput
            }
        } else {
            throw RouteError.invalidInput
        }
        
        if let outputToken = output as? Token {
            guard pairs[pairs.count - 1].involvesToken(token: outputToken) else { throw RouteError.invalidInput}
        } else if let ethOutput = output as? Currency {
            guard
                ethOutput.equalTo(Currency.ETHER),
                pairs[pairs.count - 1].involvesToken(token: wETH)
            else {
                throw RouteError.invalidInput
            }
        }
        
        var path: [Currency] = []
        
        if let inputToken = input as? Token {
            path.append(inputToken)
        } else {
            path.append(wETH)
        }
        
        for (index, pair) in pairs.enumerated() {
            let currentInput = path[index]
            guard
                currentInput.equalTo(pair.token0) || currentInput.equalTo(pair.token1)
            else {
                throw RouteError.invalidPath
            }
            
            let output = currentInput.equalTo(pair.token0) ? pair.token1 : pair.token0
            
            path.append(output)
        }
        
        self.pairs = pairs
        self.path = path
        
        if let inputToken = input as? Token {
            self.input = inputToken
        } else {
            self.input = wETH
        }
        
        if let outputToken = output as? Token {
            self.output = outputToken
        } else if let ethOutput = output as? Currency, ethOutput.equalTo(Currency.ETHER) {
            self.output = wETH
        } else {
            self.output = path[path.count - 1]
        }
        
        self.midPrice = try Price.from(pairs: pairs,
                                       path: path)
    }
}

extension Route {
    public var chainID: ChainId {
        return pairs[0].chainID
    }
}
