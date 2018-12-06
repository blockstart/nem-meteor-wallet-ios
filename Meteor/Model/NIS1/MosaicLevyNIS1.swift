//
//  MosaicLevyNIS1.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/31/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

#if NIS1
import Foundation

extension MosaicLevy: NIS1 {
    typealias NIS1JSON = MosaicLevyJSON
    typealias JSONModel = MosaicLevy
    
    static func fromNIS1JSON(json: MosaicLevyJSON) -> MosaicLevy {
        var mosaicLevy = MosaicLevy()
        mosaicLevy.type = json.type ?? 0
        mosaicLevy.recipient = json.recipient?.value ?? ""
        if let mi = json.mosaicId {
            mosaicLevy.mosaicId = MosaicId.fromNIS1JSON(json: mi)
        }
        mosaicLevy.fee = json.fee ?? 0
        return mosaicLevy
    }
}
#endif
