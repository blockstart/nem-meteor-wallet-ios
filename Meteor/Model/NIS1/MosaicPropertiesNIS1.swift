//
//  MosaicPropertiesNIS1.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/31/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

#if NIS1
import Foundation

extension MosaicProperties: NIS1 {
    typealias NIS1JSON = MosaicPropertiesJSON
    typealias JSONModel = MosaicProperties
    
    static func fromNIS1JSON(json: MosaicPropertiesJSON) -> MosaicProperties {
        var mosaicProperties = MosaicProperties()
        mosaicProperties.initialSupply = json.initialSupply ?? 0
        mosaicProperties.supplyMutable = json.supplyMutable ?? false
        mosaicProperties.transferable = json.transferable ?? false
        mosaicProperties.divisibility = json.divisibility ?? 0
        return mosaicProperties
    }
}
#endif
