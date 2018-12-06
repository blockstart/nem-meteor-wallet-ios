//
//  WalletNIS1.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/20/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//
#if NIS1
import Foundation
import Alamofire

extension Wallet: NIS1 {
    typealias NIS1JSON = WalletJSON
    typealias JSONModel = Wallet
    
    static func fromNIS1JSON(json: WalletJSON) -> Wallet {
        var wallet = Wallet()
        wallet.name = json.name ?? ""
        wallet.network = json.network ?? 1
        wallet.address = Address(networkType: json.address?.networkType ?? 0, value:json.address?.value ?? "")
        wallet.creationDate = json.creationDate ?? ""
        wallet.encryptedPrivateKey = EncryptedPrivateKey.init(encryptedKey: json.encryptedPrivateKey?.encryptedKey ?? "", iv: json.encryptedPrivateKey?.iv ?? "")
        return wallet
    }
    
    static func importWalletQRString(qrString: QRString, onComplete: @escaping Snapshot, onError: Snapshot? = nil) {
        let data = qrString.serialize()
        var request = URLRequest(url: URL(string: "\(NISAPI.URL_BASE)\(NISAPI.URL_IMPORT_WALLET_QRSTRING)")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
            if let data = response.data {
                switch response.result {
                case .success:
                    if let result = data.returnResult(WalletJSON.self) {
                        let wallet = Wallet.fromNIS1JSON(json: result)
                        self.updateAppState(wallet, onSuccess: { (success) in
                            onComplete(wallet)
                        }, onError: { (err) in
                            onError?(err)
                        })
                    }
                case .failure:
                    if let error = data.returnResult(APIError.self) {
                        onError?(error)
                    }
                }
                
            }
        }
    }
    
    static func importWalletQRObject(qrObject: QRObject, onComplete: @escaping Snapshot, onError: Snapshot? = nil) {
        var qrObject = qrObject
        do { qrObject.password = try qrObject.password.encrypt() } catch { onError?(error) }
        let data = qrObject.serialize()
        var request = URLRequest(url: URL(string: "\(NISAPI.URL_BASE)\(NISAPI.URL_IMPORT_WALLET_QROBJECT)")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
            if let data = response.data {
                switch response.result {
                case .success:
                    if let result = data.returnResult(WalletJSON.self) {
                        let wallet = Wallet.fromNIS1JSON(json: result)
                        self.updateAppState(wallet, onSuccess: { (success) in
                            onComplete(wallet)
                        }, onError: { (err) in
                            onError?(err)
                        })
                    }
                case .failure:
                    if let error = data.returnResult(APIError.self) {
                        onError?(error)
                    }
                }
            }
        }
    }
    
    static func exportWallet(wallet: Wallet, onComplete: @escaping Snapshot, onError: Snapshot? = nil) {
        let data = wallet.serialize()
        var request = URLRequest(url: URL(string: "\(NISAPI.URL_BASE)\(NISAPI.URL_EXPORT_WALLET)")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
            if let data = response.data {
                switch response.result {
                case .success:
                    if let result = data.returnResult(QRString.self) {
                        onComplete(result)
                    }
                case .failure:
                    if let error = data.returnResult(APIError.self) {
                        onError?(error)
                    }
                }
            }
        }
    }
    
    static func createWallet(createWallet: CreateWallet, onComplete: @escaping Snapshot, onError: Snapshot? = nil) {
        var createWallet = createWallet
        do {
            createWallet.password = try createWallet.password.encrypt()
            if createWallet.privateKey != "" {
                createWallet.privateKey = try createWallet.privateKey.encrypt()
            }
        } catch { onError?(error) }
        let data = createWallet.serialize()
        var request = URLRequest(url: URL(string: "\(NISAPI.URL_BASE)\(NISAPI.URL_CREATE_WALLET)")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
            if let data = response.data {
                switch response.result {
                case .success:
                    if let result = data.returnResult(WalletJSON.self) {
                        let wallet = Wallet.fromNIS1JSON(json: result)
                        self.updateAppState(wallet, onSuccess: { (success) in
                            onComplete(wallet)
                        }, onError: { (err) in
                            onError?(err)
                        })
                    }
                case .failure:
                    if let error = data.returnResult(APIError.self) {
                        onError?(error)
                    }
                }
            }
        }
    }
    
    static func getPrivateKey(getPrivateKey: GetPrivateKey, onComplete: @escaping Snapshot, onError: Snapshot? = nil) {
        var getPrivateKey = getPrivateKey
        do { getPrivateKey.password = try getPrivateKey.password.encrypt() } catch { onError?(error) }
        let data = getPrivateKey.serialize()
        var request = URLRequest(url: URL(string: "\(NISAPI.URL_BASE)\(NISAPI.URL_ECRYPTED_PRIVATE_KEY)")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
                if let data = response.data {
                    switch response.result {
                    case .success:
                        if let result = data.returnResult(PrivateKeyJSON.self) {
                            do {
                                onComplete( try result.encryptedPrivateKey.decrypt())
                            } catch {
                                onError?(error)
                            }
                        }
                    case .failure:
                        if let error = data.returnResult(APIError.self) {
                            onError?(error)
                        }
                    }
                }
        }
    }

    private static func updateAppState(_ wallet: Wallet, onSuccess: @escaping Snapshot, onError: @escaping Snapshot) {
        let account = Account(address: wallet.address.value)
        let addressPrefix = AppState.fromCache().currentNetwork == NetworkTypeStrings.main ? "N" : "T"
        if account.address.hasPrefix(addressPrefix) {
            var appState = AppState.fromCache()
            if appState.addresses.contains(account.address) {
                onError(DuplicateImportError.init(message: AlertMessage.duplicateImport))
                return
            }
            account.wallet = wallet
            account.save(key: wallet.address.value)
            
            appState.selectedAddress = wallet.address.value
            appState.addresses.append(wallet.address.value)
            appState.save()
            onSuccess(true)
            return
        }
        onError(IncorrectNetworkError.init(message: AlertMessage.wrongNetwork))
    }
}
#endif
