//
//  DeepLinkNavigator.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/27/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

class DeepLinkNavigator {
    static let instance = DeepLinkNavigator()
    private init() {}
    
    func openDeepLinkPage(_ type: DeepLinkType, payload: DeepLinkPayload?) {
        switch type {
        case .request(address: _):
            if let load = payload {
                if let root = UIApplication.shared.keyWindow?.rootViewController {
                    if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.rootVC) as? RootController {
                        vc.deepLinkAddress = load.address
                        root.present(vc, animated: true, completion: nil)
                    }
                }
            }
            return
        }
    }
}
