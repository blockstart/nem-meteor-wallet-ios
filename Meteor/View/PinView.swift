//
//  PinView.swift
//  Meteor
//
//  Created by Nathan Brewer on 10/7/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

class PinView: UIView {
    
    private var isFull: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        initPinView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initPinView()
    }
    
    func initPinView() {
        backgroundColor = .clear
        layer.cornerRadius = bounds.width / 2
        layer.borderColor = UIColor.pinHighlight.cgColor
        layer.borderWidth = 2
        clipsToBounds = true
        layer.masksToBounds = true
    }
    
    func isEmptyPin() -> Bool {
        return !isFull
    }
    
    func fill() {
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = UIColor.pinHighlight
            self.isFull = true
        }
    }
    
    func empty() {
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = .clear
            self.isFull = false
        }
    }
    

}
