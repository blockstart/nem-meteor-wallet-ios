//
//  MosaicLevy.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/31/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import Foundation

struct MosaicLevy: Serializable {
    var type = 0
    var recipient = ""
    var mosaicId = MosaicId()
    var fee = 0
}
