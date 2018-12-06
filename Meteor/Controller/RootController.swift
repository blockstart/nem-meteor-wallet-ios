//
//  RootController.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/27/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

class RootController: UITabBarController {
    
    var deepLinkAddress: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if deepLinkAddress != nil {
           selectedIndex = 1
        }
        deepLinkAddress = nil
    }

}
