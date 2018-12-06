//
//  CodeReader.swift
//  Blockstart
//
//  Created by Nathan Brewer on 7/16/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

protocol QRScanner {
    func scanResult(result: String)
    func cancelSession()
    func accessDenied()
}
