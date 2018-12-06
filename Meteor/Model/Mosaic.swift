//
//  Mosaic.swift
//  Meteor
//
//  Created by Mark Price on 7/25/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import Foundation

struct Mosaic: Serializable {
    static let XEM = "xem"
    
    var mosaicId = MosaicId()
    var properties = MosaicProperties()
    var levy = MosaicLevy()
    var quantity: Int = 0
    var ticker: String?
    var isXEM = true
    
    static func ticker(mosaicName: String, namespace: String) -> String? {
        guard let path = Bundle.main.path(forResource: "mosaics", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path),
            let mosaics = dict.object(forKey: "mosaics" as Any) as? Dictionary<String, String>,
            let ticker = mosaics["\(namespace)\(mosaicName)"] else { return nil }
        return ticker
    }
}
