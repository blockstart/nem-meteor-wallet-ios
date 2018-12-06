//
//  FilterTransactionNIS1.swift
//  Meteor
//
//  Created by Jacob Luetzow on 9/2/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

#if NIS1
import Foundation
import Alamofire

extension FilterTransaction: NIS1 {
    typealias NIS1JSON = FilterTransactionJSON
    typealias JSONModel = FilterTransaction
    
    static func fromNIS1JSON(json: FilterTransactionJSON) -> FilterTransaction {
        var transactions = [Transaction]()
        if let tx = json.transactions {
            transactions = tx.map {
                return Transaction.fromNIS1JSON(json: $0)}
        }
        let filteredTX = FilterTransaction(transactions: transactions, nextPageId: json.nextPageId ?? 0)
        return filteredTX
    }
    
    static func fetchFilterTransactions(filterTransaction: FilterTXBody, onComplete: @escaping Snapshot) {
        let data = filterTransaction.serialize()
        var request = URLRequest(url: URL(string: "\(NISAPI.URL_BASE)\(NISAPI.URL_FILTER_TRANSACTIONS)")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        Alamofire.request(request).responseJSON { (response) in
            if let data = response.data {
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(FilterTransactionJSON.self, from: data)
                    let filterTXs = FilterTransaction.fromNIS1JSON(json:result)
                    filterTXs.save(key: filterTransaction.address + filterTransaction.mosaicId.namespaceId + filterTransaction.mosaicId.name)
                    onComplete(filterTXs)
                } catch {
                    debugPrint("Cannot decode JSON: ", error.localizedDescription)
                }
            }
            
            if let err = response.error {
                debugPrint("ERROR: \(err)")
            }
        }
    }
}
#endif
