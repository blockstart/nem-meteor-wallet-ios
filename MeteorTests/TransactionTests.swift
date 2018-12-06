//
//  TransactionTests.swift
//  MeteorTests
//
//  Created by Nathan Brewer on 9/6/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import XCTest

class TransactionTests: XCTestCase {
    
    var testMosaic: Mosaic!
    
    override func setUp() {
        super.setUp()
        testMosaic = createTestingMosaic()
    }
    
    override func tearDown() {
        super.tearDown()
        testMosaic = nil
    }
    
    func testOverflowBuffer() {
        let leftSide = OverflowBuffer(value: "10")
        let rightSide = OverflowBuffer(value: "10")
        let result = leftSide * rightSide
        XCTAssertEqual(result.value, "100")
        
        let zeroOnLeft = OverflowBuffer(value: "0")
        let zeroOnRight = OverflowBuffer(value: "0")
        let outcome = zeroOnLeft * zeroOnRight
        XCTAssertEqual(outcome.value, "0")
        
        let overflowIntOne = OverflowBuffer(value: "12345678901234567890")
        let multiplierInt = OverflowBuffer(value: "1000")
        let overflowResult = overflowIntOne * multiplierInt
        XCTAssertEqual(overflowResult.value, "12345678901234567890000")
    }
    
    func testOverflowToDecimalNumber() {
        var largeNumber = "12345678901234567890"
        let decimalNumber = largeNumber.decimalFormat(6)
        let localeString = decimalNumber.thousandsSeparator(2)
        XCTAssertEqual(localeString, "12,345,678,901,234.57")
        
        let bitcoinValueString = decimalNumber.thousandsSeparator(8)
        XCTAssertEqual(bitcoinValueString, "12,345,678,901,234.56789")
    }
    
    func testMosaicQuantity() {
        XCTAssertEqual(testMosaic.mosaicId.name, "Cache")
        XCTAssertEqual(testMosaic.quantity, 1000123456)
        
        let formattedQuantity = testMosaic.quantity.decimalFormat(testMosaic.properties.divisibility)
        let stringQuantity = formattedQuantity.thousandsSeparator(testMosaic.properties.divisibility)
        XCTAssertEqual(stringQuantity, "1,000.123456")
        
        let fee = 50000
        XCTAssertEqual(fee.decimalFormat(6), 0.05)
        
        let mosaicQuantity = 6000
        let divisibility = 3
        XCTAssertEqual(mosaicQuantity.decimalFormat(divisibility), 6.000)
    }
    
    func testUserInputFormatsToApiQuantity() {
        let userInput = "55.05"
        var apiInt = userInput.toApiReadable(6)
        XCTAssertEqual(apiInt, 55050000)
        
        let anotherInput = "100000"
        apiInt = anotherInput.toApiReadable(3)
        XCTAssertEqual(apiInt, 100000000)
        
    }
    
    func testDecimalIndex() {
        var numberString = "100"
        XCTAssertEqual(numberString.decimalIndex(), 0)
        
        numberString = "10.005"
        XCTAssertEqual(numberString.decimalIndex(), 3)
        
        numberString = "1.123456"
        XCTAssertEqual(numberString.decimalIndex(), 6)
        
        numberString = "12345.67"
        XCTAssertEqual(numberString.decimalIndex(), 2)
    }
    
    func testMosaicQuantityConvertsToLocaleValue() {
        let mosaicQuantity = 100123456
        MockedCurrencyConverter.mockApiConversionResponse(locale: "$", rate: "0.0875", code: "USD")
        let convertedNumber = mosaicQuantity.localeValue(6)
        XCTAssertEqual(convertedNumber, "$ 8.76 (USD)")
        
        MockedCurrencyConverter.mockApiConversionResponse(locale: "¥", rate: "9.88", code: "JPY")
        let japaneseConvertedNumber = mosaicQuantity.localeValue(6)
        XCTAssertEqual(japaneseConvertedNumber, "¥ 989.22 (JPY)")
        
        let largeMosaicQuantity = 10000000123456
        MockedCurrencyConverter.mockApiConversionResponse(locale: "$", rate: "0.98765", code: "USD")
        let intOverflowNumber = largeMosaicQuantity.localeValue(6)
        XCTAssertEqual(intOverflowNumber, "$ 9,876,500.12 (USD)")
        
        let zeroBalance = 0
        let smallBalance = 10000
        MockedCurrencyConverter.mockApiConversionResponse(locale: "$", rate: "0.90795", code: "USD")
        let formattedBalance = zeroBalance.localeValue(6)
        XCTAssertEqual(formattedBalance, "$ 0 (USD)")
        
        let smallbal = smallBalance.localeValue(6)
        XCTAssertEqual(smallbal, "$ 0.01 (USD)")
    }
    
    func testLocaleValueInputConvertsToMosaicAmount() {
        let userInput = "100.05"
        MockedCurrencyConverter.mockApiConversionResponse(locale: "$", rate: "0.0875", code: "USD")

        //input first becomes an Int in API format
        let decimalIndex = userInput.decimalIndex()
        let intValue = userInput.toApiReadable(decimalIndex)
        XCTAssertEqual(decimalIndex, 2)
        XCTAssertEqual(intValue, 10005)
        
        let cryptoValue = intValue.cryptoValueFromLocale(6, inputIndex: decimalIndex)
        XCTAssertEqual(cryptoValue, "1,143.428571")
        
        let largeUserInput = "1234567890.123456"
        MockedCurrencyConverter.mockApiConversionResponse(locale: "$", rate: "0.987654", code: "USD")
        let decIndex = largeUserInput.decimalIndex()
        XCTAssertEqual(decIndex, 6)
        
        let apiIntValue = largeUserInput.toApiReadable(decIndex)
        XCTAssertEqual(apiIntValue, 1234567890123456)
        
        let crypValue = apiIntValue.cryptoValueFromLocale(6, inputIndex: decIndex)
        XCTAssertEqual(crypValue, "1,250,000,395.000128")
    }
    
    func createTestingMosaic() -> Mosaic {
        var mos = Mosaic()
        mos.isXEM = false
        mos.properties.divisibility = 6
        mos.mosaicId.name = "Cache"
        mos.mosaicId.namespaceId = "Cache"
        mos.quantity = 1000123456
        mos.ticker = "CHE"
        return mos
    }
}
