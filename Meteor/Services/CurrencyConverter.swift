//
//  CurrencyConverter.swift
//  Meteor
//
//  Created by Nathan Brewer on 8/27/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import Alamofire

struct CurrentMosaicsRate {
    var localeSymbol = "$"
    var localeCode = "USD"
    var exchangeRate = "0"
    
    init(_ symbol: String, rate: String, code: String) {
        localeSymbol = symbol
        exchangeRate = rate
        localeCode = code
    }
}

class CurrencyConverter {
    static let instance = CurrencyConverter()
    private let BASE_URL = "https://min-api.cryptocompare.com/data/pricemultifull?fsyms="
    private let XEM = "XEM"
    private let SECOND_SYM = "&tsyms="
    private let LOCALE_CODE = "localeCode"
    private let DISPLAY = "DISPLAY"
    private let RAW = "RAW"
    private let PRICE = "PRICE"
    private let SYMBOL = "TOSYMBOL"
    static public var currentMosaicsRate : CurrentMosaicsRate!
    public var localeCode: String {
        get {
            return UserDefaults.standard.string(forKey: LOCALE_CODE) ?? CurrencyStrings.USD
        }
        set {
            UserDefaults.standard.set(newValue, forKey: LOCALE_CODE)
        }
    }
    
    func convert(_ convertFrom: String, completion: @escaping (Bool) -> ()) {
        let localeCode = self.localeCode
        if let url = URL(string: BASE_URL + convertFrom.uppercased() + SECOND_SYM + localeCode) {
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.get.rawValue
            Alamofire.request(request).responseJSON { (response) in
                if let result = response.value as? Dictionary<String, AnyObject> {
                    let symbol = self.getLocaleSymbol(result, currencyCode: convertFrom.uppercased())
                    let price = self.getPrice(result, currencyCode: convertFrom.uppercased())
                    CurrencyConverter.currentMosaicsRate = CurrentMosaicsRate(symbol, rate: "\(price)", code: localeCode)
                    completion(true)
                } else {
                    CurrencyConverter.currentMosaicsRate = CurrentMosaicsRate("$", rate: "0", code: localeCode)
                    completion(true)
                }
            }
        }
    }
    
    func getLocaleSymbol(_ data: Dictionary<String, AnyObject>, currencyCode: String) -> String {
        if let displayData = data[self.DISPLAY] as? Dictionary<String, AnyObject>,
            let mosaic = displayData[currencyCode] as? Dictionary<String, AnyObject>,
            let denomination = mosaic[self.localeCode] as? Dictionary<String, AnyObject>,
            let symbol = denomination[self.SYMBOL] as? String {
            return symbol
        } else { return "$" }
    }
    
    func getPrice(_ data: Dictionary<String, AnyObject>, currencyCode: String) -> NSDecimalNumber {
        if let rawData = data[self.RAW] as? Dictionary<String, AnyObject>,
            let mosaic = rawData[currencyCode] as? Dictionary<String, AnyObject>,
            let denomination = mosaic[self.localeCode] as? Dictionary<String, AnyObject>,
            let price = denomination[self.PRICE] as? Double {
            return NSDecimalNumber(string: "\(price)")
        } else { return 0.0 }
    }
    
    func localXemRate(_ completion: @escaping (String) -> ()) {
        let localeCode = self.localeCode
        if let url = URL(string: BASE_URL + XEM + SECOND_SYM + localeCode) {
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.get.rawValue
            Alamofire.request(request).responseJSON { (response) in
                if let result = response.value as? Dictionary<String, AnyObject>,
                    let displayData = result[self.DISPLAY] as? Dictionary<String, AnyObject>,
                    let xem = displayData[self.XEM] as? Dictionary<String, AnyObject>,
                    let denomination = xem[localeCode] as? Dictionary<String, AnyObject>,
                    let price = denomination[self.PRICE] as? String {
                    completion(price)
                }
            }
        }
    }
    
}
 



