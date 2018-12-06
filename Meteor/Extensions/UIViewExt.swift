//
//  UIViewExt.swift
//  Meteor
//
//  Created by Nathan Brewer on 9/1/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import Lottie

extension UIView {
    func addLottieAnimation(_ animView: LOTAnimationView, scale: CGFloat = 1, loop: Bool = false, reverse: Bool = false, completion: @escaping () -> ()) {
        animView.frame = bounds
        animView.frame.size.height = bounds.height * scale
        animView.frame.size.width = bounds.width * scale
        animView.center = self.center
        animView.contentMode = .scaleAspectFit
        animView.loopAnimation = loop
        animView.autoReverseAnimation = reverse
        let animBackground = UIView(frame: self.bounds)
        animBackground.backgroundColor = UIColor.bsPrimary
        addSubview(animBackground)
        addSubview(animView)
        animView.play { (_) in
            completion()
        }
    }
    
    func shake(count: Float = 8, duration: TimeInterval = 0.04, translation: CGFloat = 3) {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.repeatCount = count
        animation.duration = duration
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: -translation, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: translation, y: self.center.y))
        layer.borderWidth = 1
        layer.borderColor = UIColor.bsRed.cgColor
        layer.add(animation, forKey: "shake")
    }
}
