//
//  AddressNIS1.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/31/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

#if NIS1
import Foundation

extension Address: NIS1 {
    typealias NIS1JSON = AddressJSON
    typealias JSONModel = Address
    
    static func fromNIS1JSON(json: AddressJSON) -> Address {
        var address = Address()
        address.networkType = json.networkType ?? 0
        address.value = json.value ?? ""
        return address
    }
}
#endif
