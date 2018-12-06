//
//  PinPadDisplay.swift
//  Meteor
//
//  Created by Nathan Brewer on 10/11/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import LocalAuthentication

class PinPadDisplay: UIView {
    
    @IBOutlet weak var leftBottomBtn: PinPadButton!
    
    var pinDelegate: PinDisplayDelegate?
    private var pinState: PinDisplay.LockState = .SetPin
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        let context = LAContext()
        var error: NSError?
        var img = UIImage()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if context.biometryType == .faceID {
                if let image = UIImage(named: "face_ID") {
                    img = image
                }
            } else if context.biometryType == .touchID {
                if let image = UIImage(named: "touch_ID") {
                    img = image
                }
            }
        } else if pinState == .AccessPin { leftBottomBtn.isEnabled = false }
        pinState.getState().isCancellable
            ? leftBottomBtn.setTitle(CANCEL, for: .normal)
            : leftBottomBtn.setImage(img, for: .normal)
    }
    
    func assignDelegate(_ delegate: PinDisplayDelegate, with state: PinDisplay.LockState) {
        pinDelegate = delegate
        pinState = state
    }
    
    @IBAction func pinSelected(_ sender: PinPadButton) {
        pinDelegate?.fillPin(sender.pinCharacter)
    }
    
    @IBAction func leftBottomBtnPressed(_ sender: PinPadButton) {
        pinDelegate?.leftBtnAction()
    }
    
    @IBAction func backspacePressed(_ sender: PinPadButton) {
        pinDelegate?.emptyPin()
    }

}
