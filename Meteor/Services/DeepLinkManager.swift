//
//  DeepLinkManager.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/27/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

enum DeepLinkType {
    case request(address: String)
}

let Deeplinker = DeepLinkManager()

class DeepLinkManager {
    fileprivate init() {}
    
    private var deeplinkType: DeepLinkType?
    private var deeplinkedAddress: DeepLinkPayload?
    private let defaults = UserDefaults.standard
    var requestAmount: String? {
        get { return defaults.string(forKey: UserDefaultKeys.deepLinkAmount) }
        set { defaults.set(newValue, forKey: UserDefaultKeys.deepLinkAmount) }
    }
    var requestAddress: String? {
        get { return defaults.string(forKey: UserDefaultKeys.deepLinkAddress) }
        set { defaults.set(newValue, forKey: UserDefaultKeys.deepLinkAddress) }
    }
    var requestMosaic: String? {
        get { return defaults.string(forKey: UserDefaultKeys.deepLinkMosaic) }
        set { defaults.set(newValue, forKey: UserDefaultKeys.deepLinkMosaic) }
    }
    
    func clearUserDefaults() {
        requestAddress = nil
        requestMosaic = nil
        requestAmount = nil
    }
    
    func checkDeepLink() {
        guard let type = deeplinkType else { return }
        DeepLinkNavigator.instance.openDeepLinkPage(type, payload: self.deeplinkedAddress)
        self.deeplinkType = nil
    }
    
    func handleDeeplink(url: URL) -> Bool {
        deeplinkType = DeepLinkParser.instance.parseDeepLink(url)
        deeplinkedAddress = DeepLinkParser.instance.parseDeepLinkAddress(url)
        return deeplinkType != nil
    }
}
