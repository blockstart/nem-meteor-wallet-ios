//
//  TransactionInfo.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/31/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import Foundation

struct TransactionInfo: Serializable {
    var hash = Hash()
    var height = 0
    var id = 0
}
