//
//  CacheTests.swift
//  MeteorTests
//
//  Created by Mark Price on 7/31/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import XCTest
import Cache

class CacheTests: XCTestCase {
    
    var mosaics: [Mosaic]!
    var transactions: [Transaction]!
    let address = "TCXGGAWCGNHFFLQ6KEAIPBCPQVKCACVKHTFHIAGO"

    override func setUp() {
        mosaics = [Mosaic]()
        transactions = [Transaction]()
        var mos = Mosaic()
        mos.isXEM = false
        mos.mosaicId.name = "Cache"
        mos.mosaicId.namespaceId = "Cache"
        mos.quantity = 1000123456
        mos.ticker = "CHE"
        mosaics.append(mos)
        
        var trans = Transaction()
        trans._mosaics.append(mos)
        trans._mosaics[0].quantity = 450000000
        trans.message.payload = "For alien stim packs"
        trans.recipient.value = "1234"
        trans.transactionInfo.hash.data = "ABCD1234"
        trans.timeWindow.timeStamp = "TIME"
        trans.signer.address = "4321"
        transactions.append(trans)
        
        let account = Account(address: address, mosaics: mosaics)
        account.save(key: address)
    }

    override func tearDown() {
        let savedAccount = Account.fromCache(key: address)
        savedAccount.delete(key: address)
    }
 
    func testCacheAccount() {
        let savedAccount = Account.fromCache(key: address)
        XCTAssertNotNil(savedAccount)
        XCTAssertNotNil(savedAccount.mosaics)
        XCTAssertEqual(savedAccount.mosaics[0].mosaicId.name, "Cache")
    }
    
    func testCacheWallet() {
        var wallet = Wallet()
        wallet.name = "test"
        wallet.network = 1
        wallet.address.value = address
        wallet.creationDate = "2018-08-21T13:31:32.847"
        wallet.encryptedPrivateKey = EncryptedPrivateKey.init(encryptedKey: "fd0a43080fcb4a8f1f5fd02969662cb12d6399c5cd01bc3352f0b54aac460720d67a73b124fd6d741b9635a715f3c219", iv: "96647f17653b7dc3998ced5b3f6772f3")
        let savedAccount = Account.fromCache(key: address)
        savedAccount.wallet = wallet
        savedAccount.save(key: address)
        XCTAssertNotNil(savedAccount.wallet)
        XCTAssertEqual(savedAccount.wallet.name, "test")
        XCTAssertEqual(savedAccount.wallet.network, 1)
        XCTAssertEqual(savedAccount.wallet.address.value, address)
        XCTAssertEqual(savedAccount.wallet.encryptedPrivateKey.encryptedKey, "fd0a43080fcb4a8f1f5fd02969662cb12d6399c5cd01bc3352f0b54aac460720d67a73b124fd6d741b9635a715f3c219")
        XCTAssertEqual(savedAccount.wallet.encryptedPrivateKey.iv, "96647f17653b7dc3998ced5b3f6772f3")
    }

    func testStorage() {
        let diskConfig = DiskConfig(name: "default")

        XCTAssertEqual(diskConfig.name, "default")
        
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
        let storage = try? Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: Account.self))

        XCTAssertNotNil(storage)
        XCTAssertThrowsError(try storage?.object(forKey: "default") === Account.self, "default does not exist. Should throw error") { (err) in
        
        }
        
    }
}
