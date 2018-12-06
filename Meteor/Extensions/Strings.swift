//
//  Strings.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/28/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import CryptoSwift

extension String {
    mutating func pretty() -> String {
        while let pos = self.index(of: "-") {
            self.remove(at: pos)
        }
        return self
    }
    
    mutating func trim() -> String {
        while let pos = self.index(of: " ") {
            self.remove(at: pos)
        }
        return self
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var formatTimestamp: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale.current
        let date = dateFormatter.date(from: self) ?? Date()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from:date)
    }
    
    var removeUnsupportedCharacters: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return self.filter {okayChars.contains($0) }
    }
    
    func toApiReadable(_ div: Int) -> Int {
        let locale = NSLocale.current
        let seperator = locale.decimalSeparator ?? "."
        var expo = div
        if let decimal: Range<String.Index> = self.range(of: seperator) {
            let index = self.distance(from: self.endIndex, to: decimal.upperBound)
            expo += index
        }
        let numWithoutDecimal = self.replacingOccurrences(of: seperator, with: "")
        guard let num = UInt64(numWithoutDecimal) else { return 0 }
        let dec = NSDecimalNumber(mantissa: num, exponent: Int16(expo), isNegative: false)
        guard let decimalNumber = Int(exactly: dec) else { return 0 }
        return decimalNumber
    }
    
    mutating func decimalFormat(_ div: Int) -> NSDecimalNumber {
        if self.count <= div {
            let zerosToAdd = div - self.count
            for _ in 0...zerosToAdd {
                self.insert("0", at: self.startIndex)
            }
        }
        let locale = NSLocale.current
        let separator: Character = Character(locale.decimalSeparator ?? ".")
        self.insert(separator, at: self.index(self.endIndex, offsetBy: -div))
        return NSDecimalNumber(string: self)
    }
    
    func decimalIndex() -> Int {
        let locale = NSLocale.current
        let seperator = locale.decimalSeparator ?? "."
        if let decimal: Range<String.Index> = self.range(of: seperator) {
            return abs(self.distance(from: self.endIndex, to: decimal.upperBound))
        }
        return 0
    }
    
    func hexa2Bytes() -> [UInt8] {
        let hexa = Array(self)
        return stride(from: 0, to: count, by: 2).compactMap { UInt8(String(hexa[$0..<$0.advanced(by: 2)]), radix: 16) }
    }
    
    /**
     * Since mobile apps transmit data via REST to the internal API
     * it is possible for other devices on the same network to
     * sniff the data and read it.  Therefore we encrypt data transmissions.
     * Change these keys for your own project. Keys here should match
     * the keys you enter in the API
     */
    func decrypt() throws -> String {
        let encrypted = self.hexa2Bytes()
        let decryptedText  = try AES(key: "<enter unique key here>", iv: "<enter unique key here>").decrypt(encrypted)
        let data = Data(bytes: decryptedText, count: decryptedText.count)
        return String(bytes: data, encoding: .utf8) ?? ""
    }
    
    func encrypt() throws -> String {
        let digest = Array(self.utf8)
        let encryptedString = try AES(key: "<enter unique key here>", iv: "<enter unique key here>").encrypt(digest).toHexString()
        return encryptedString
    }
}
