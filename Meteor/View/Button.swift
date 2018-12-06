//
//  Button.swift
//  Blockstart
//
//  Created by Nathan Brewer on 7/20/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

@IBDesignable
class Button: UIButton {
    
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
        backgroundColor = setColor(colorCode)
        layer.cornerRadius = cornerRadius
    }
    
    @IBInspectable var colorCode: Int = 4 {
        didSet {
            backgroundColor = setColor(colorCode)
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 3 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var colorBorder: Int = 4 {
        didSet {
            layer.borderColor = setColor(colorBorder).cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    func setColor(_ colorCode: Int) -> UIColor {
        switch colorCode {
        case 0:
            return BSColor.bsGreen
        case 1:
            return BSColor.bsPrimary
        case 2:
            return BSColor.bsOrange
        case 3:
            return BSColor.bsRed
        case 4:
            return UIColor.clear
        case 5:
            return UIColor.darkPrimary
        case 6:
            return UIColor.primaryLight
        default:
            return UIColor.clear
        }
    }
}
