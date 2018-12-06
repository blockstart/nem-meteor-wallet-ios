//
//  PinVC.swift
//  Meteor
//
//  Created by Nathan Brewer on 10/8/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//
import UIKit

class PinVC: UIViewController, PinResultDelegate {
    
    @IBOutlet weak var pinDisplayView: PinDisplay!
    @IBOutlet weak var pinPadDisplayView: PinPadDisplay!
    
    var state: PinDisplay.LockState = .SetPin
    
    func setInitialState(_ state: PinDisplay.LockState) {
        self.state = state
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinPadDisplayView.assignDelegate(pinDisplayView, with: state)
        pinDisplayView.assignDelegate(self, with: state)
    }
    
    func acceptPinSuccessful(from state: PinDisplay.LockState) {
        switch state {
        case .AccessPin:
            dismiss(animated: true, completion: nil)
        case .ConfirmPin:
            present(Alert.instance.singleMsgAlertWithDismiss(title: AlertMessage.pinLockEnabled, message: "", parent: self), animated: true, completion: nil)
        case .RemovePin:
            present(Alert.instance.singleMsgAlertWithDismiss(title: AlertMessage.pinLockDisabled, message: "", parent: self), animated: true, completion: nil)
        case .SetPin: break
        }
    }
    
    func sessionCancelled() {
        dismiss(animated: true, completion: nil)
    }
    
}
