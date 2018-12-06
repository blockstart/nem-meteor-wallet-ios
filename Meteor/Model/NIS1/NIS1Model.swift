//
//  NIS1.swift
//  Meteor
//
//  Created by Mark Price on 7/25/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

#if NIS1
import Foundation
import Alamofire

protocol NIS1 {
    associatedtype NIS1JSON
    associatedtype JSONModel
    static func fromNIS1JSON(json: NIS1JSON) -> JSONModel
}
struct MosaicIdJSON: Codable {
    var name: String?
    var namespaceId: String?
}
struct MosaicPropertiesJSON: Codable {
    var initialSupply: UInt?
    var supplyMutable: Bool?
    var transferable: Bool?
    var divisibility: Int?
}
struct MosaicLevyJSON: Codable {
    var type: Int?
    var recipient: AddressJSON?
    var mosaicId: MosaicIdJSON?
    var fee: Int?
}
struct MosaicJSON: Codable {
    var mosaicId: MosaicIdJSON?
    var properties: MosaicPropertiesJSON?
    var levy: MosaicLevyJSON?
    var quantity: Int?
}
struct XemJSON: Codable {
    var quantity: Int?
    var mosaicId: MosaicIdJSON?
    var properties: MosaicProperties?
}
struct MessageJSON: Codable {
    var payload: String?
}
struct AddressJSON: Codable {
    var networkType: Int?
    var value: String?
}
struct SignerJSON: Codable {
    var address: AddressJSON?
    var publicKey: String?
}
struct TimeWindowJSON: Codable {
    var deadline: String?
    var timeStamp: String?
}
struct HashJSON: Codable {
    var data: String?
}
struct TransactionInfoJSON: Codable {
    var hash: HashJSON?
    var height: Int?
    var id: Int?
}
struct TransactionJSON: Codable {
    var type: Int?
    var version: Int?
    var timeWindow: TimeWindowJSON?
    var fee: Int?
    var recipient: AddressJSON?
    var _xem: XemJSON?
    var message: MessageJSON?
    var _mosaics: Array<MosaicJSON>?
    var signature: String?
    var signer: SignerJSON?
    var transactionInfo: TransactionInfoJSON?
}
struct AccountJSON: Codable {
    var address: String?
    var mosaics: Array<MosaicJSON>?
}
struct FilterTransactionJSON: Codable {
    var transactions: Array<TransactionJSON>?
    var nextPageId: Int? 
}
struct EncryptedPrivateKeyJSON: Codable {
    var encryptedKey: String?
    var iv: String?
}
struct WalletJSON: Codable {
    var name: String?
    var network: Int?
    var address: AddressJSON?
    var creationDate: String?
    var encryptedPrivateKey: EncryptedPrivateKeyJSON?
}
struct AddressObj: Codable {
    var pretty: String
    var plain: String
}
struct PrivateKeyJSON: Codable {
    var encryptedPrivateKey: String
}
struct APIError: Codable {
    var message: String
}
struct IncorrectNetworkError: Codable {
    var message: String
}
struct DuplicateImportError: Codable {
    var message: String
}
struct NISAPI {
    static let URL_BASE = "http://localhost:3000"
    static let URL_ACCOUNT = "/account"
    static let URL_ADDRESS_FORMAT = "/account/format"
    static let URL_IMPORT_WALLET_QRSTRING = "/wallet/import/qrstring"
    static let URL_IMPORT_WALLET_QROBJECT = "/wallet/import/qrobject"
    static let URL_EXPORT_WALLET = "/wallet/export"
    static let URL_CREATE_WALLET = "/wallet/create"
    static let URL_ECRYPTED_PRIVATE_KEY = "/wallet/encryptedPrivateKey"
    static let URL_CREATE_TRANSACTION = "/transaction/create"
    static let URL_SEND_TRANSACTION = "/transaction/send"
    static let URL_DECODE_MESSAGE = "/transaction/decode/message"
    static let URL_FILTER_TRANSACTIONS = "/transaction/filtered/byMosaicId"
    static let URL_VITALS_HEARTBEAT = "/vitals/heartbeat"
    static let URL_SWITCH_NETWORK = "/network/switch"
}
#endif
typealias Snapshot = (_ data: Any) -> Void
