//
//  TokenTests.swift
//  PancakeSDK-swiftTests
//
//  Created by IntrodexMac on 7/9/2565 BE.
//

import XCTest
import BigInt
import Quick
import Nimble
import AvantisSwapSDK

class TokenSpec: QuickSpec {
    
    override func spec() {
        
        describe("#equals") {
            it("fails if address differs") {
                let addressOne = "0x0000000000000000000000000000000000000001"
                let addressTwo = "0x0000000000000000000000000000000000000002"
                
                let tokenA = Token(chainId: .mainnet,
                                   address: addressOne,
                                   decimals: 18)
                let tokenB = Token(chainId: .mainnet,
                                   address: addressTwo,
                                   decimals: 18)
                
                expect(tokenA.equals(tokenB)).to(equal(false))
            }
            
            it("false if chain id differs") {
                let addressOne = "0x0000000000000000000000000000000000000001"
                
                let tokenA = Token(chainId: .testnet,
                                   address: addressOne,
                                   decimals: 18)
                let tokenB = Token(chainId: .mainnet,
                                   address: addressOne,
                                   decimals: 18)
                
                expect(tokenA.equals(tokenB)).to(equal(false))
            }
            
            it("true if only decimals differs") {
                let addressOne = "0x0000000000000000000000000000000000000001"
                
                let tokenA = Token(chainId: .mainnet,
                                   address: addressOne,
                                   decimals: 9)
                let tokenB = Token(chainId: .mainnet,
                                   address: addressOne,
                                   decimals: 18)
                
                expect(tokenA.equals(tokenB)).to(equal(true))
            }
            
            it("true if address is the same") {
                let addressOne = "0x0000000000000000000000000000000000000001"
                
                let tokenA = Token(chainId: .mainnet,
                                   address: addressOne,
                                   decimals: 18)
                let tokenB = Token(chainId: .mainnet,
                                   address: addressOne,
                                   decimals: 18)
                
                expect(tokenA.equals(tokenB)).to(equal(true))
            }
            
            it("true on reference equality") {
                let addressOne = "0x0000000000000000000000000000000000000001"
                
                let tokenA = Token(chainId: .mainnet,
                                   address: addressOne,
                                   decimals: 18)
                
                expect(tokenA.equals(tokenA)).to(equal(true))
            }
            
            it("true even if name/symbol/decimals differ") {
                let addressOne = "0x0000000000000000000000000000000000000001"
                
                let tokenA = Token(chainId: .mainnet,
                                   address: addressOne,
                                   decimals: 9,
                                   symbols: "abc",
                                   name: "def")
                let tokenB = Token(chainId: .mainnet,
                                   address: addressOne,
                                   decimals: 18,
                                   symbols: "ghi",
                                   name: "jkl")
                
                expect(tokenA.equals(tokenB)).to(equal(true))
            }
            
        }
        
    }
    
}
