//
//  UIColor.swift
//  Blockstart
//
//  Created by Nathan Brewer on 7/19/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

typealias BSColor = UIColor

extension BSColor {
    convenience init(red: UInt8, green: UInt8, blue: UInt8) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex: Int) {
        self.init(red: UInt8((netHex >> 16) & 0xff), green: UInt8((netHex >> 8) & 0xff), blue: UInt8(netHex & 0xff))
    }
    
    class var fadedBlack: BSColor {
        return BSColor(red: 0, green: 0, blue: 0, alpha: 0.7)
    }
    
    class var bsGreen: BSColor {
        return BSColor(netHex: 0x69D2A9)
    }
    
    class var bsPrimary: BSColor {
        return BSColor(netHex: 0x141A3F)
    }
    
    class var primaryHighlight: BSColor {
        return BSColor(netHex: 0x2b3052)
    }
    
    class var pinHighlight: BSColor {
        return BSColor(netHex: 0x72758b)
    }
    
    class var darkPrimary: BSColor {
        return BSColor(netHex: 0x0A0F2D)
    }
    
    class var bsRed: BSColor {
        return BSColor(netHex: 0xC05759)
    }
    
    class var bsOrange: BSColor {
        return BSColor(netHex: 0xECAB3B)
    }
    
    class var primaryLight: BSColor {
        return BSColor(netHex: 0x5B5DAE)
    }
}
