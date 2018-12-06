//
//  CopyLabel.swift
//  Meteor
//
//  Created by Nathan Brewer on 10/16/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

class CopyLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(copyText))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let loc = touch.location(in: self)
            if bounds.contains(loc) {
                let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
                lbl.backgroundColor = UIColor.darkPrimary
                lbl.textAlignment = .center
                lbl.textColor = .white
                lbl.text = COPIED
                lbl.clipsToBounds = true
                lbl.font = UIFont(name: MeteorFonts.fontBold, size: 14)
                lbl.layer.cornerRadius = 15
                lbl.center.x = loc.x
                lbl.center.y = loc.y - 30
                addSubview(lbl)
                UIView.animate(withDuration: 1.35, animations: {
                    lbl.alpha = 0
                }) { (finished) in
                    if finished { lbl.removeFromSuperview() }
                }
            }
        }
    }
    
    @objc func copyText() {
        if let txt = text {
            UIPasteboard.general.string = txt
            animateCopy()
        }
    }
    
    func animateCopy() {
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.4, options: .allowUserInteraction, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }

}
