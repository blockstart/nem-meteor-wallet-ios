//
//  FilteredTransaction.swift
//  Meteor
//
//  Created by Jacob Luetzow on 9/2/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import Foundation
import Cache

class FilterTransaction: Serializable {
    internal(set) var transactions = Array<Transaction>()
    internal(set) var nextPageId = 0
    
    static func storage() -> HybridStorage<FilterTransaction>? {
        do {
            let memory = MemoryStorage<FilterTransaction>(config: MemoryConfig())
            let disk = try DiskStorage<FilterTransaction>(config: DiskConfig(name: "FilterTransactionDisk"), transformer: TransformerFactory.forCodable(ofType: FilterTransaction.self))
            return HybridStorage(memoryStorage: memory, diskStorage: disk)
        } catch {
            debugPrint("Error: ", error.localizedDescription)
            return nil
        }
    }
    
    init(transactions: [Transaction] = [], nextPageId: Int = 0) {
        self.transactions = transactions
        self.nextPageId = nextPageId
    }
    
    func save(key: String) {
        do {
            try FilterTransaction.storage()?.setObject(self, forKey: key)
        } catch {
            debugPrint("Error: ", error.localizedDescription)
        }
    }
    
    func delete(key: String) {
        do {
            try FilterTransaction.storage()?.removeObject(forKey: key)
        } catch {
            debugPrint("Error: ", error.localizedDescription)
        }
    }
    
    static func fromCache(key: String) -> FilterTransaction {
        do {
            if let filterTransaction = try FilterTransaction.storage()?.object(forKey: key) {
                return filterTransaction
            }
        } catch {
            debugPrint("Error: ", error.localizedDescription)
        }
        return FilterTransaction()
    }
}

struct FilterTXBody: Serializable {
    var address = ""
    var mosaicId = MosaicId()
    var nextPageId: Int?
}
