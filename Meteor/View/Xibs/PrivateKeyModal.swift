//
//  PrivateKeyModal.swift
//  Meteor
//
//  Created by Nathan Brewer on 9/20/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

class PrivateKeyModal: UIView {
    
    @IBOutlet weak var privateKeyLbl: UILabel!
    @IBOutlet weak var copiedStack: UIStackView!
    @IBOutlet weak var copiedTextLbl: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    private var copyTap = UITapGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initNib()
    }
    
    override func layoutSubviews() {
        headerView.layer.cornerRadius = 5
        if #available(iOS 11.0, *) {
            headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            let path = UIBezierPath(roundedRect: headerView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 5, height: 5))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = headerView.bounds
            maskLayer.path = path.cgPath
            headerView.layer.mask = maskLayer
        }
    }
    
    func initNib() {
        layer.cornerRadius = 5
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 0.8
        clipsToBounds = false
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 3
    }
    
    func setPrivateKey(_ key: String) {
        privateKeyLbl.text = key
        copyTap = UITapGestureRecognizer(target: self, action: #selector(animateCopy))
        copyTap.cancelsTouchesInView = false
        privateKeyLbl.addGestureRecognizer(copyTap)
        privateKeyLbl.isUserInteractionEnabled = true
        animateCopy()
    }
    
    @objc func animateCopy() {
        if let pk = privateKeyLbl.text {
            UIPasteboard.general.string = pk
            copiedTextLbl.font = UIFont(name: MeteorFonts.fontItalic, size: 16)
            copiedStack.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: .allowUserInteraction, animations: {
                self.copiedStack.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
    
}
