//
//  CALayer.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/24/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

extension CALayer {
    func addGradientBorder(colors: [UIColor], cornerRadius: CGFloat, width:CGFloat = 1) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: self.bounds.size)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.3)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.7)
        gradientLayer.colors = colors.map({$0.cgColor})
        let shape = CAShapeLayer()
        shape.lineWidth = width
        shape.fillColor = nil
        shape.strokeColor = UIColor.black.cgColor
        shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        gradientLayer.mask = shape
        
        self.addSublayer(gradientLayer)
    }
    
    func addDropShadow() {
        masksToBounds = false
        shadowColor = UIColor.gray.cgColor
        shadowOffset = CGSize(width: 0, height: 2)
        shadowOpacity = 0.5
        shadowRadius = 2
    }
    
    func addTopShadow() {
        masksToBounds = false
        shadowColor = UIColor.darkGray.cgColor
        shadowOffset = CGSize(width: 0, height: -5)
        shadowOpacity = 0.5
        shadowRadius = 5
    }

}
