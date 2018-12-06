//
//  SendConfirmationVC.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/27/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import Lottie

class SendConfirmationVC: BaseVC, UITextFieldDelegate {

    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var currencyTypeLbl: UILabel!
    @IBOutlet weak var recipientAddressLbl: UILabel!
    @IBOutlet weak var messageTF: UITextField!
    @IBOutlet weak var fromWalletLbl: UILabel!
    @IBOutlet weak var transactionFeeLbl: UILabel!
    @IBOutlet weak var greyBlockView: UIView!
    @IBOutlet weak var fauxInput: UITextField!
    @IBOutlet weak var usdValueLbl: UILabel!
    @IBOutlet weak var rocketImgView: UIImageView!
    
    private var account = Account.fromCache(key: AppState.fromCache().selectedAddress)
    private var passwordInput = UITextField()
    private var createdTx = CreateTransaction()
    private var selectedMosaic = Mosaic()
    private var divisibility = 6
    private var xemDivisibility = 6
    private var rocketAnimation = LOTAnimationView()
    private var spinner = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNetworkStatus()
        let keyboardDismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        keyboardDismissTap.cancelsTouchesInView = false
        greyBlockView.addGestureRecognizer(keyboardDismissTap)
        usdValueLbl.isHidden = !selectedMosaic.isXEM
    }
    
    @objc func dismissKeyboard() {
        _ = textFieldShouldReturn(passwordInput)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        passwordInput.resignFirstResponder()
        greyBlockView.gestureRecognizers?.removeAll()
        rocketAnimation.gestureRecognizers?.removeAll()
    }
    
    func setupScreen() {
        CurrencyConverter.instance.convert(selectedMosaic.mosaicId.name) { (_) in
            let val = self.createdTx.mosaic.quantity.localeValue(self.divisibility)
            self.usdValueLbl.text = val
        }
        passwordInput = UITextField()
        amountLbl.text = createdTx.mosaic.quantity.decimalFormat(divisibility).thousandsSeparator(divisibility)
        recipientAddressLbl.text = createdTx.address
        currencyTypeLbl.text = "\(createdTx.mosaic.mosaicId.name) to:"
        fromWalletLbl.text = "\(account.wallet.name) \(lastPartOfAddress(account.address))"
        messageView.layer.masksToBounds = false
        messageView.layer.addDropShadow()
        let action = #selector(handleTransaction(_:))
        let accessory = createAccessoryView(btnTitle: SEND, btnColor: .bsRed, action: action, input: passwordInput)
        passwordInput.delegate = self
        passwordInput.isSecureTextEntry = true
        passwordInput.addTarget(self, action: #selector(textFieldWasEdited), for: .editingChanged)
        fauxInput.inputAccessoryView = accessory
    }
    
    func loadTransactionInfo(_ tx: CreateTransaction, userMosaic: Mosaic) {
        createdTx = tx
        selectedMosaic = userMosaic
        Deeplinker.clearUserDefaults()
        divisibility = tx.mosaic.properties.divisibility
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        greyBlockView.alpha = 0
        view.endEditing(true)
        return true
    }
    
    @objc func textFieldWasEdited() {
        passwordInput.layer.borderWidth = 0
    }
    
    func lastPartOfAddress(_ address: String) -> String {
        return " (...\(address.suffix(4)))"
    }
    
    @objc func handleTransaction(_ sender: UIButton) {
        spinner.activityIndicatorViewStyle = .white
        spinner.hidesWhenStopped = true
        fauxInput.inputAccessoryView?.addSubview(spinner)
        spinner.center = sender.center
        buttonState(toDefault: false, button: sender)
        guard let pwd = passwordInput.text else { return }
        createdTx.message = messageTF.text ?? ""
        Transaction.create(createTransaction: createdTx, onComplete: { (data) in
            if let tx = data as? Transaction {
                if self.ownsEnoughToCoverFee(tx) {
                    let send = SendTransaction.init(wallet: self.account.wallet, transferTransaction: tx, password: pwd)
                    self.sendTransaction(send, sender: sender)
                } else {
                    self.buttonState(toDefault: true, button: sender)
                    self.present(Alert.instance.singleMsgAlert(title: AlertMessage.insufficientFunds, message: "You need \(tx.fee.decimalFormat(self.xemDivisibility)) XEM to cover the fee"), animated: true, completion: nil)
                }
            }
        }) { (_) in
            self.buttonState(toDefault: true, button: sender)
            self.passwordInput.shake()
        }
    }
    
    func buttonState(toDefault: Bool, button: UIButton) {
        button.alpha = toDefault ? 1 : 0.5
        let buttonTitle = toDefault ? SEND : ""
        button.setTitle(buttonTitle, for: .normal)
        _ = toDefault ? spinner.stopAnimating() : spinner.startAnimating()
    }
    
    func sendTransaction(_ send: SendTransaction, sender: UIButton) {
        Transaction.send(sendTransaction: send, onComplete: { (_) in
            _ = self.textFieldShouldReturn(self.passwordInput)
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            let rocket = self.createRocketAnimationImg()
            rocket.play(toProgress: 0.95) { (finished) in
                if finished {
                    self.goToSendHomeScreen()
                }
            }
        }) { (_) in
            self.buttonState(toDefault: true, button: sender)
            self.passwordInput.shake()
        }
    }
    
    func ownsEnoughToCoverFee(_ tx: Transaction) -> Bool {
        if createdTx.mosaic.isXEM {
            return createdTx.mosaic.quantity + tx.fee <= selectedMosaic.quantity
        } else {
            if let xem = account.mosaics.first(where: {$0.mosaicId.name.uppercased() == XEM}) {
                return xem.quantity >= tx.fee
            }
        }
        return false
    }
    
    func goToSendHomeScreen() {
        if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.rootVC) as? RootController {
            vc.deepLinkAddress = createdTx.address
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .currentContext
            present(vc, animated: true, completion: nil)
        }
    }
    
    func createRocketAnimationImg() -> LOTAnimationView {
        rocketAnimation = LOTAnimationView(name: AnimationJson.nemMoon)
        rocketAnimation.frame = view.bounds
        rocketAnimation.contentMode = .scaleAspectFill
        let tap = UITapGestureRecognizer(target: self, action: #selector(endAnimation))
        rocketAnimation.addGestureRecognizer(tap)
        rocketImgView.addSubview(rocketAnimation)
        rocketImgView.alpha = 1
        return rocketAnimation
    }
    
    @objc func endAnimation() {
        if rocketAnimation.isAnimationPlaying {
            rocketAnimation.stop()
            goToSendHomeScreen()
        }
    }
    
    @IBAction func messageEdited(_ sender: UITextField) {
        guard let message = messageTF.text else { return }
        createdTx.message = message
        Transaction.create(createTransaction: createdTx, onComplete: { (data) in
            if let tx = data as? Transaction {
                let fee = tx.fee.decimalFormat(self.xemDivisibility)
                self.transactionFeeLbl.text = "\(fee) XEM"
            }
        }) { (err) in
            if let err = err as? APIError {
                debugPrint(err.message)
            }
        }
    }
    
    @IBAction func sendTransactionBtnTapped(_ sender: UIButton) {
        fauxInput.becomeFirstResponder()
        UIView.animate(withDuration: 0.2) {
            self.greyBlockView.alpha = 0.3
            self.passwordInput.becomeFirstResponder()
        }
    }
}
