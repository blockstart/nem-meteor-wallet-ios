//
//  TransactionInfoNIS1.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/31/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

#if NIS1
import Foundation

extension TransactionInfo: NIS1 {
    typealias NIS1JSON = TransactionInfoJSON
    typealias JSONModel = TransactionInfo
    
    static func fromNIS1JSON(json: TransactionInfoJSON) -> TransactionInfo {
        var transactionInfo = TransactionInfo()
        if let hash = json.hash {
            transactionInfo.hash = Hash.fromNIS1JSON(json: hash)
        }
        transactionInfo.height = json.height ?? 0
        transactionInfo.id = json.id ?? 0
        return transactionInfo
    }
}
#endif
