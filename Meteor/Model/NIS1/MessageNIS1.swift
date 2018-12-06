//
//  MessageNIS1.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/31/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

#if NIS1
import Foundation

extension Message: NIS1 {
    typealias NIS1JSON = MessageJSON
    typealias JSONModel = Message
    
    static func fromNIS1JSON(json: MessageJSON) -> Message {
        var message = Message()
        message.payload = json.payload ?? ""
        return message
    }
}
#endif
