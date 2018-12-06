//
//  PinDisplay.swift
//  Meteor
//
//  Created by Nathan Brewer on 10/8/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import LocalAuthentication

protocol PinDisplayDelegate {
    func fillPin(_ nextCharacter: String)
    func emptyPin()
    func leftBtnAction()
}

protocol PinLockState {
    var title: String {get}
    var isFaceIdAllowed: Bool {get}
    var isCancellable: Bool {get}
    typealias completed = (_ isComplete: Bool) -> Void
    
    mutating func acceptPin(pin: String, complete: @escaping completed)
}

protocol PinResultDelegate {
    func acceptPinSuccessful(from state: PinDisplay.LockState)
    func sessionCancelled()
}

class PinDisplay: UIView, PinDisplayDelegate {
    
    public enum LockState {
        case SetPin
        case AccessPin
        case RemovePin
        case ConfirmPin
        
        func getState() -> PinLockState {
            
            switch self {
            case .SetPin: return SetPinState()
            case .AccessPin: return AccessPinState()
            case .RemovePin: return RemovePinState()
            case .ConfirmPin: return ConfirmPinState(pin: "")
            }
        }
    }
    
    @IBOutlet weak var pinStack: UIStackView!
    @IBOutlet weak var instructionLbl: UILabel!
    
    private var pinGroup: [PinView] = []
    private var delegate: PinResultDelegate?
    private var state: LockState = LockState.SetPin
    private var _newPin: String = ""
    private var _confirmPin: String = ""
    var newPin: String {
        get { return _newPin }
        set {
            if newPin.count < 4 {
                _newPin = newValue
                if _newPin.count == 4 {
                    if state == PinDisplay.LockState.SetPin {
                        setupConfirmationPin()
                    } else {
                        var currentState = state.getState()
                        currentState.acceptPin(pin: _newPin, complete: { (result) in
                            self.handlePin(result: result, for: self.state)
                        })
                    }
                }
            } else if newPin.count == 4 && newValue == "" {
                _newPin = newValue
            }
        }
    }
    
    var confirmPin: String {
        get { return _confirmPin }
        set {
            if confirmPin.count < 4 {
                _confirmPin = newValue
                if _confirmPin.count == 4 {
                    let currentState = ConfirmPinState(pin: newPin)
                    currentState.acceptPin(pin: confirmPin, complete: { (result) in
                        self.handlePin(result: result, for: self.state)
                    })
                }
            } else if confirmPin.count == 4 && newValue == "" {
                _confirmPin = newValue
            }
        }
    }
    
    func assignDelegate(_ delegate: PinResultDelegate, with state: LockState ) {
        self.state = state
        self.delegate = delegate
        if state == .AccessPin {
            setupFaceId()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPins()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPins()
    }
    
    override func layoutSubviews() {
        instructionLbl.text = state.getState().title
    }
    
    func resetConfirmationPin() {
        pinStack.shake()
        confirmPin = ""
        for pin in self.pinGroup { pin.empty() }
    }
    
    func setupPins() {
        for i in 1...4 {
            if let pin = viewWithTag(i) as? PinView {
                pinGroup.append(pin)
            }
        }
    }
    
    func handlePin(result: Bool, for state: PinDisplay.LockState) {
        switch result {
        case true:
            delegate?.acceptPinSuccessful(from: state)
        case false:
            switch state {
            case .ConfirmPin: resetConfirmationPin()
            default:
                pinStack.shake()
                newPin = ""
                for pin in self.pinGroup { pin.empty() }
            }
        }
    }
    
    func setupConfirmationPin() {
        state = .ConfirmPin
        UIView.animate(withDuration: 0.25, animations: {
            for pin in self.pinGroup { pin.empty() }
            self.alpha = 0
        }) { (_) in
            UIView.animate(withDuration: 0.15, animations: {
                self.alpha = 1
                self.instructionLbl.text = PinStateStrings.confirmPinTitle
            })
        }
    }
    
    func fillPin(_ nextCharacter: String) {
        let pinToAlter = pinGroup.first(where: {$0.isEmptyPin() == true})
        pinToAlter?.fill()
        add(nextCharacter)
    }
    
    func emptyPin() {
        let reversedPins = pinGroup.reversed()
        let pinToAlter = reversedPins.first(where: {$0.isEmptyPin() == false})
        pinToAlter?.empty()
        minusCharacter()
    }
    
    func leftBtnAction() {
        state.getState().isCancellable
            ? delegate?.sessionCancelled()
            : setupFaceId()
    }
    
    func add(_ character: String) {
        state == LockState.ConfirmPin
            ? (confirmPin += character)
            : (newPin += character)
    }
    
    func minusCharacter() {
        state == LockState.ConfirmPin
            ? (confirmPin.count > 1 ? (confirmPin = String(confirmPin.dropLast())) : (confirmPin = ""))
            : (newPin.count > 1 ? (newPin = String(newPin.dropLast())) : (newPin = ""))
    }
    
    func setupFaceId() {
        let context = LAContext()
        var permissionString = AuthStrings.faceId
        var authError: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            if context.biometryType == .faceID {
                permissionString = AuthStrings.faceId
            } else if context.biometryType == .touchID {
                permissionString = AuthStrings.touchId
            }
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: permissionString) { (success, err) in
                DispatchQueue.main.async {
                    if err != nil { debugPrint("Error:", err?.localizedDescription as Any)}
                    if success {
                        UIView.animate(withDuration: 0.3, animations: {
                            for pin in self.pinGroup { pin.fill() }
                        }, completion: { (_) in
                            self.delegate?.acceptPinSuccessful(from: self.state)
                        })
                    } else {
                        self.pinStack.shake()
                    }
                }
            }
        } else {
            debugPrint("Error on biometrics policy")
        }
    }

}
