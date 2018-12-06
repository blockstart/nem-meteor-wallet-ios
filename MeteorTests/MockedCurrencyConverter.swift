//
//  MockedCurrencyConverter.swift
//  MeteorTests
//
//  Created by Nathan Brewer on 9/19/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

class MockedCurrencyConverter: CurrencyConverter {
    
    static func mockApiConversionResponse(locale: String, rate: String, code: String) {
        CurrencyConverter.currentMosaicsRate = CurrentMosaicsRate(locale, rate: rate, code: code)
    }
}

