//
//  FractionTests.swift
//  PancakeSDK-swiftTests
//
//  Created by IntrodexMac on 7/9/2565 BE.
//

import XCTest
import BigInt
import Quick
import Nimble
import AvantisSwapSDK

class FractionSpec: QuickSpec {
    
    override func spec() {
        
        describe("#quotient") {
            it("floor division") {
                
                // one below
                expect(Fraction(numerator: BigUInt(8), denominator: BigUInt(3)).quotient).to(equal(BigUInt(2)))
                // exact
                expect(Fraction(numerator: BigUInt(12), denominator: BigUInt(4)).quotient).to(equal(BigUInt(3)))
                // one above
                expect(Fraction(numerator: BigUInt(16), denominator: BigUInt(5)).quotient).to(equal(BigUInt(3)))
            }
        }
        
        describe("#remainder") {
            it("returns fraction after divison") {
                expect(Fraction(numerator: BigUInt(8), denominator: BigUInt(3)).remainder)
                    .to(equal(Fraction(numerator: BigUInt(2), denominator: BigUInt(3))))
                
                expect(Fraction(numerator: BigUInt(12), denominator: BigUInt(4)).remainder)
                    .to(equal(Fraction(numerator: BigUInt(0), denominator: BigUInt(4))))
                
                expect(Fraction(numerator: BigUInt(16), denominator: BigUInt(5)).remainder)
                    .to(equal(Fraction(numerator: BigUInt(1), denominator: BigUInt(5))))
            }
        }
        
        describe("#invert") {
            it("flips num and denom") {
                expect(Fraction(numerator: BigUInt(5), denominator: BigUInt(10)).invert().numerator)
                    .to(equal(BigUInt(10)))
                
                expect(Fraction(numerator: BigUInt(5), denominator: BigUInt(10)).invert().denominator)
                    .to(equal(BigUInt(5)))
            }
        }
        
        describe("#add") {
            
            it("multiples denoms and adds nums") {
                let base = Fraction(numerator: BigUInt(1), denominator: BigUInt(10))
                let other = Fraction(numerator: BigUInt(4), denominator: BigUInt(12))
                
                expect(base.add(other))
                    .to(equal(Fraction(numerator: BigUInt(52), denominator: BigUInt(120))))
            }
            
            it("same denom") {
                let base = Fraction(numerator: BigUInt(1), denominator: BigUInt(5))
                let other = Fraction(numerator: BigUInt(2), denominator: BigUInt(5))
                
                expect(base.add(other))
                    .to(equal(Fraction(numerator: BigUInt(3), denominator: BigUInt(5))))
            }
            
        }
        
        describe("#substract") {
            it("multiples denoms and subtracts nums") {
                let base = Fraction(numerator: BigUInt(8), denominator: BigUInt(10))
                let other = Fraction(numerator: BigUInt(4), denominator: BigUInt(12))
                
                expect(base.substract(other))
                    .to(equal(Fraction(numerator: BigUInt(56), denominator: BigUInt(120))))
                
            }
            
            it("same denom") {
                let base = Fraction(numerator: BigUInt(3), denominator: BigUInt(5))
                let other = Fraction(numerator: BigUInt(2), denominator: BigUInt(5))
                
                expect(base.substract(other))
                    .to(equal(Fraction(numerator: BigUInt(1), denominator: BigUInt(5))))
            }
            
        }
        
        describe("#multiply") {
            it("correct") {
                let base = Fraction(numerator: BigUInt(1), denominator: BigUInt(10))
                let base2 = Fraction(numerator: BigUInt(1), denominator: BigUInt(3))
                let base3 = Fraction(numerator: BigUInt(5), denominator: BigUInt(12))
                let other = Fraction(numerator: BigUInt(4), denominator: BigUInt(12))
                
                expect(base.multiply(other))
                    .to(equal(Fraction(numerator: BigUInt(4), denominator: BigUInt(120))))
                
                expect(base2.multiply(other))
                    .to(equal(Fraction(numerator: BigUInt(4), denominator: BigUInt(36))))
                
                expect(base3.multiply(other))
                    .to(equal(Fraction(numerator: BigUInt(20), denominator: BigUInt(144))))
                
            }
        }
        
        describe("#divide") {
            it("correct") {
                let base = Fraction(numerator: BigUInt(1), denominator: BigUInt(10))
                let base2 = Fraction(numerator: BigUInt(1), denominator: BigUInt(3))
                let base3 = Fraction(numerator: BigUInt(5), denominator: BigUInt(12))
                let other = Fraction(numerator: BigUInt(4), denominator: BigUInt(12))
                
                expect(base.divide(other))
                    .to(equal(Fraction(numerator: BigUInt(12), denominator: BigUInt(40))))
                
                expect(base2.divide(other))
                    .to(equal(Fraction(numerator: BigUInt(12), denominator: BigUInt(12))))
                
                expect(base3.divide(other))
                    .to(equal(Fraction(numerator: BigUInt(60), denominator: BigUInt(48))))
            }
        }
        
        describe("#lessThan") {
            it("correct") {
                let base = Fraction(numerator: BigUInt(1), denominator: BigUInt(10))
                let base2 = Fraction(numerator: BigUInt(1), denominator: BigUInt(3))
                let base3 = Fraction(numerator: BigUInt(5), denominator: BigUInt(12))
                let other = Fraction(numerator: BigUInt(4), denominator: BigUInt(12))
                
                expect(base.lessThan(other))
                    .to(equal(true))
                
                expect(base2.lessThan(other))
                    .to(equal(false))
                
                expect(base3.lessThan(other))
                    .to(equal(false))
            }
        }
        
        describe("#equalTo") {
            it("correct") {
                let base = Fraction(numerator: BigUInt(1), denominator: BigUInt(10))
                let base2 = Fraction(numerator: BigUInt(1), denominator: BigUInt(3))
                let base3 = Fraction(numerator: BigUInt(5), denominator: BigUInt(12))
                let other = Fraction(numerator: BigUInt(4), denominator: BigUInt(12))
                
                expect(base.equalTo(other))
                    .to(equal(false))
                
                expect(base2.equalTo(other))
                    .to(equal(true))
                
                expect(base3.equalTo(other))
                    .to(equal(false))
            }
        }
        
        describe("#greaterThan") {
            it("correct") {
                let base = Fraction(numerator: BigUInt(1), denominator: BigUInt(10))
                let base2 = Fraction(numerator: BigUInt(1), denominator: BigUInt(3))
                let base3 = Fraction(numerator: BigUInt(5), denominator: BigUInt(12))
                let other = Fraction(numerator: BigUInt(4), denominator: BigUInt(12))
                
                expect(base.greaterThan(other))
                    .to(equal(false))
                
                expect(base2.greaterThan(other))
                    .to(equal(false))
                
                expect(base3.greaterThan(other))
                    .to(equal(true))
            }
        }
        
        describe("#asFraction") {
            it("returns an equivalent but not the same reference fraction") {
                
                let f = Fraction(numerator: 1,
                                 denominator: 2)
                expect(f.asFraction)
                    .to(equal(f))
                
                expect(f.asFraction === f)
                    .to(equal(false))
            }
        }
        
        describe("#toSignificant") {
            it("correct") {
                let base = Fraction(numerator: BigUInt(22), denominator: BigUInt(7)) // 3.142 8 571429
                let base2 = Fraction(numerator: BigUInt(500))
                
                expect(try base.toSignificant(4, rounding: .halfUp))
                .to(equal("3.143"))
                
                expect(try base.toSignificant(4, rounding: .halfDown))
                .to(equal("3.143"))
                
                expect(try base.toSignificant(4, rounding: .down))
                .to(equal("3.142"))
                
                expect(try base2.toSignificant(4, rounding: .halfUp))
                .to(equal("500"))
                
            }
            
            it("zero significant") {
                let base = Fraction(numerator: BigUInt(22), denominator: BigUInt(7)) // 3.142 8 571429
                
                expect {
                    try base.toSignificant(0, rounding: .halfUp)
                }.to(throwError(Fraction.FractionError.isNotPositive(significantDigits: 0)))
            }
        }
        
        describe("#toFixed") {
            it("correct") {
                let base = Fraction(numerator: BigUInt(22), denominator: BigUInt(7)) // 3.142 8 571429
                let base2 = Fraction(numerator: BigUInt(500))
                
                expect(try base.toFixed(4, rounding: .halfUp))
                .to(equal("3.1429"))
                
                expect(try base.toFixed(4, rounding: .halfDown))
                .to(equal("3.1429"))
                
                expect(try base.toFixed(4, rounding: .down))
                .to(equal("3.1428"))
                
                expect(try base2.toFixed(4, rounding: .halfUp))
                .to(equal("500.0000"))
            }
            
        }
        
    }
    
}

