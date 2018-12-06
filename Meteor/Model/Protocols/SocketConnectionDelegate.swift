//
//  SocketConnectionDelegate.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/17/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import Foundation

@objc protocol SocketConnectionDelegate {
    func onSocketEvent(event: String, data: Any?)
}
