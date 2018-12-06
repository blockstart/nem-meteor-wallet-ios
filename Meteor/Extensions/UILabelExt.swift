//
//  UILabelExt.swift
//  Meteor
//
//  Created by Nathan Brewer on 9/10/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import Alamofire

extension UILabel {
    func addBoldText(fullText: String, bold: Array<String>) {
        let str = fullText as NSString
        let attr = NSMutableAttributedString.init(string: fullText)
        for i in 0..<bold.count {
            let range = str.range(of: bold[i])
            attr.addAttribute(.font, value: UIFont(name: MeteorFonts.fontBold, size: 30)!, range: range)
        }
        self.attributedText = attr
    }
}
