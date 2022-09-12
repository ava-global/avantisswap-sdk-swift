//
//  TradeTests.swift
//  PancakeSDK-swiftTests
//
//  Created by Peerasak Unsakon on 9/9/2565 BE.
//

import XCTest
import Quick
import Nimble
import BigInt
import AvantisSwapSDK

class TradeSpec: QuickSpec {
    
    override func spec() {
        
        describe("Trade") {
            let token0 = Token(chainId: .mainnet,
                               address: "0x0000000000000000000000000000000000000001",
                               decimals: 18,
                               symbols: "t0")
            let token1 = Token(chainId: .mainnet,
                               address: "0x0000000000000000000000000000000000000002",
                               decimals: 18,
                               symbols: "t0")
            let token2 = Token(chainId: .mainnet,
                               address: "0x0000000000000000000000000000000000000003",
                               decimals: 18,
                               symbols: "t0")
            let token3 = Token(chainId: .mainnet,
                               address: "0x0000000000000000000000000000000000000004",
                               decimals: 18,
                               symbols: "t0")
            
            let pair_0_1 = try! Pair(tokenAmountA: TokenAmount(token: token0, amount: 1000),
                                     tokenAmountB: TokenAmount(token: token1, amount: 1000))
            let pair_0_2 = try! Pair(tokenAmountA: TokenAmount(token: token0, amount: 1000),
                                     tokenAmountB: TokenAmount(token: token2, amount: 1100))
            let pair_0_3 = try! Pair(tokenAmountA: TokenAmount(token: token0, amount: 1000),
                                     tokenAmountB: TokenAmount(token: token3, amount: 900))
            let pair_1_2 = try! Pair(tokenAmountA: TokenAmount(token: token1, amount: 1200),
                                     tokenAmountB: TokenAmount(token: token2, amount: 1000))
            let pair_1_3 = try! Pair(tokenAmountA: TokenAmount(token: token1, amount: 1200),
                                     tokenAmountB: TokenAmount(token: token3, amount: 1300))
            let pair_wETH_0 = try! Pair(tokenAmountA: TokenAmount(token: Constant.wETH[.mainnet]!, amount: 1000),
                                        tokenAmountB: TokenAmount(token: token0, amount: 1000))
            let empty_pair_0_1 = try! Pair(tokenAmountA: TokenAmount(token: token0, amount: 0),
                                           tokenAmountB: TokenAmount(token: token1, amount: 0))
            let wETH = Constant.wETH[.mainnet]!
            
            it("can be constructed with ETHER as input") {
                
                let trade = try Trade(route: try Route(pairs: [pair_wETH_0],
                                                       input: wETH),
                                      amount: TokenAmount(token: wETH,
                                                          amount: 100),
                                      tradeType: .exactInput)
                
                expect(trade.inputAmount.token).to(equal(wETH))
                expect(trade.outputAmount.token).to(equal(token0))
            }
            
            it("can be constructed with ETHER as output") {
                let trade = try Trade(route: try Route(pairs: [pair_wETH_0],
                                                       input: token0),
                                      amount: TokenAmount(token: wETH,
                                                          amount: 100),
                                      tradeType: .exactOutput)
                expect(trade.inputAmount.token).to(equal(token0))
                expect(trade.outputAmount.token).to(equal(wETH))
            }
            
            it("can be constructed with ETHER as input for exact output") {
                let trade = try Trade(route: try Route(pairs: [pair_wETH_0],
                                                       input: wETH,
                                                       output: token0),
                                      amount: TokenAmount(token: token0,
                                                          amount: 100),
                                      tradeType: .exactOutput)
                expect(trade.inputAmount.token).to(equal(wETH))
                expect(trade.outputAmount.token).to(equal(token0))
            }
            
            it("can be constructed with ETHER as output") {
                let trade = try Trade(route: try Route(pairs: [pair_wETH_0],
                                                       input: token0),
                                      amount: TokenAmount(token: wETH,
                                                          amount: 100),
                                      tradeType: .exactOutput)
                expect(trade.inputAmount.token).to(equal(token0))
                expect(trade.outputAmount.token).to(equal(wETH))
            }
            
            it("can be constructed with ETHER as output for exact input") {
                let trade = try Trade(route: try Route(pairs: [pair_wETH_0],
                                                       input: token0,
                                                       output: wETH),
                                      amount: TokenAmount(token: token0,
                                                          amount: 100),
                                      tradeType: .exactInput)
                expect(trade.inputAmount.token).to(equal(token0))
                expect(trade.outputAmount.token).to(equal(wETH))
            }
            
            describe("#bestTradeExactIn") {
                
                it("throws with empty pairs") {
                    let originalAmount = TokenAmount(token: token0,
                                                     amount: 100)
                    expect(try Trade.bestTradeExactIn(pairs: [],
                                                      currencyAmountIn: originalAmount,
                                                      currencyOut: token2,
                                                      originalAmountIn: originalAmount)).to(throwError(TradeError.emptyPairs))
                }
                
                it("throws with max hops of 0") {
                    let originalAmount = TokenAmount(token: token0,
                                                     amount: 100)
                    expect(try Trade.bestTradeExactIn(pairs: [pair_0_2],
                                                      currencyAmountIn: originalAmount,
                                                      currencyOut: token2,
                                                      maxHops: 0,
                                                      originalAmountIn: originalAmount)).to(throwError(TradeError.zeroMaxHop))
                }
                
                it("provides best route") {
                    let originalAmount = TokenAmount(token: token0,
                                                     amount: 100)
                    let result = try Trade.bestTradeExactIn(pairs: [pair_0_1, pair_0_2, pair_1_2],
                                                            currencyAmountIn: originalAmount,
                                                            currencyOut: token2,
                                                            originalAmountIn: originalAmount)
                    expect(result).to(haveCount(2))
                    expect(result[0].route.pairs).to(haveCount(1)) // 0 -> 2 at 10:11
                    expect(result[0].route.path).to(equal([token0, token2]))
                    expect(result[0].inputAmount).to(equal(TokenAmount(token: token0, amount: 100)))
                    expect(result[0].outputAmount).to(equal(TokenAmount(token: token2, amount: 99)))
                    
                    expect(result[1].route.pairs).to(haveCount(2)) // 0 -> 1 -> 2 at 12:12:10
                    expect(result[1].route.path).to(equal([token0, token1, token2]))
                    expect(result[1].inputAmount).to(equal(TokenAmount(token: token0, amount: 100)))
                    expect(result[1].outputAmount).to(equal(TokenAmount(token: token2, amount: 69)))
                }
                
                it("doesnt throw for zero liquidity pairs") {
                    let originalAmount = TokenAmount(token: token0,
                                                     amount: 100)
                    expect(try Trade.bestTradeExactIn(pairs: [empty_pair_0_1],
                                                      currencyAmountIn: originalAmount,
                                                      currencyOut: token1,
                                                      originalAmountIn: originalAmount)).to(haveCount(0))
                }
                
                it("respects maxHops") {
                    let originalAmount = TokenAmount(token: token0,
                                                     amount: 10)
                    let result = try Trade.bestTradeExactIn(pairs: [pair_0_1, pair_0_2, pair_1_2],
                                                            currencyAmountIn: originalAmount,
                                                            currencyOut: token2,
                                                            maxHops: 1,
                                                            originalAmountIn: originalAmount)
                    
                    expect(result).to(haveCount(1))
                    expect(result[0].route.pairs).to(haveCount(1)) // 0 -> 2 at 10:11
                    expect(result[0].route.path).to(equal([token0, token2]))
                }
                
                it("insufficient input for one pair") {
                    let originalAmount = TokenAmount(token: token0,
                                                     amount: 1)
                    let result = try Trade.bestTradeExactIn(pairs: [pair_0_1, pair_0_2, pair_1_2],
                                                            currencyAmountIn: originalAmount,
                                                            currencyOut: token2,
                                                            originalAmountIn: originalAmount)
                    expect(result).to(haveCount(1))
                    expect(result[0].route.pairs).to(haveCount(1)) // 0 -> 2 at 10:11
                    expect(result[0].route.path).to(equal([token0, token2]))
                    expect(result[0].outputAmount).to(equal(TokenAmount(token: token2,
                                                                        amount: 1)))
                }
                
                it("respect n") {
                    let originalAmount = TokenAmount(token: token0,
                                                     amount: 10)
                    let result = try Trade.bestTradeExactIn(pairs: [pair_0_1, pair_0_2, pair_1_2],
                                                            currencyAmountIn: originalAmount,
                                                            currencyOut: token2,
                                                            maxNumResults: 1,
                                                            originalAmountIn: originalAmount)
                    
                    expect(result).to(haveCount(1))
                }
                
                it("no path") {
                    let originalAmount = TokenAmount(token: token0,
                                                     amount: 10)
                    let result = try Trade.bestTradeExactIn(pairs: [pair_0_1, pair_0_3, pair_1_3],
                                                            currencyAmountIn: originalAmount,
                                                            currencyOut: token2,
                                                            maxNumResults: 1,
                                                            originalAmountIn: originalAmount)
                    expect(result).to(haveCount(0))
                }
            }
            
            describe("#maximumAmountIn") {
                describe("tradeType = EXACT_INPUT") {
                    let exactIn = try! Trade(route: try! Route(pairs: [pair_0_1, pair_1_2],
                                                               input: token0),
                                             amount: TokenAmount(token: token0,
                                                                 amount: 100),
                                             tradeType: .exactInput)
                    
                    it("return exact if 0") {
                        expect(try exactIn.maximumAmountInput(slippageTolerance: Percent(numerator: 0,
                                                                                         denominator: 100)))
                        .to(equal(exactIn.inputAmount))
                    }
                    
                    it("returns exact if nonzero") {
                        expect(try exactIn.maximumAmountInput(slippageTolerance: Percent(numerator: 0,
                                                                                         denominator: 100)))
                        .to(equal(TokenAmount(token: token0,
                                              amount: 100)))
                        
                        expect(try exactIn.maximumAmountInput(slippageTolerance: Percent(numerator: 5,
                                                                                         denominator: 100)))
                        .to(equal(TokenAmount(token: token0,
                                              amount: 100)))
                        
                        expect(try exactIn.maximumAmountInput(slippageTolerance: Percent(numerator: 200,
                                                                                         denominator: 100)))
                        .to(equal(TokenAmount(token: token0,
                                              amount: 100)))
                        
                    }
                }
                
                describe("tradeType = EXACT_OUTPUT") {
                    let exactOut = try! Trade(route: try! Route(pairs: [pair_0_1, pair_1_2],
                                                                input: token0),
                                              amount: TokenAmount(token: token2,
                                                                  amount: 100),
                                              tradeType: .exactOutput)
                    
                    it("return exact if 0") {
                        expect(try exactOut.maximumAmountInput(slippageTolerance: Percent(numerator: 0,
                                                                                          denominator: 100)))
                        .to(equal(exactOut.inputAmount))
                    }
                    
                    it("returns slippage amount if nonzero") {
                        expect(try exactOut.maximumAmountInput(slippageTolerance: Percent(numerator: 0,
                                                                                          denominator: 100)))
                        .to(equal(TokenAmount(token: token0,
                                              amount: 156)))
                        
                        expect(try exactOut.maximumAmountInput(slippageTolerance: Percent(numerator: 5,
                                                                                          denominator: 100)))
                        .to(equal(TokenAmount(token: token0,
                                              amount: 163)))
                        
                        expect(try exactOut.maximumAmountInput(slippageTolerance: Percent(numerator: 200,
                                                                                          denominator: 100)))
                        .to(equal(TokenAmount(token: token0,
                                              amount: 468)))
                        
                    }
                }
            }
            
            describe("#minimumAmountOut") {
                describe("tradeType = EXACT_INPUT") {
                    let exactIn = try! Trade(route: try! Route(pairs: [pair_0_1, pair_1_2],
                                                               input: token0),
                                             amount: TokenAmount(token: token0,
                                                                 amount: 100),
                                             tradeType: .exactInput)
                    
                    it("returns exact if 0") {
                        expect(try exactIn.minimumAmountOut(slippageTolerance: Percent(numerator: 0,
                                                                                       denominator: 100)))
                        .to(equal(exactIn.outputAmount))
                    }
                    
                    it("returns exact if nonzero") {
                        expect(try exactIn.minimumAmountOut(slippageTolerance: Percent(numerator: 0,
                                                                                       denominator: 100)))
                        .to(equal(TokenAmount(token: token2,
                                              amount: 69)))
                        expect(try exactIn.minimumAmountOut(slippageTolerance: Percent(numerator: 5,
                                                                                       denominator: 100)))
                        .to(equal(TokenAmount(token: token2,
                                              amount: 65)))
                        expect(try exactIn.minimumAmountOut(slippageTolerance: Percent(numerator: 200,
                                                                                       denominator: 100)))
                        .to(equal(TokenAmount(token: token2,
                                              amount: 23)))
                    }
                }
                
                describe("tradeType = EXACT_OUTPUT") {
                    let exactOut = try! Trade(route: try! Route(pairs: [pair_0_1, pair_1_2],
                                                                input: token0),
                                              amount: TokenAmount(token: token2,
                                                                  amount: 100),
                                              tradeType: .exactOutput)
                    
                    it("returns exact if 0") {
                        expect(try exactOut.minimumAmountOut(slippageTolerance: Percent(numerator: 0,
                                                                                        denominator: 100)))
                        .to(equal(exactOut.outputAmount))
                    }
                    
                    it("returns exact if nonzero") {
                        expect(try exactOut.minimumAmountOut(slippageTolerance: Percent(numerator: 0,
                                                                                        denominator: 100)))
                        .to(equal(TokenAmount(token: token2,
                                              amount: 100)))
                        expect(try exactOut.minimumAmountOut(slippageTolerance: Percent(numerator: 5,
                                                                                        denominator: 100)))
                        .to(equal(TokenAmount(token: token2,
                                              amount: 100)))
                        expect(try exactOut.minimumAmountOut(slippageTolerance: Percent(numerator: 200,
                                                                                        denominator: 100)))
                        .to(equal(TokenAmount(token: token2,
                                              amount: 100)))
                    }
                }
            }
            
            describe("#bestTradeExactOut") {
                
                it("throws with empty pairs") {
                    let originalAmount = TokenAmount(token: token2,
                                                     amount: 100)
                    expect(try Trade.bestTradeExactOut(pairs: [],
                                                       currencyIn: token0,
                                                       currencyAmountOut: originalAmount,
                                                       originalAmountOut: originalAmount)).to(throwError(TradeError.emptyPairs))
                }
                
                it("throws with max hops of 0") {
                    let originalAmount = TokenAmount(token: token2,
                                                     amount: 100)
                    expect(try Trade.bestTradeExactOut(pairs: [pair_0_2],
                                                       currencyIn: token0,
                                                       currencyAmountOut: originalAmount,
                                                       maxHops: 0,
                                                       originalAmountOut: originalAmount)).to(throwError(TradeError.zeroMaxHop))
                }
                
                it("provides best route") {
                    let originalAmount = TokenAmount(token: token2,
                                                     amount: 100)
                    
                    let result = try Trade.bestTradeExactOut(pairs: [pair_0_1, pair_0_2, pair_1_2],
                                                             currencyIn: token0,
                                                             currencyAmountOut: originalAmount,
                                                             originalAmountOut: originalAmount)
                    
                    expect(result).to(haveCount(2))
                    expect(result[0].route.pairs).to(haveCount(1)) // 0 -> 2 at 10:11
                    expect(result[0].route.path).to(equal([token0, token2]))
                    expect(result[0].inputAmount).to(equal(TokenAmount(token: token0, amount: 101)))
                    expect(result[0].outputAmount).to(equal(TokenAmount(token: token2, amount: 100)))
                    
                    expect(result[1].route.pairs).to(haveCount(2)) // 0 -> 1 -> 2 at 12:12:10
                    expect(result[1].route.path).to(equal([token0, token1, token2]))
                    expect(result[1].inputAmount).to(equal(TokenAmount(token: token0, amount: 156)))
                    expect(result[1].outputAmount).to(equal(TokenAmount(token: token2, amount: 100)))
                }
                
                it("doesnt throw for zero liquidity pairs") {
                    let originalAmount = TokenAmount(token: token0,
                                                     amount: 100)
                    expect(try Trade.bestTradeExactOut(pairs: [empty_pair_0_1],
                                                       currencyIn: token1,
                                                       currencyAmountOut: originalAmount,
                                                       originalAmountOut: originalAmount)).to(haveCount(0))
                }
                
                it("respects maxHops") {
                    let originalAmount = TokenAmount(token: token2,
                                                     amount: 10)
                    let result = try Trade.bestTradeExactOut(pairs: [pair_0_1, pair_0_2, pair_1_2],
                                                             currencyIn: token0,
                                                             currencyAmountOut: originalAmount,
                                                             maxHops: 1,
                                                             originalAmountOut: originalAmount)
                    expect(result).to(haveCount(1))
                    expect(result[0].route.pairs).to(haveCount(1)) // 0 -> 2 at 10:11
                    expect(result[0].route.path).to(equal([token0, token2]))
                }
                
                it("insufficient liquidity") {
                    let originalAmount = TokenAmount(token: token2,
                                                     amount: 1200)
                    let result = try Trade.bestTradeExactOut(pairs: [pair_0_1, pair_0_2, pair_1_2],
                                                             currencyIn: token0,
                                                             currencyAmountOut: originalAmount,
                                                             maxHops: 1,
                                                             originalAmountOut: originalAmount)
                    
                      expect(result).to(haveCount(0))
                }
            
                it("insufficient liquidity in one pair but not the other") {
                    let originalAmount = TokenAmount(token: token2,
                                                     amount: 1050)
                    let result = try Trade.bestTradeExactOut(pairs: [pair_0_1, pair_0_2, pair_1_2],
                                                             currencyIn: token0,
                                                             currencyAmountOut: originalAmount,
                                                             originalAmountOut: originalAmount)
                    expect(result).to(haveCount(1))
                }

                it("respect n") {
                    let originalAmount = TokenAmount(token: token2,
                                                     amount: 10)
                    let result = try Trade.bestTradeExactOut(pairs: [pair_0_1, pair_0_2, pair_1_2],
                                                             currencyIn: token0,
                                                             currencyAmountOut: originalAmount,
                                                             maxNumResults: 1,
                                                             originalAmountOut: originalAmount)

                    expect(result).to(haveCount(1))
                }
                
                it("no path") {
                    let originalAmount = TokenAmount(token: token2,
                                                     amount: 10)
                    let result = try Trade.bestTradeExactOut(pairs: [pair_0_1, pair_0_3, pair_1_3],
                                                             currencyIn: token0,
                                                             currencyAmountOut: originalAmount,
                                                             maxNumResults: 1,
                                                             originalAmountOut: originalAmount)
                    expect(result).to(haveCount(0))
                }
            }
        }
    }
}
