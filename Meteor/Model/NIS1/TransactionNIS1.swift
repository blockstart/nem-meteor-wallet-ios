//
//  TransactionNIS1.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/20/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//
#if NIS1
import Foundation
import Alamofire

extension Transaction: NIS1 {
    typealias NIS1JSON = TransactionJSON
    typealias JSONModel = Transaction
    
    
    static func fromNIS1JSON(json: TransactionJSON) -> Transaction {
        var transaction = Transaction()
        transaction.type = json.type ?? 0
        transaction.version = json.version ?? 0
        if let tw = json.timeWindow {
            transaction.timeWindow = TimeWindow.fromNIS1JSON(json: tw)
        }
        transaction.fee = json.fee ?? 0
        if let add = json.recipient {
            transaction.recipient = Address.fromNIS1JSON(json: add)
        }
        if let xem = json._xem {
            transaction._xem = Xem.fromNIS1JSON(json: xem)
        }
        if let mess = json.message {
            transaction.message = Message.fromNIS1JSON(json: mess)
        }
        var mosaics = [Mosaic]()
        if let mos = json._mosaics {
            mosaics = mos.map {
                return Mosaic.fromNIS1JSON(json: $0)}
        }
        transaction._mosaics = mosaics
        transaction.signature = json.signature ?? ""
        if let sign = json.signer {
            transaction.signer = Signer.fromNIS1JSON(json: sign)
        }
        if let ti = json.transactionInfo {
            transaction.transactionInfo = TransactionInfo.fromNIS1JSON(json: ti)
        }
        return transaction
    }
    
    static func create(createTransaction: CreateTransaction, onComplete: @escaping Snapshot, onError: Snapshot? = nil) {
        let data = createTransaction.serialize()
        var request = URLRequest(url: URL(string: "\(NISAPI.URL_BASE)\(NISAPI.URL_CREATE_TRANSACTION)")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
                guard let data = response.data else { return }
                switch response.result {
                case .success:
                    if let res = data.returnResult(TransactionJSON.self) {
                        onComplete(Transaction.fromNIS1JSON(json: res))
                    }
                case .failure:
                    if let err = data.returnResult(APIError.self) {
                        onError?(err)
                    }
                }
        }
    }
    
    static func send(sendTransaction: SendTransaction, onComplete: @escaping Snapshot, onError: Snapshot? = nil) {
        var sendTransaction = sendTransaction
        do { sendTransaction.password = try sendTransaction.password.encrypt() } catch { onError?(error) }
        let data = sendTransaction.serialize()
        var request = URLRequest(url: URL(string: "\(NISAPI.URL_BASE)\(NISAPI.URL_SEND_TRANSACTION)")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .responseData { (response) in
                switch response.result {
                case .success:
                    onComplete(response.result.value as Any)
                case .failure:
                    onError?(response.result.value as Any)
                    if let err = response.error {
                        debugPrint("ERROR: \(err)")
                    }
                }
        }
    }
    
    static func decodeMessage(message: Message, onComplete: @escaping Snapshot, onError: Snapshot? = nil) {
        let data = message.serialize()
        var request = URLRequest(url: URL(string: "\(NISAPI.URL_BASE)\(NISAPI.URL_DECODE_MESSAGE)")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
            if let data = response.data {
                switch response.result {
                case .success:
                    if let result = data.returnResult(MessageJSON.self) {
                        onComplete(result.payload ?? "")
                    }
                case .failure:
                    if let error = data.returnResult(APIError.self) {
                        onError?(error)
                    }
                }
            }
        }
    }
    
    static func txDataToTransactionObject(dict: Any) -> Transaction {
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: [])
            let decoder = JSONDecoder()
            let result = try decoder.decode(TransactionJSON.self, from: data)
            return Transaction.fromNIS1JSON(json: result)
        } catch {
            debugPrint("Cannot decode JSON: ", error.localizedDescription)
        }
        return Transaction()
    }
}
#endif
