//
//  CreateWalletVC.swift
//  Blockstart
//
//  Created by Nathan Brewer on 7/3/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

class CreateWalletVC: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var instructionsLbl: UILabel!
    @IBOutlet weak var walletNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var fauxInput: UITextField!
    @IBOutlet weak var greyBlockView: UIView!
    @IBOutlet weak var currentNetworkLbl: UILabel!
    
    private var confirmPasswordTF = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        confirmPasswordTF.isSecureTextEntry = true
        let action = #selector(passwordConfirmed)
        let accessory = createAccessoryView(btnTitle: NEXT, btnColor: .primaryLight, action: action, input: confirmPasswordTF, inputPlaceholder: RETYPE_PASSWORD)
         fauxInput.inputAccessoryView = accessory
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentNetworkLbl.text = currentNetwork()
        let keyboardDismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(keyboardDismissTap)
        let dismissPwdTF = UITapGestureRecognizer(target: self, action: #selector(dismissPwdConfirm))
        greyBlockView.addGestureRecognizer(dismissPwdTF)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        fauxInput.inputAccessoryView = nil
        view.gestureRecognizers?.removeAll()
        greyBlockView.gestureRecognizers?.removeAll()
    }
    
    @objc func dismissPwdConfirm() {
        _ = textFieldShouldReturn(confirmPasswordTF)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupScreen() {
        instructionsLbl.addBoldText(fullText: WalletCreation.enterWalletAndPwd, bold: WalletCreation.newWalletBoldText)
        walletNameTF.assignPlaceholder(with: WalletCreation.walletName)
        passwordTF.assignPlaceholder(with: PASSWORD)
        confirmPasswordTF = UITextField()
        confirmPasswordTF.delegate = self
        confirmPasswordTF.addTarget(self, action: #selector(textFieldWasEdited), for: .editingChanged)
    }
    
    @objc func passwordConfirmed() {
        guard let pwd = passwordTF.text, let confirmPwd = confirmPasswordTF.text else { return }
        if Validators.stringsMatch(pwd, strTwo: confirmPwd) {
            guard let walletName = walletNameTF.text else { return }
            var createWallet = CreateWallet()
            createWallet.name = walletName.removeUnsupportedCharacters
            createWallet.password = pwd
            Wallet.createWallet(createWallet: createWallet, onComplete: { (_) in
                self.performSegue(withIdentifier: Segues.toBackupWalletVC, sender: self)
            }) { (_) in
                self.present(Alert.instance.singleMsgAlert(title: "Error creating wallet", message: "A new wallet was not created, please try again"), animated: true, completion: nil)
            }
        } else {
            confirmPasswordTF.shake()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        greyBlockView.alpha = 0
        view.endEditing(true)
        return true
    }
    
    @objc func textFieldWasEdited() {
        confirmPasswordTF.layer.borderWidth = 0
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextBtnTapped(_ sender: UIButton) {
        guard let pwd = passwordTF.text, let name = walletNameTF.text else { return }
        if Validators.newAccountInfoIsValid(pwd, walletName: name) {
            fauxInput.becomeFirstResponder()
            UIView.animate(withDuration: 0.2) {
                self.confirmPasswordTF.becomeFirstResponder()
                self.greyBlockView.alpha = 0.3
            }
        } else {
            present(Alert.instance.singleMsgAlert(title: AlertMessage.completeForm, message: AlertMessage.passwordLengthCheck), animated: true, completion: nil)
        }
    }
    
}
