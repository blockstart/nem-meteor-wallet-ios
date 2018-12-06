//
//  NewWalletVC.swift
//  Blockstart
//
//  Created by Nathan Brewer on 7/3/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import AVFoundation

class NewWalletVC: BaseVC, QRScanner, UITextFieldDelegate {
    
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var qrContainerView: UIView!
    @IBOutlet weak var scannerHeaderView: UIView!
    @IBOutlet weak var importWalletBtn: UIButton!
    @IBOutlet weak var starBg: UIImageView!
    @IBOutlet weak var greyBlockView: UIView!
    @IBOutlet weak var fauxInput: UITextField!
    @IBOutlet weak var currentNetworkLbl: UILabel!
    
    fileprivate var scanner = QRCodeScanner()
    private var passwordInput = UITextField()
    var nanoWalletQRObj: NanoQRObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addParallaxEffect(starBg)
        fauxInput.delegate = self
        passwordInput = UITextField()
        let action = #selector(confirmedImportWalletPwd)
        let accessory = createAccessoryView(btnTitle: WalletCreation.importText, btnColor: .bsRed, action: action, input: passwordInput, inputPlaceholder: WalletCreation.existingPassword)
        passwordInput.delegate = self
        passwordInput.isSecureTextEntry = true
        passwordInput.addTarget(self, action: #selector(textFieldWasEdited), for: .editingChanged)
        fauxInput.inputAccessoryView = accessory
        importWalletBtn.isHidden = AppState.fromCache().selectedAddress != ""
        closeBtn.isHidden = AppState.fromCache().selectedAddress == ""
        scannerHeaderView.backgroundColor = UIColor.primaryLight
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentNetworkLbl.text = currentNetwork()
    }
    
    @objc func confirmedImportWalletPwd() {
        guard let pwd = passwordInput.text, let nanoQr = nanoWalletQRObj else { return }
        let qrObj = QRObject.init(data: nanoQr.data, password: pwd)
        Wallet.importWalletQRObject(qrObject: qrObj, onComplete: { (_) in
            _ = self.textFieldShouldReturn(self.passwordInput)
            if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.rootVC) as? RootController {
                self.present(vc, animated: true, completion: nil)
            }
        }) { (err) in
            if let _ = err as? APIError {
                self.passwordInput.shake()
            } else {
                Alert.instance.showErrorAlert(err, presenter: self)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        view.endEditing(true)
        greyBlockView.alpha = 0
        return true
    }
    
    @objc func textFieldWasEdited() {
        passwordInput.layer.borderWidth = 0
    }
    
    func setupQRScanner() {
        scanner = QRCodeScanner()
        scanner.delegate = self
        scanner.checkCameraPermissions { (granted) in
            if granted {
                DispatchQueue.main.async {
                    let bottomPadding: CGFloat = 160
                    self.scanner.prepareCaptureSession(bottomPadding)
                    self.scanner.videoPreview.frame = self.qrContainerView.bounds
                    self.qrContainerView.addSubview(self.scanner.videoPreview)
                    self.scanner.animateFadeInOut(true, views: [self.scannerHeaderView, self.qrContainerView])
                }
            }
        }
    }
    
    func accessDenied() {
        present(Alert.instance.singleMsgAlert(title: AlertMessage.notAuthorized, message: AlertMessage.cameraAccess), animated: true, completion: nil)
    }
    
    func cancelSession() {
        scanner.animateFadeInOut(false, views: [scannerHeaderView, qrContainerView])
        scanner.videoPreview.removeFromSuperview()
    }
    
    func scanResult(result: String) {
        navigationItem.title = WalletHomeStrings.myWallets
        qrContainerView.subviews.last?.removeFromSuperview()
        scanner.videoPreview.removeFromSuperview()
        qrContainerView.alpha = 0
        scannerHeaderView.alpha = 0
        if let data = result.data(using: .utf8) {
            if let nanoQr = data.returnResult(NanoQRObject.self) {
                if (AppState.fromCache().currentNetwork == NetworkTypeStrings.main) {
                    if nanoQr.v != WalletV.main.rawValue {
                        self.present(Alert.instance.incorrectNetwork(AlertMessage.wrongNetwork), animated: true, completion: nil)
                        return
                    }
                } else {
                    if nanoQr.v != WalletV.test.rawValue && nanoQr.v != WalletV.testAlt.rawValue {
                        self.present(Alert.instance.incorrectNetwork(AlertMessage.wrongNetwork), animated: true, completion: nil)
                        return
                    }
                }
                let formattedName = nanoQr.data.name.removeUnsupportedCharacters
                self.nanoWalletQRObj = nanoQr
                self.nanoWalletQRObj?.data.name = formattedName
                fauxInput.becomeFirstResponder()
                UIView.animate(withDuration: 0.2) {
                    self.greyBlockView.alpha = 0.3
                    self.passwordInput.becomeFirstResponder()
                }
            } else {
                Wallet.importWalletQRString(qrString: QRString.init(qrstring: result), onComplete: { (_) in
                    self.goToHomeVC()
                }) { (err) in
                    Alert.instance.showErrorAlert(err, presenter: self)
                }
            }
        }
    }
    
    func goToHomeVC() {
        if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.rootVC) as? RootController {
            present(vc, animated: true, completion: nil)
        }
    }
    
    func addParallaxEffect(_ v: UIView) {
        let amount = 100
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        v.addMotionEffect(group)
    }
    
    func showWalletOptions() {
        let alert = UIAlertController(title: WalletHomeStrings.newWallet, message: nil, preferredStyle: .actionSheet)
        let importWithQR = UIAlertAction(title: WalletHomeStrings.importWallet, style: .default) { (action) in
            self.setupQRScanner()
        }
        
        let importWithPrivateKey = UIAlertAction(title: WalletHomeStrings.importFromPK, style: .default) { (action) in
            self.prepareImportWalletScreen()
        }
        
        let cancelBtn = UIAlertAction(title: CANCEL, style: .cancel) { (_) in }
        alert.addAction(importWithQR)
        alert.addAction(importWithPrivateKey)
        alert.addAction(cancelBtn)
        present(alert, animated: true, completion: nil)
    }
    
    func prepareImportWalletScreen() {
        if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.importWalletVC) as? ImportWalletVC {
            present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func createBtnTapped(_ sender: UIButton) {
        performSegue(withIdentifier: Segues.toCreateWalletVC, sender: self)
    }

    @IBAction func closeBtnTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func importExistingWalletTapped(_ sender: UIButton) {
        showWalletOptions()
    }
    
}
