//
//  XemNIS1.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/31/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

#if NIS1
import Foundation

extension Xem: NIS1 {
    typealias NIS1JSON = XemJSON
    typealias JSONModel = Xem
    
    static func fromNIS1JSON(json: XemJSON) -> Xem {
        var xem = Xem()
        xem.quantity = json.quantity ?? 0
        if let mi = json.mosaicId {
            xem.mosaicId = MosaicId.fromNIS1JSON(json: mi)
        }
        return xem
    }
}
#endif
