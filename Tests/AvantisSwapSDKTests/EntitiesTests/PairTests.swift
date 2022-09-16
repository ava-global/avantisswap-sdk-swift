//
//  PairTests.swift
//  PancakeSDK-swiftTests
//
//  Created by dAISY foto on 8/9/2565 BE.
//

import XCTest
import BigInt
import Quick
import Nimble
import AvantisSwapSDK

class PairTests: QuickSpec {
    
    let usdc = Token(chainId: ChainId.mainnet,
                     address: "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d",
                     decimals: 18,
                     symbols: "USDC",
                     name: "USD Coin")
    let dai = Token(chainId: ChainId.mainnet,
                    address: "0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3",
                    decimals: 18,
                    symbols: "DAI",
                    name: "DAI Stablecoin")
    
    override func spec() {
        
        describe("#constructor") {
            it("cannot be used for tokens on different chains") {
                expect(try Pair(tokenAmountA: TokenAmount(token: self.usdc,
                                                      amount: BigUInt.hundred),
                            tokenAmountB: TokenAmount(token: Constant.wETH[ChainId.testnet]!,
                                                      amount: BigUInt.hundred))).to(throwError(TokenError.tokenAreOnDifferentChains))
            }
        }
        
        describe("#getAddress") {
            it("returns the correct address") {
                expect(try Pair.getAddress(tokenA: self.usdc,
                                           tokenB: self.dai))
                .to(equal("0x35dd4c0af967e1c1108cc765917d28edec52cc9d"))
            }
        }
        
        describe("#token0") {
            it("always is the token that sorts before") {
                expect(try Pair(tokenAmountA: TokenAmount(token: self.usdc,
                                                          amount: BigUInt.hundred),
                                tokenAmountB: TokenAmount(token: self.dai,
                                                          amount: BigUInt.hundred)).token0)
                .to(equal(self.dai))
                
                expect(try Pair(tokenAmountA: TokenAmount(token: self.dai,
                                                          amount: BigUInt.hundred),
                                tokenAmountB: TokenAmount(token: self.usdc,
                                                          amount: BigUInt.hundred)).token0)
                .to(equal(self.dai))
            }
        }
        
        describe("#token1") {
            it("always is the token that sorts after") {
                expect(try Pair(tokenAmountA: TokenAmount(token: self.usdc,
                                                          amount: BigUInt.hundred),
                                tokenAmountB: TokenAmount(token: self.dai,
                                                          amount: BigUInt.hundred)).token1)
                .to(equal(self.usdc))
                
                expect(try Pair(tokenAmountA: TokenAmount(token: self.dai,
                                                          amount: BigUInt.hundred),
                                tokenAmountB: TokenAmount(token: self.usdc,
                                                          amount: BigUInt.hundred)).token1)
                .to(equal(self.usdc))
            }
        }
        
        describe("#reserve0") {
            it("always comes from the token that sorts before") {
                expect(try Pair(tokenAmountA: TokenAmount(token: self.usdc,
                                                          amount: 100),
                                tokenAmountB: TokenAmount(token: self.dai,
                                                          amount: 101)).reserve0)
                .to(equal(TokenAmount(token: self.dai,
                                      amount: 101)))
            }
        }
        
        describe("#reserve0") {
            it("always comes from the token that sorts after") {
                expect(try Pair(tokenAmountA: TokenAmount(token: self.usdc,
                                                          amount: 100),
                                tokenAmountB: TokenAmount(token: self.dai,
                                                          amount: 101)).reserve1)
                .to(equal(TokenAmount(token: self.dai,
                                      amount: 100)))
            }
        }
        
        
        describe("#token0Price") {
            it("returns price of token0 in terms of token1") {
                let pair0 = try Pair(tokenAmountA: TokenAmount(token: self.usdc,
                                                               amount: 101),
                                     tokenAmountB: TokenAmount(token: self.dai,
                                                               amount: 100))
                let pair1 = try Pair(tokenAmountA: TokenAmount(token: self.dai,
                                                               amount: 100),
                                     tokenAmountB: TokenAmount(token: self.usdc,
                                                               amount: 101))
                let price0 = Price(baseCurrency: self.usdc,
                                   quoteCurrency: self.dai,
                                   denominator: 100,
                                   numerator: 101)
                
                expect(pair0.token0Price).to(equal(price0))
                expect(pair1.token0Price).to(equal(price0))
            }
        }
        
        describe("#token1Price") {
            it("returns price of token1 in terms of token0") {
                let pair0 = try Pair(tokenAmountA: TokenAmount(token: self.usdc,
                                                               amount: 101),
                                     tokenAmountB: TokenAmount(token: self.dai,
                                                               amount: 100))
                let pair1 = try Pair(tokenAmountA: TokenAmount(token: self.dai,
                                                               amount: 100),
                                     tokenAmountB: TokenAmount(token: self.usdc,
                                                               amount: 101))
                let price1 = Price(baseCurrency: self.usdc,
                                   quoteCurrency: self.dai,
                                   denominator: 101,
                                   numerator: 100)
                
                expect(pair0.token1Price).to(equal(price1))
                expect(pair1.token1Price).to(equal(price1))
            }
        }
        
        describe("#priceOf") {
            let pair = try! Pair(tokenAmountA: TokenAmount(token: self.usdc,
                                                           amount: 101),
                                 tokenAmountB: TokenAmount(token: self.dai,
                                                           amount: 100))
            
            it("returns price of token in terms of other token") {
                expect(try pair.priceOf(token: self.dai)).to(equal(pair.token0Price))
                expect(try pair.priceOf(token: self.usdc)).to(equal(pair.token1Price))
            }
            
            it("throws if invalid token") {
                expect(try pair.priceOf(token: Constant.wETH[ChainId.mainnet]!)).to(throwError(PancakeSwapError.notInPair))
            }
        }
        
        describe("#reserveOf") {
            let pair0 = try! Pair(tokenAmountA: TokenAmount(token: self.usdc,
                                                           amount: 100),
                                 tokenAmountB: TokenAmount(token: self.dai,
                                                           amount: 101))
            let pair1 = try! Pair(tokenAmountA: TokenAmount(token: self.dai,
                                                           amount: 101),
                                 tokenAmountB: TokenAmount(token: self.usdc,
                                                           amount: 100))
            it("returns reserves of the given token") {
                expect(try pair0.reserveOf(token: self.usdc))
                    .to(equal(TokenAmount(token: self.usdc,
                                          amount: 100)))
                
                expect(try pair1.reserveOf(token: self.usdc))
                    .to(equal(TokenAmount(token: self.usdc,
                                          amount: 100)))
            }
            
            it("throws if not in the pair") {
                expect(try pair1.reserveOf(token: Constant.wETH[ChainId.mainnet]!)).to(throwError(PancakeSwapError.notInPair))
            }
        }
        
        describe("#chainId") {
            let pair0 = try! Pair(tokenAmountA: TokenAmount(token: self.usdc,
                                                           amount: 100),
                                 tokenAmountB: TokenAmount(token: self.dai,
                                                           amount: 101))
            let pair1 = try! Pair(tokenAmountA: TokenAmount(token: self.dai,
                                                           amount: 101),
                                 tokenAmountB: TokenAmount(token: self.usdc,
                                                           amount: 100))
            
            it("returns price of token1 in terms of token0") {
                expect(pair0.chainID).to(equal(ChainId.mainnet))
                expect(pair1.chainID).to(equal(ChainId.mainnet))
            }
        }
        
        describe("#involvesToken") {
            let pair = try! Pair(tokenAmountA: TokenAmount(token: self.usdc,
                                                           amount: 100),
                                 tokenAmountB: TokenAmount(token: self.dai,
                                                           amount: 101))
            expect(pair.involvesToken(token: self.usdc)).to(equal(true))
            expect(pair.involvesToken(token: self.dai)).to(equal(true))
            expect(pair.involvesToken(token: Constant.wETH[ChainId.mainnet]!)).to(equal(false))
        }
    }
}
    

