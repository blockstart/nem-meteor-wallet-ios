//
//  ShadowView.swift
//  Blockstart
//
//  Created by Nathan Brewer on 7/20/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

class ShadowView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        layer.addDropShadow()
        layer.masksToBounds = false
        alpha = 0
    }

}
