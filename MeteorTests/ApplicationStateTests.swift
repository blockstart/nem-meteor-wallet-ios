//
//  ApplicationStateTests.swift
//  MeteorTests
//
//  Created by Mark Price on 8/31/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import XCTest

class ApplicationStateTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAddress() {
        let appState = AppState(selectedAddress: "address me address", addresses: ["address me address"], deviceToken: "", currentNetwork: NetworkTypeStrings.test)
        XCTAssertEqual("address me address", appState.selectedAddress)
        
        appState.save()
        
        let appState2 = AppState.fromCache()
        XCTAssertEqual("address me address", appState2.selectedAddress)
        
        appState2.delete()
        
        let appState3 = AppState.fromCache()
        XCTAssertEqual(appState3.selectedAddress, "")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
