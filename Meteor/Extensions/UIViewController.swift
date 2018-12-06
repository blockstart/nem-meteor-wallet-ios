//
//  UIViewController.swift
//  Blockstart
//
//  Created by Nathan Brewer on 7/3/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

extension UIViewController {
    func createAccessoryView(viewColor: UIColor? = .white, btnTitle: String, btnColor: UIColor, action: Selector, input: UITextField, inputPlaceholder: String? = PASSWORD_PLACEHOLDER) -> UIView {
        let inputSpacer = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let accessory = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 180))
        accessory.backgroundColor = viewColor
        accessory.addSubview(input)
        let sendBtn = UIButton(frame: CGRect(x: 0, y: 120, width: view.frame.width, height: 60))
        accessory.addSubview(sendBtn)
        sendBtn.setTitle(btnTitle, for: .normal)
        sendBtn.titleLabel?.font = UIFont(name: MeteorFonts.fontBold, size: 17)
        sendBtn.backgroundColor = btnColor
        sendBtn.addTarget(self, action: action, for: .touchUpInside)
        input.frame = CGRect(x: 0, y: 20, width: view.frame.width * 0.9, height: 50)
        input.layer.cornerRadius = 5
        input.clipsToBounds = true
        input.leftViewMode = .always
        input.leftView = inputSpacer
        input.center.x = view.frame.width / 2
        input.autocorrectionType = .no
        input.placeholder = inputPlaceholder
        input.backgroundColor = UIColor.groupTableViewBackground
        accessory.layer.addTopShadow()
        return accessory
    }
}
