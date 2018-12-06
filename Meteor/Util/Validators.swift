//
//  Validators.swift
//  Blockstart
//
//  Created by Nathan Brewer on 7/18/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

class Validators {
    
    static func stringsMatch(_ strOne: String, strTwo: String) -> Bool {
        return strOne == strTwo
    }
    
    static func newAccountInfoIsValid(_ password: String, walletName: String) -> Bool {
        return password != "" && password.count >= 8 && walletName != ""
    }
}



