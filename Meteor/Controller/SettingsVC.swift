//
//  SettingsVC.swift
//  Meteor
//
//  Created by Nathan Brewer on 8/29/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

enum SettingsData {
    case language(Language)
    case currency(Currency)
}

struct Language {
    var titles = [String]()
    init(languages: [String]) {
        self.titles = languages
    }
}

struct Currency {
    var titles: [String]
    init(codes: [String]) {
        self.titles = codes
    }
}

protocol PrivateKeyDelegate {
    func privateKeyPrompt()
}

protocol NetworkChangeDelegate {
    func networkChanged()
}

class SettingsVC: BaseVC, UITextFieldDelegate {

    @IBOutlet weak var greyBlockView: UIView!
    @IBOutlet weak var fauxInput: UITextField!
    
    private var passwordInput = UITextField()
    private var privateKeyView = PrivateKeyModal()
    private var account: Account = Account.fromCache(key: AppState.fromCache().selectedAddress)
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        passwordInput.isSecureTextEntry = true
        passwordInput.addTarget(self, action: #selector(textFieldWasEdited), for: .editingChanged)
        let action = #selector(passwordConfirmed)
        let accessory = createAccessoryView(btnTitle: SHOW, btnColor: .primaryLight, action: action, input: passwordInput, inputPlaceholder: PASSWORD_PLACEHOLDER)
        fauxInput.inputAccessoryView = accessory
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let privateKeyModal = Bundle.main.loadNibNamed(XibStrings.privateKeyModal, owner: self, options: nil)?[0] as? PrivateKeyModal {
            privateKeyView = privateKeyModal
        }
        passwordInput.delegate = self
        fauxInput.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNetworkStatus()
        let dismissPwdTF = UITapGestureRecognizer(target: self, action: #selector(dismissPwdConfirm))
        dismissPwdTF.cancelsTouchesInView = false
        greyBlockView.addGestureRecognizer(dismissPwdTF)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removePrivateKeyModal()
        greyBlockView.gestureRecognizers?.removeAll()
    }
    
    @objc func dismissPwdConfirm() {
        removePrivateKeyModal()
        _ = textFieldShouldReturn(passwordInput)
    }
    
    func removePrivateKeyModal() {
        if view.subviews.contains(privateKeyView) {
            privateKeyView.removeFromSuperview()
        }
        greyBlockView.alpha = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        greyBlockView.backgroundColor = .black
        greyBlockView.alpha = 0
        view.endEditing(true)
        return true
    }
    
    @objc func textFieldWasEdited() {
        passwordInput.layer.borderWidth = 0
    }
    
    @objc func passwordConfirmed() {
        privateKeyView.center = view.center
        privateKeyView.alpha = 0
        view.addSubview(privateKeyView)
        let getPrivateKey = GetPrivateKey.init(wallet: account.wallet, password: passwordInput.text?.trim() ?? "")
        Wallet.getPrivateKey(getPrivateKey: getPrivateKey, onComplete: { (pk) in
            self.passwordInput.resignFirstResponder()
            self.fauxInput.resignFirstResponder()
            UIView.animate(withDuration: 0.3) {
                self.passwordInput.text = ""
                self.privateKeyView.setPrivateKey(pk as? String ?? "")
                self.greyBlockView.backgroundColor = .white
                self.greyBlockView.alpha = 0.8
                self.privateKeyView.alpha = 1
            }
        }) { (_) in
            self.passwordInput.shake()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.settingsContainer {
            if let vc = segue.destination as? SettingsTableVC {
                vc.assignDelegateOwner(self, networkDelegate: self)
            }
        }
    }

}

extension SettingsVC: PrivateKeyDelegate, NetworkChangeDelegate {
    
    func privateKeyPrompt() {
        fauxInput.becomeFirstResponder()
        UIView.animate(withDuration: 0.2) {
            self.greyBlockView.alpha = 0.3
            self.passwordInput.becomeFirstResponder()
        }
    }
    
    func networkChanged() {
        setNetworkStatus()
        account = Account.fromCache(key: AppState.fromCache().selectedAddress)
    }
}
