//
//  Label.swift
//  Blockstart
//
//  Created by Nathan Brewer on 7/20/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

@IBDesignable
class Label: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        radius(cornerRadius)
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            radius(cornerRadius)
        }
    }
    
    func radius(_ amount: CGFloat)  {
        layer.cornerRadius = amount
    }

}
