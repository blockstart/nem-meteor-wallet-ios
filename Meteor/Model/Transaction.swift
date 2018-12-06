//
//  Transaction.swift
//  Meteor
//
//  Created by Mark Price on 7/26/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import Foundation

struct Transaction: Serializable {
    var type = 0
    var version = 0
    var timeWindow = TimeWindow()
    var fee = 0
    var recipient = Address()
    var _xem = Xem()
    var message = Message()
    var _mosaics = Array<Mosaic>()
    var signature = ""
    var signer = Signer()
    var transactionInfo = TransactionInfo()
}

struct CreateTransaction: Serializable {
    var address = ""
    var mosaic = Mosaic()
    var message = ""
}

struct SendTransaction: Serializable {
    var wallet = Wallet()
    var transferTransaction = Transaction()
    var password = ""
}

struct TransactionNotif: Serializable {
    var mosaicName: String
    var recipientAddress: String
    var senderAddress: String
    
    static func fromSocketDictionary(dictData: Any) -> TransactionNotif? {
        guard let tx = dictData as? Dictionary<String, Any> else { return nil }
        var mosaicName = ""
        if let mosaics = tx["_mosaics"] as? Array<Dictionary<String, Any>> {
            if mosaics.count > 0 {
                let mosaic = mosaics[0]
                if let mosaicId = mosaic["mosaicId"] as? Dictionary<String, String> {
                    if let name = mosaicId["name"] {
                        mosaicName = name
                    }
                }
            }
        }
        
        if mosaicName == "" {
            guard let _xem = tx["_xem"] as? Dictionary<String, Any> else { return nil }
            guard let mosaicId = _xem["mosaicId"] as? Dictionary<String, String> else { return nil }
            guard let name = mosaicId["name"] else { return nil }
            mosaicName = name
        }
        
        guard let sender = tx["signer"] as? Dictionary<String, Any> else { return nil }
        guard let senderAddress = sender["address"] as? Dictionary<String, Any> else { return nil }
        guard let addressValue = senderAddress["value"] as? String else { return nil }
        
        guard let recipient = tx["recipient"] as? Dictionary<String, Any> else { return nil }
        guard let address = recipient["value"] as? String else { return nil }
        return TransactionNotif(mosaicName: mosaicName, recipientAddress: address, senderAddress: addressValue)
    }
}





