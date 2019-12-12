//
//  Capital_iOSTests.swift
//  Capital.iOSTests
//
//  Created by Anton Sokolov on 01/10/2018.
//  Copyright © 2018 Anton Sokolov. All rights reserved.
//

import XCTest
@testable import Capital_iOS

class Capital_iOSTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testCurrencyExchange() {
        let usd_money = Money(amt: 10.00, currency: .USD)
        let eur_money = Money(amt: 400.00, currency: .EUR)
        let rub_money = Money(amt: 1000.00, currency: .RUB)
        
        XCTAssertEqual(usd_money.amount, 10, "Amount computed from USD is wrong")
        XCTAssertEqual(eur_money.amount, 400, "Amount computed from EUR is wrong")
        let sum = usd_money + eur_money
        XCTAssertEqual(sum.amount, 30430.10, "Score computed from guess is wrong")
        let sum2 = usd_money + eur_money + rub_money
        XCTAssertEqual(sum2.amount, 31430.1)
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
