//
//  AccountNIS1.swift
//  Meteor
//
//  Created by Mark Price on 7/30/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

#if NIS1
import Foundation
import Alamofire

extension Account: NIS1 {
    typealias NIS1JSON = AccountJSON
    typealias JSONModel = Account
    
    static func fromNIS1JSON(json: AccountJSON) -> Account {
        var mosaics = [Mosaic]()
        if let mos = json.mosaics {
            mosaics = mos.map { Mosaic.fromNIS1JSON(json: $0)}
        }
        let account = Account(address: json.address ?? "", mosaics: mosaics)
        return account
    }
    
    func refresh(onComplete: @escaping Snapshot) {
        Alamofire.request("\(NISAPI.URL_BASE)\(NISAPI.URL_ACCOUNT)/\(address)").responseJSON { response in
            if let data = response.data {
                let decoder = JSONDecoder()
                do {
                    var result = try decoder.decode(AccountJSON.self, from: data)
                    result.address = self.address
                    let acct = Account.fromNIS1JSON(json: result)
                    self.address = acct.address
                    self.mosaics = acct.mosaics
                    self.save(key: self.address)
                    for mosaic in acct.mosaics {
                        let filteredTXBody = FilterTXBody.init(address: acct.address, mosaicId: mosaic.mosaicId, nextPageId: nil)
                        FilterTransaction.fetchFilterTransactions(filterTransaction: filteredTXBody, onComplete: { _ in})
                    }
                    onComplete(acct)
                } catch {
                    debugPrint("Cannot decode JSON: ", error.localizedDescription)
                }
            }
            
            if let err = response.error {
                debugPrint("ERROR: \(err)")
            }
        }
    }
    
    static func formatAddress(address: String, onComplete: @escaping Snapshot, onError: Snapshot? = nil) {
        Alamofire.request("\(NISAPI.URL_BASE)\(NISAPI.URL_ADDRESS_FORMAT)/\(address)")
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                guard let data = response.data else { return }
                switch response.result {
                case .success:
                    if let result = data.returnResult(AddressObj.self) {
                        onComplete(result)
                    }
                case.failure:
                    if let result = data.returnResult(APIError.self) {
                        onError?(result)
                    }
                    break
                }
        }
    }
    
    static func switchNetwork(to network: String, onComplete: @escaping Snapshot, onError: Snapshot? = nil) {
        Alamofire.request("\(NISAPI.URL_BASE)\(NISAPI.URL_SWITCH_NETWORK)/\(network)")
        .validate(statusCode: 200..<300)
            .responseData{ response in
                guard let data = response.data else { return }
                switch response.result {
                case .success:
                    onComplete(response.result.value as Any)
                case .failure:
                    if let result = data.returnResult(APIError.self) {
                        onError?(result)
                    }
                    break
                }
        }
    }
}
#endif
