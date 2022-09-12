//
//  RouteTests.swift
//  PancakeSDK-swiftTests
//
//  Created by Peerasak Unsakon on 9/9/2565 BE.
//

import XCTest
import BigInt
import Quick
import Nimble
import AvantisSwapSDK

class RouteTests: QuickSpec {

    
    override func spec() {
        
        describe("Route") {
            
            let token0 = Token(chainId: ChainId.mainnet,
                             address: "0x0000000000000000000000000000000000000001",
                             decimals: 18,
                             symbols: "t0",
                             name: "Token 0")
            let token1 = Token(chainId: ChainId.mainnet,
                            address: "0x0000000000000000000000000000000000000002",
                            decimals: 18,
                            symbols: "t1",
                            name: "Token 1")
            let wETH = Constant.wETH[ChainId.mainnet]!
            
            let pair_0_1 = try! Pair(tokenAmountA: TokenAmount(token: token0,
                                                          amount: 100),
                                tokenAmountB: TokenAmount(token: token1,
                                                          amount: 200))
            let pair_0_weth = try! Pair(tokenAmountA: TokenAmount(token: token0,
                                                                 amount: 100),
                                       tokenAmountB: TokenAmount(token: wETH,
                                                                 amount: 100))
            let pair_1_weth = try! Pair(tokenAmountA: TokenAmount(token: token1,
                                                                 amount: 175),
                                       tokenAmountB: TokenAmount(token: wETH,
                                                                 amount: 100))
            
            
            it("constructs a path from the tokens") {
                let route = try Route(pairs: [pair_0_1],
                                      input: token0)
                
                expect(route.pairs).to(equal([pair_0_1]))
                expect(route.path).to(equal([token0, token1]))
                expect(route.input.equalTo(token0)).to(equal(true))
                expect(route.output.equalTo(token1)).to(equal(true))
                expect(route.chainID).to(equal(ChainId.mainnet))
            }
            
            it("can have a token as both input and output") {
                let route = try Route(pairs: [pair_0_weth, pair_0_1, pair_1_weth],
                                      input: wETH)
                expect(route.pairs).to(equal([pair_0_weth, pair_0_1, pair_1_weth]))
                expect(route.input.equalTo(wETH)).to(equal(true))
                expect(route.output.equalTo(wETH)).to(equal(true))
            }
            
            it("supports ether input") {
                let route = try Route(pairs: [pair_0_weth],
                                      input: wETH)
                expect(route.pairs).to(equal([pair_0_weth]))
                expect(route.input.equalTo(wETH)).to(equal(true))
                expect(route.output.equalTo(token0)).to(equal(true))
            }
            

            it("supports ether output") {
                let route = try Route(pairs: [pair_0_weth],
                                      input: wETH)
                expect(route.pairs).to(equal([pair_0_weth]))
                expect(route.input.equalTo(wETH)).to(equal(true))
                expect(route.output.equalTo(token0)).to(equal(true))
            }
        }
    }
}
