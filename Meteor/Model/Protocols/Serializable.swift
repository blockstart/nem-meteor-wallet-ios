//
//  Serializable.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/23/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import Foundation

protocol Serializable: Codable {
    func serialize() -> Data?
}

extension Serializable {
    func serialize() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
}
