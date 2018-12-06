//
//  Double.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/29/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

struct OverflowBuffer {
    var value: String
    
    func multiply(right: OverflowBuffer) -> OverflowBuffer {
        var leftCharArray: [Int] {
            return value.reversed().map { Int(String($0)) ?? 0 }
        }
        var rightCharArray: [Int] {
            return right.value.reversed().map { Int(String($0)) ?? 0 }
        }
        var result = [Int](repeating: 0, count: leftCharArray.count + rightCharArray.count)
        
        for leftIndex in 0..<leftCharArray.count {
            for rightIndex in 0..<rightCharArray.count {
                
                let resultIndex = leftIndex + rightIndex
                
                result[resultIndex] = leftCharArray[leftIndex] * rightCharArray[rightIndex] + (resultIndex >= result.count ? 0 : result[resultIndex])
                if result[resultIndex] > 9 {
                    result[resultIndex + 1] = (result[resultIndex] / 10) + (resultIndex + 1 >= result.count ? 0 : result[resultIndex + 1])
                    result[resultIndex] -= (result[resultIndex] / 10) * 10
                }
            }
        }
        
        result = Array(result.reversed())
        var stringValue: String {
            var string = result.map { String($0) }.joined(separator: "")
            if string.hasPrefix("0") && string.count > 1 {
                string = String(string.dropFirst())
            }
            return string
        }
        return  OverflowBuffer(value: stringValue)
    }
}

func * (left: OverflowBuffer, right: OverflowBuffer) -> OverflowBuffer { return left.multiply(right: right) }

extension Int {
    
    func decimalFormat(_ div: Int) -> NSDecimalNumber {
        return NSDecimalNumber(mantissa: UInt64(self), exponent: Int16(-div), isNegative: false)
    }
    
    func localeValue(_ div: Int) -> String {
        guard let mosaicRate = CurrencyConverter.currentMosaicsRate else { return "" }
        let index = mosaicRate.exchangeRate.decimalIndex()
        let rawRate = mosaicRate.exchangeRate.toApiReadable(index)
        let rawRateBuffer = OverflowBuffer(value: "\(rawRate)")
        let quantityBuffer = OverflowBuffer(value: "\(self)")
        var total = rawRateBuffer * quantityBuffer
        let decimalPlaces = mosaicRate.localeCode == "BTC" ? 8 : 2
        let formattedTotal = total.value.decimalFormat(div + index).thousandsSeparator(decimalPlaces)
        return "\(mosaicRate.localeSymbol) \(formattedTotal) (\(mosaicRate.localeCode))"
    }
    
    func cryptoValueFromLocale(_ div: Int, inputIndex: Int) -> String {
        guard let mosaicRate = CurrencyConverter.currentMosaicsRate else { return "" }
        let index = mosaicRate.exchangeRate.decimalIndex()
        let rawRate = mosaicRate.exchangeRate.toApiReadable(index)
        let total: Double = Double(self) / Double(rawRate)
        let totalIndex = "\(total)".decimalIndex()
        let rawTotal = "\(total)".toApiReadable(totalIndex)
        return rawTotal.decimalFormat(totalIndex - index + inputIndex).thousandsSeparator(div)
    }
}

extension NSDecimalNumber {
    
    func thousandsSeparator(_ decimalPlaces: Int) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = NumberFormatter.Style.decimal
        nf.maximumFractionDigits = decimalPlaces
        return nf.string(from: self) ?? ""
    }
}




