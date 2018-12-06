//
//  HashNIS1.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/31/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

#if NIS1
import Foundation

extension Hash: NIS1 {
    typealias NIS1JSON = HashJSON
    typealias JSONModel = Hash
    
    static func fromNIS1JSON(json: HashJSON) -> Hash {
        var hash = Hash()
        hash.data = json.data ?? ""
        return hash
    }
}
#endif
