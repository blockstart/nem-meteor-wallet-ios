//
//  PinPadButton.swift
//  Meteor
//
//  Created by Nathan Brewer on 10/11/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

@IBDesignable
class PinPadButton: UIButton {

    @IBInspectable
    var pinCharacter: String = "1"
    
    @IBInspectable
    var borderColor: UIColor = UIColor.pinHighlight
    
    @IBInspectable
    var highlightedBgColor: UIColor = .clear
    
    internal var pinState: PinDisplay.LockState = .SetPin
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupActions()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        setupActions()
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    
    private func setupView() {
        if pinCharacter == "x" {
            layer.borderWidth = 0
        } else {
            layer.borderWidth = 1
        }
        frame.size.width = bounds.height
        layer.cornerRadius = bounds.height / 2
        layer.borderColor = borderColor.cgColor
        layoutIfNeeded()
    }
    
    private func setupActions() {
        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchDragOutside, .touchCancel])
    }
    
    @objc func handleTouchDown() {
        animateBackgroundColor(color: highlightedBgColor)
    }
    
    @objc func handleTouchUp() {
        animateBackgroundColor(color: .clear)
    }
    
    private func animateBackgroundColor(color: UIColor) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.backgroundColor = color
        }, completion: nil)
    }
}
