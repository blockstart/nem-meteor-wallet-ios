//
//  ImportWalletVC.swift
//  Meteor
//
//  Created by Nathan Brewer on 7/25/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import Lottie

class ImportWalletVC: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var privateKeyTF: UITextField!
    @IBOutlet weak var walletNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var greyBlockView: UIView!
    @IBOutlet weak var fauxInput: UITextField!
    @IBOutlet weak var currentNetworkLbl: UILabel!
    
    private var confirmPwdTF = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instructionLbl.addBoldText(fullText: WalletCreation.importWalletHeader, bold: WalletCreation.importWalletHeaderBold)
        privateKeyTF.assignPlaceholder(with: WalletCreation.privateKey)
        walletNameTF.assignPlaceholder(with: WalletCreation.newWalletName)
        passwordTF.assignPlaceholder(with: PASSWORD)
        confirmPwdTF.delegate = self
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        confirmPwdTF.isSecureTextEntry = true
        confirmPwdTF.addTarget(self, action: #selector(textFieldWasEdited), for: .editingChanged)
        let action = #selector(passwordConfirmed)
        let accessory = createAccessoryView(btnTitle: NEXT, btnColor: .primaryLight, action: action, input: confirmPwdTF, inputPlaceholder: RETYPE_PASSWORD)
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
    
    @objc func textFieldWasEdited() {
        confirmPwdTF.layer.borderWidth = 0
    }
    
    @objc func dismissPwdConfirm() {
        _ = textFieldShouldReturn(confirmPwdTF)
    }
    
    @objc func passwordConfirmed() {
        guard let pk = privateKeyTF.text else { return }
        if let pass = passwordTF.text, let walletName = walletNameTF.text?.removeUnsupportedCharacters, let pwdConfirm = confirmPwdTF.text {
            if Validators.newAccountInfoIsValid(pass, walletName: walletName) && Validators.stringsMatch(pass, strTwo: pwdConfirm) {
                let newWallet = CreateWallet.init(name: walletName, password: pass, privateKey: pk)
                Wallet.createWallet(createWallet: newWallet, onComplete: { (_) in
                    let lottie = LOTAnimationView(name: AnimationJson.checkmarkGreen)
                    self.view.addLottieAnimation(lottie) {
                        self.fadeOut()
                    }
                }) { (err) in
                    if let err = err as? APIError {
                        self.present(Alert.instance.singleMsgAlert(title: ERROR, message: err.message), animated: true, completion: nil)
                    } else {
                        Alert.instance.showErrorAlert(err, presenter: self)
                    }
                }
            } else {
                confirmPwdTF.shake()
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        greyBlockView.alpha = 0
        view.endEditing(true)
        return true
    }
    
    @IBAction func nextBtnTapped(_ sender: Button) {
        guard let pwd = passwordTF.text, let name = walletNameTF.text else { return }
        if Validators.newAccountInfoIsValid(pwd, walletName: name) {
            fauxInput.becomeFirstResponder()
            UIView.animate(withDuration: 0.2) {
                self.greyBlockView.alpha = 0.3
                self.confirmPwdTF.becomeFirstResponder()
            }
        } else {
            present(Alert.instance.singleMsgAlert(title: AlertMessage.completeForm, message: AlertMessage.passwordLengthCheck), animated: true, completion: nil)
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func fadeOut() {
        if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.rootVC) as? RootController {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}
