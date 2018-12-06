//
//  WalletHomeVC.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/26/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation
import Lottie

class WalletHomeVC: BaseVC, UITableViewDelegate, UITableViewDataSource, QRScanner, DropdownDelegate, UITextFieldDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var qrContainerView: UIView!
    @IBOutlet weak var xemPriceLocaleLbl: UILabel!
    @IBOutlet weak var localValue: UILabel!
    @IBOutlet weak var walletDropdown: UIView!
    @IBOutlet weak var dropdownTable: UITableView!
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var selectedWalletLbl: UILabel!
    @IBOutlet weak var dropdownTableHeight: NSLayoutConstraint!
    @IBOutlet weak var shadowViewHeight: NSLayoutConstraint!
    @IBOutlet weak var fauxInput: UITextField!
    @IBOutlet weak var greyBlockView: UIView!
    @IBOutlet weak var xemPriceHolderView: UIView!
    
    private var account: Account = Account.fromCache(key: AppState.fromCache().selectedAddress)
    private var appState = AppState.fromCache()
    fileprivate var dropdownOpen = false
    var dropdownTableDelegate: DropDownTableDelegate?
    var scanner = QRCodeScanner()
    var passwordInput = UITextField()
    var nanoWalletQRObj: NanoQRObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if LocalAuth.fromCache().pinLockEnabled {
            if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.pinVC) as? PinVC {
                vc.setInitialState(.AccessPin)
                present(vc, animated: false, completion: nil)
            }
        }
        addSocketConnectObserver(#selector(setNetwork), owner: self)
        addSocketListeningObserver(#selector(loadData), owner: self)
        addSocketConfirmedTxObserver(#selector(loadData), owner: self)
        addSocketUnconfirmedTxObserver(#selector(loadData), owner: self)
        self.navigationController?.navigationBar.backgroundColor = .bsPrimary
        fauxInput.delegate = self
        passwordInput = UITextField()
        passwordInput.delegate = self
        passwordInput.addTarget(self, action: #selector(textFieldWasEdited), for: .editingChanged)
        xemPriceHolderView.backgroundColor = BSColor.bsPrimary
        selectedWalletLbl.text = account.wallet.name
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        let action = #selector(confirmedImportWalletPwd)
        let accessory = createAccessoryView(btnTitle: WalletCreation.importText, btnColor: .bsRed, action: action, input: passwordInput, inputPlaceholder: WalletCreation.existingPassword)
        passwordInput.isSecureTextEntry = true
        fauxInput.inputAccessoryView = accessory
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.dropdownTableDelegate = nil
        self.dropdownTableDelegate = DropDownTableDelegate(self)
        self.dropdownTable.delegate = self.dropdownTableDelegate
        self.dropdownTable.dataSource = self.dropdownTableDelegate
        CurrencyConverter.instance.localXemRate() { (result) in
            self.localValue.text = result
            self.xemPriceLocaleLbl.text = "\(WalletHomeStrings.xemPrice) (\(CurrencyConverter.instance.localeCode))"
        }
        account = Account.fromCache(key: AppState.fromCache().selectedAddress)
        addGesturesForDropDown()
        SocketService.instance.delegate = self
        setNetworkStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dropdownTable.gestureRecognizers?.removeAll()
    }

    @objc func loadData() {
        account = Account.fromCache(key: AppState.fromCache().selectedAddress)
        self.selectedWalletLbl.text = self.account.wallet.name
        self.account.refresh { (acct) in
            self.tableView.reloadData()
        }
    }

    @objc func setNetwork() {
        appState.switchNetwork(to: appState.currentNetwork, address: appState.selectedAddress) { (_) in
            if self.appState.selectedAddress == "" {
                self.prepareNewWalletScreen()
            } else {
                self.loadData()
            }
        }
    }
    
    @objc func confirmedImportWalletPwd() {
        guard let pwd = passwordInput.text, let nanoQr = nanoWalletQRObj else { return }
        let qrObj = QRObject.init(data: nanoQr.data, password: pwd)
        Wallet.importWalletQRObject(qrObject: qrObj, onComplete: { (_) in
            _ = self.textFieldShouldReturn(self.passwordInput)
            self.loadData()
        }) { (err) in
            if let _ = err as? APIError {
                self.passwordInput.shake()
            } else {
                Alert.instance.showErrorAlert(err, presenter: self)
            }
        }
        navigationItem.leftBarButtonItem?.isEnabled = true
    }
    
    func didSelectCell(_ selection: String) {
        showCurrencyMenu(UITapGestureRecognizer())
        var appState = AppState.fromCache()
        appState.selectedAddress = selection
        appState.save()
        loadData()
    }
    
    func didDeleteCell() {
        if AppState.fromCache().selectedAddress == "" {
            prepareNewWalletScreen()
        } else {
            loadData()
        }
    }
    
    func scanResult(result: String) {
        navigationItem.title = WalletHomeStrings.myWallets
        qrContainerView.subviews.last?.removeFromSuperview()
        scanner.videoPreview.removeFromSuperview()
        qrContainerView.alpha = 0
        if let data = result.data(using: .utf8) {
            if let nanoQr = data.returnResult(NanoQRObject.self) {
                if (AppState.fromCache().currentNetwork == NetworkTypeStrings.main) {
                    if nanoQr.v != WalletV.main.rawValue {
                        self.present(Alert.instance.incorrectNetwork(AlertMessage.wrongNetwork), animated: true, completion: nil)
                        navigationItem.leftBarButtonItem?.isEnabled = true
                        return
                    }
                } else {
                    if nanoQr.v != WalletV.test.rawValue && nanoQr.v != WalletV.testAlt.rawValue {
                        self.present(Alert.instance.incorrectNetwork(AlertMessage.wrongNetwork), animated: true, completion: nil)
                        navigationItem.leftBarButtonItem?.isEnabled = true
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
            }
        } else {
            Wallet.importWalletQRString(qrString: QRString.init(qrstring: result), onComplete: { (_) in
                self.loadData()
            }) { (err) in
                Alert.instance.showErrorAlert(err, presenter: self)
            }
            navigationItem.leftBarButtonItem?.isEnabled = true
        }
    }

    
    func cancelSession() {
        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.title = WalletHomeStrings.myWallets
        scanner.animateFadeInOut(false, views: [qrContainerView])
        scanner.videoPreview.removeFromSuperview()
    }
    
    func accessDenied() {
        present(Alert.instance.singleMsgAlert(title: AlertMessage.notAuthorized, message: AlertMessage.cameraAccess), animated: true, completion: nil)
    }
    
    func setupQRScanner() {
        scanner = QRCodeScanner()
        scanner.delegate = self
        scanner.checkCameraPermissions { (granted) in
            if granted {
                DispatchQueue.main.async {
                    self.navigationItem.leftBarButtonItem?.isEnabled = false
                    let tabbarPadding: CGFloat = 220
                    self.scanner.prepareCaptureSession(tabbarPadding)
                    self.scanner.videoPreview.frame = self.qrContainerView.bounds
                    self.qrContainerView.addSubview(self.scanner.videoPreview)
                    self.scanner.animateFadeInOut(true, views: [self.qrContainerView])
                    self.navigationItem.title = WalletHomeStrings.scanWallet
                }
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
    
    func addGesturesForDropDown() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showCurrencyMenu(_:)))
        walletDropdown.addGestureRecognizer(tap)
    }
    
    func dropdownHeight(_ height: CGFloat) -> CGFloat {
        let maxHeight = tableView.frame.size.height
        return height < maxHeight ? height : maxHeight
    }
    
    @objc func showCurrencyMenu(_ sender: UITapGestureRecognizer) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            let cellCount = Account.allFromCache(addresses: AppState.fromCache().addresses, networkFilter: AppState.fromCache().currentNetwork).count
            let heightValue: CGFloat = self.dropdownOpen ? 0 : CGFloat(cellCount*Int(CellHeight.walletMosaicCell))
            self.dropdownTable.alpha = self.dropdownOpen ? 0 : 1
            self.shadowView.alpha = self.dropdownOpen ? 0 : 1
            self.shadowViewHeight.constant = self.dropdownHeight(heightValue)
            self.dropdownTableHeight.constant = self.dropdownHeight(heightValue)
            self.tableView.alpha = self.dropdownOpen ? 1 : 0
            self.view.layoutIfNeeded()
        }) { (true) in
            self.dropdownOpen = !self.dropdownOpen
        }
    }

    @IBAction func showWalletOptions(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: WalletHomeStrings.newWallet, message: nil, preferredStyle: .actionSheet)
        let importWithQR = UIAlertAction(title: WalletHomeStrings.importWallet, style: .default) { (action) in
            self.setupQRScanner()
        }
        
        let importWithPrivateKey = UIAlertAction(title: WalletHomeStrings.importFromPK, style: .default) { (action) in
            self.prepareImportWalletScreen()
        }
        
        let createNewWalletBtn = UIAlertAction(title: WalletHomeStrings.createNewWallet, style: .default) { (action) in
            self.prepareNewWalletScreen()
        }
        let cancelBtn = UIAlertAction(title: CANCEL, style: .cancel) { (_) in }
        alert.addAction(importWithQR)
        alert.addAction(importWithPrivateKey)
        alert.addAction(createNewWalletBtn)
        alert.addAction(cancelBtn)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func prepareNewWalletScreen() {
        if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.newWalletVC) as? NewWalletVC {
            present(vc, animated: true, completion: nil)
        }
    }
    
    func prepareImportWalletScreen() {
        if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.importWalletVC) as? ImportWalletVC {
            present(vc, animated: true, completion: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return account.mosaics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.walletMosaicCell) as? CurrencyCell {
            let mosaic = account.mosaics[indexPath.row]
            cell.configureCell(mosaic)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mosaic = account.mosaics[indexPath.row]
        if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.currencyDetailsVC) as? CurrencyDetailsVC {
            if let navigator = navigationController {
                vc.hidesBottomBarWhenPushed = true
                vc.assignTxsAndCurrencyInfo(mosaic: mosaic)
                navigator.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CellHeight.walletMosaicCell
    }
    
}
