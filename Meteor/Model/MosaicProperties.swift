//
//  MosaicProperties.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/31/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import Foundation

struct MosaicProperties: Serializable {
    var initialSupply: UInt = 0
    var supplyMutable = false
    var transferable = false
    var divisibility = 0
}
