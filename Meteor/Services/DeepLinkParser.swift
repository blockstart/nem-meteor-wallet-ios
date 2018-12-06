//
//  DeepLinkParser.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/27/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

struct DeepLinkPayload {
    let address: String
    let amount: String
    let currency: String
}

class DeepLinkParser {
    static let instance = DeepLinkParser()
    private init() {}
    
    func parseDeepLink(_ url: URL) -> DeepLinkType? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else { return nil }
        var pathComp = components.path.components(separatedBy: "/")
        pathComp.removeFirst()
        switch host {
        case HOST:
            if let requestId = pathComp.first {
                return DeepLinkType.request(address: requestId)
            }
        default:
            break
        }
        return nil
    }
    
    func parseDeepLinkAddress(_ url: URL) -> DeepLinkPayload? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        if let params = components.queryItems, params.count >= 3 {
            guard let address = params[0].value,
                let amount = params[1].value,
                let currency = params[2].value else { return nil }
            Deeplinker.requestAddress = address
            Deeplinker.requestAmount = amount
            Deeplinker.requestMosaic = currency
            return DeepLinkPayload(address: address, amount: amount, currency: currency)
        }
        return nil
    }
}
