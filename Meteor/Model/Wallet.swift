//
//  Wallet.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/20/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import Foundation
import Cache

struct Wallet: Serializable {
    var name = ""
    var network = 1
    var address = Address()
    var creationDate = ""
    var encryptedPrivateKey = EncryptedPrivateKey()
}

struct NanoAccountInfoQR: Serializable {
    var data: NanoQRData
    var type = 0
    var v = 0
}

struct NanoQRData: Serializable {
    var addr = ""
    var name = ""
}

struct NanoQRObject: Serializable {
    var data: QRObjectData
    var type = 0
    var v = 0
}

struct QRString: Serializable {
    var qrstring = ""
}

struct QRObject: Serializable {
    var data = QRObjectData()
    var password = ""
}

struct QRObjectData: Serializable {
    var name = ""
    var priv_key = ""
    var salt = ""
}

struct CreateWallet: Serializable {
    var name = ""
    var password = ""
    var privateKey = ""
}

struct GetPrivateKey: Serializable {
    var wallet = Wallet()
    var password = ""
}

enum WalletV: Int {
    case main = 2
    case test = 3
    case testAlt = 1
}
