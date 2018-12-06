//
//  PinLockStateTypes.swift
//  Meteor
//
//  Created by Nathan Brewer on 10/11/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

struct SetPinState: PinLockState {
    
    let title = PinStateStrings.setPinTitle
    var isFaceIdAllowed = false
    var isCancellable = true

    func acceptPin(pin: String, complete: @escaping SetPinState.completed) {}
}

struct ConfirmPinState: PinLockState {
    
    let title = PinStateStrings.confirmPinTitle
    var isFaceIdAllowed = false
    var isCancellable = true
    
    private var pinToConfirm: String
    
    init(pin: String) {
        self.pinToConfirm = pin
    }
    
    func acceptPin(pin: String, complete: @escaping ConfirmPinState.completed) {
        if pin == pinToConfirm {
            var auth = LocalAuth.fromCache()
            auth.privatePin = pin
            auth.pinLockEnabled = true
            auth.save()
            complete(true)
        } else {
            complete(false)
        }
    }
}

struct AccessPinState: PinLockState {
    
    let title = PinStateStrings.accessPinTitle
    var isFaceIdAllowed = true
    var isCancellable = false
    
    func acceptPin(pin: String, complete: @escaping AccessPinState.completed) {
        if pin == LocalAuth.fromCache().privatePin {
            complete(true)
        } else {
            complete(false)
        }
        
    }
}

struct RemovePinState: PinLockState {
    
    let title = PinStateStrings.removePinTitle
    var isFaceIdAllowed = true
    var isCancellable = true
    
    func acceptPin(pin: String, complete: @escaping RemovePinState.completed) {
        if pin == LocalAuth.fromCache().privatePin {
            var auth = LocalAuth.fromCache()
            auth.privatePin = ""
            auth.pinLockEnabled = false
            auth.save()
            complete(true)
        } else {
            complete(false)
        }
    }
}
