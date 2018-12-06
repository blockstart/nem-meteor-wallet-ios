//
//  BackupWalletVC.swift
//  Blockstart
//
//  Created by Nathan Brewer on 7/5/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import MessageUI
import Lottie
import Photos

class BackupWalletVC: BaseVC, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var headerTextLbl: UILabel!
    @IBOutlet weak var subTextLbl: UILabel!
    @IBOutlet weak var greyBlockView: UIView!
    @IBOutlet weak var fauxInput: UITextField!
    @IBOutlet weak var currentNetworkLbl: UILabel!
    
    private var composer = EmailManager()
    private var emailTF = UITextField()
    private var email = ""
    private var scanner = QRCodeScanner()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentNetworkLbl.text = currentNetwork()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        fauxInput.inputAccessoryView = nil
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        let action = #selector(backupWallet)
        emailTF.keyboardType = .emailAddress
        let accessory = createAccessoryView(btnTitle: WalletCreation.sendBackupFile, btnColor: .primaryLight, action: action, input: emailTF, inputPlaceholder: WalletCreation.typeEmail)
        fauxInput.inputAccessoryView = accessory
    }
    
    func setupScreen() {
        headerTextLbl.addBoldText(fullText: WalletCreation.backupWalletHeader, bold: WalletCreation.backupWalletBoldText)
        emailTF = UITextField()
        emailTF.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        greyBlockView.alpha = 0
        view.endEditing(true)
        return true
    }
    
    func showBackupEmail(_ qrString: String) {
        composer = EmailManager()
        if composer.canCompose {
            composer.delegate = self
            composer.subject = EmailMessage.emailSubject
            composer.recipients = [self.email]
            composer.body = ""
            if let qrImg = self.scanner.generateQRCode(from: qrString) {
                if let data = UIImagePNGRepresentation(qrImg) {
                    composer.attachmentData = data
                    composer.show()
                }
            }
        } else {
            present(Alert.instance.singleMsgAlert(title: ERROR, message: EmailMessage.noEmailFound), animated: true, completion: nil)
        }
    }
    
    @objc func backupWallet() {
        guard let email = emailTF.text else { return }
        self.email = email.lowercased()
        let account = Account.fromCache(key: AppState.fromCache().selectedAddress)
        Wallet.exportWallet(wallet: account.wallet, onComplete: { (data) in
            if let qrString = data as? QRString {
                self.showBackupEmail(qrString.qrstring)
            }
        }) { (err) in
            if let err = err as? APIError {
                debugPrint("Error exporting wallet", err.message)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        composer.hide()
        if result == .sent {
            goToConfirmationScreen()
        } else {
            present(Alert.instance.singleMsgAlert(title: ERROR, message: AlertMessage.emailNotSent), animated: true, completion: nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.emailSentVC) as? EmailSentVC {
            vc.assignBackupMethod(WalletCreation.photosApp, header: WalletCreation.photoBackup)
            present(vc, animated: true, completion: nil)
        }
    }
    
    func goToConfirmationScreen() {
        if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.emailSentVC) as? EmailSentVC {
            vc.assignBackupMethod("\n\(email)", header: EmailMessage.emailSentAddress)
            present(vc, animated: true, completion: nil)
        }
    }
    
    func saveQRImageToPhotos(_ qrString: String) {
        let auth = PHPhotoLibrary.authorizationStatus()
        switch auth {
        case .authorized:
            if let qrImg = scanner.generateQRCode(from: qrString) {
                UIImageWriteToSavedPhotosAlbum(qrImg, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
            break
        case .denied:
            self.present(Alert.instance.singleMsgAlert(title: ERROR, message: AlertMessage.noPhotoPermission), animated: true, completion: nil)
            break
        default:
            PHPhotoLibrary.requestAuthorization { (_) in
                self.saveQRImageToPhotos(qrString)
            }
            break
        }
    }
    
    @IBAction func backupWalletBtnTapped(_ sender: UIButton) {
        fauxInput.becomeFirstResponder()
        UIView.animate(withDuration: 0.2) {
            self.emailTF.becomeFirstResponder()
            self.greyBlockView.alpha = 0.3
        }
    }
    
    @IBAction func saveBackupWalletToPhotos(_ sender: UIButton) {
        let account = Account.fromCache(key: AppState.fromCache().selectedAddress)
        Wallet.exportWallet(wallet: account.wallet, onComplete: { (data) in
            if let qrString = data as? QRString {
                self.saveQRImageToPhotos(qrString.qrstring)
            }
        }) { (err) in
            if let err = err as? APIError {
                debugPrint("Error exporting wallet", err.message)
            }
        }
    }
    
    @IBAction func postponeBackupBtnTapped(_ sender: UIButton) {
        let lottie = LOTAnimationView(name: AnimationJson.checkmarkGreen)
        view.addLottieAnimation(lottie) {
            self.fadeOut()
        }
    }
    
    func fadeOut() {
        if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.rootVC) as? RootController {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}




