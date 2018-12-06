//
//  Account.swift
//  Meteor
//
//  Created by Mark Price on 7/25/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import Foundation
import Cache

class Account: Codable {
    internal(set) var address = ""
    internal(set) var mosaics = [Mosaic]()
    internal(set) var wallet = Wallet()
    
    static func storage() -> HybridStorage<Account>? {
        do {
            let memory = MemoryStorage<Account>(config: MemoryConfig())
            let disk = try DiskStorage<Account>(config: DiskConfig(name: "AccountDisk"), transformer: TransformerFactory.forCodable(ofType: Account.self))
            return HybridStorage(memoryStorage: memory, diskStorage: disk)
        } catch {
            debugPrint("Error: ", error.localizedDescription)
            return nil
        }
    }
    
    init(address: String = "", mosaics: [Mosaic] = []) {
        self.address = address
        self.mosaics = mosaics
    }
    
    func save(key: String) {
        do {
            try Account.storage()?.setObject(self, forKey: self.address)
        } catch {
            debugPrint("Error: ", error.localizedDescription)
        }
    }
    
    func delete(key: String) {
        do {
            try Account.storage()?.removeObject(forKey: self.address)
        } catch {
            debugPrint("Error: ", error.localizedDescription)
        }
    }
    
    static func fromCache(key: String) -> Account {
        do {
            if let account = try Account.storage()?.object(forKey: key) {
                return account
            }
        } catch {
            debugPrint("Error: ", error.localizedDescription)
        }
        return Account(address: key)
    }
    
    static func allFromCache(addresses: [String], networkFilter: String) -> Array<Account> {
        let key = networkFilter == NetworkTypeStrings.main ? "N" : "T"
        let networkAddresses = addresses.filter({$0.hasPrefix(key)})
        return networkAddresses.map {
            return Account.fromCache(key: $0)
        }
    }
}

