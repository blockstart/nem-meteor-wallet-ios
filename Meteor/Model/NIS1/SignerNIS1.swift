//
//  SignerNIS1.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/31/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

#if NIS1
import Foundation

extension Signer: NIS1 {
    typealias NIS1JSON = SignerJSON
    typealias JSONModel = Signer
    
    static func fromNIS1JSON(json: SignerJSON) -> Signer {
        var signer = Signer()
        signer.address = json.address?.value ?? ""
        signer.publicKey = json.publicKey ?? ""
        return signer
    }
}
#endif
