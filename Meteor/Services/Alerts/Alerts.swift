//
//  Alerts.swift
//  Blockstart
//
//  Created by Nathan Brewer on 7/17/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

class Alert {
    static let instance = Alert()
    
    func singleMsgAlert(title: String?, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okBtn)
        return alert
    }
    
    func singleMsgAlertWithDismiss(title: String?, message: String, parent: UIViewController) -> UIAlertController {
        let alert = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .default) { (action) in
            parent.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okBtn)
        return alert
    }
    
    func incorrectNetwork(_ msg: String) -> UIAlertController {
        return singleMsgAlert(title: AlertMessage.incorrectNetwork, message: msg)
    }
    
    func duplicateImport(_ msg: String) -> UIAlertController {
        return singleMsgAlert(title: AlertMessage.duplicateTitle , message: msg)
    }
    
    func showErrorAlert(_ error: Any, presenter: UIViewController) {
        if let err = error as? IncorrectNetworkError {
            presenter.present(Alert.instance.incorrectNetwork(err.message), animated: true, completion: nil)
        } else if let err = error as? DuplicateImportError {
            presenter.present(Alert.instance.duplicateImport(err.message), animated: true, completion: nil)
        } else if let _ = error as? APIError {
            presenter.present(Alert.instance.singleMsgAlert(title: AlertMessage.badQRCode, message: AlertMessage.scanProperQRCode), animated: true, completion: nil)
        }
    }
}
