//
//  MosaicIdNIS1.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/31/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

#if NIS1
import Foundation

extension MosaicId: NIS1 {
    typealias NIS1JSON = MosaicIdJSON
    typealias JSONModel = MosaicId
    
    static func fromNIS1JSON(json: MosaicIdJSON) -> MosaicId {
        var mosaicId = MosaicId()
        mosaicId.namespaceId = json.namespaceId ?? ""
        mosaicId.name = json.name ?? ""
        return mosaicId
    }
}
#endif
