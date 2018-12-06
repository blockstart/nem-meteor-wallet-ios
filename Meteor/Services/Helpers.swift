//
//  Helpers.swift
//  Blockstart
//
//  Created by Nathan Brewer on 7/5/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

class Helpers {
    static let instance = Helpers()
    private init() {}
    
    func sentOrReceived(recipient: String) -> String {
        return recipient == AppState.fromCache().selectedAddress ? TransactionStrings.received : TransactionStrings.sent
    }
    
    func imgSentOrReceived(recipient: String) -> UIImage? {
        return AppState.fromCache().selectedAddress == recipient ? UIImage(named: "received_icon_green") :
            UIImage(named: "sent_icon_red")
    }
}
