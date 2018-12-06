//
//  UITextFieldExt.swift
//  Meteor
//
//  Created by Nathan Brewer on 8/23/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

extension UITextField {
    func assignPlaceholder(with placeholder: String) {
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightText])
    }
}
