//
//  DeepLinkTests.swift
//  MeteorTests
//
//  Created by Nathan Brewer on 10/8/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import XCTest

class DeepLinkTests: XCTestCase {
    
    var urlComponent: NSURLComponents?

    override func setUp() {
        let urlComp = NSURLComponents()
        urlComp.scheme = SCHEME
        urlComp.host = HOST
        urlComp.path = PATH
        let address = NSURLQueryItem(name: RECIPIENT, value: "UserAddress")
        let amount = NSURLQueryItem(name: AMOUNT, value: "100")
        let currency = NSURLQueryItem(name: CURRENCY, value: "cache")
        urlComponent = urlComp
        urlComponent?.queryItems = [address, amount, currency] as [URLQueryItem]
    }

    override func tearDown() {
        urlComponent = nil
        Deeplinker.clearUserDefaults()
    }
    
    func testDeepLinking() {
        XCTAssertTrue(Deeplinker.handleDeeplink(url: (urlComponent?.url)!))
        XCTAssertEqual(Deeplinker.requestAddress, "UserAddress")
        XCTAssertEqual(Deeplinker.requestAmount, "100")
        XCTAssertEqual(Deeplinker.requestMosaic, "cache")
        
        Deeplinker.clearUserDefaults()
        
        XCTAssertNil(Deeplinker.requestAddress)
        XCTAssertNil(Deeplinker.requestAmount)
        XCTAssertNil(Deeplinker.requestMosaic)
    }
    
    func testIncorrectDeepLinkURL() {
        urlComponent?.queryItems?.removeLast()
        
        XCTAssertNoThrow(Deeplinker.handleDeeplink(url: (urlComponent?.url)!))
        XCTAssertNoThrow(Deeplinker.checkDeepLink())
        XCTAssertNil(Deeplinker.requestAddress)
        XCTAssertNil(Deeplinker.requestAmount)
        XCTAssertNil(Deeplinker.requestMosaic)
    }

}
