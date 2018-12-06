//
//  MosaicNIS1.swift
//  Meteor
//
//  Created by Mark Price on 7/30/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//
#if NIS1
import Foundation

extension Mosaic: NIS1 {
    typealias NIS1JSON = MosaicJSON
    typealias JSONModel = Mosaic
    
    static func fromNIS1JSON(json: MosaicJSON) -> Mosaic {
        var mosaic = Mosaic()
        if let mi = json.mosaicId {
            mosaic.mosaicId = MosaicId.fromNIS1JSON(json: mi)
        }
        if let mp = json.properties {
            mosaic.properties = MosaicProperties.fromNIS1JSON(json: mp)
        }
        if let levy = json.levy {
            mosaic.levy = MosaicLevy.fromNIS1JSON(json: levy)
        }
        mosaic.quantity = json.quantity ?? 0
        mosaic.ticker = Mosaic.ticker(mosaicName: mosaic.mosaicId.name, namespace: mosaic.mosaicId.namespaceId)
        mosaic.isXEM = json.mosaicId?.name?.lowercased() == Mosaic.XEM
        return mosaic
    }
}
#endif
