//
//  SendHomeVC.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/26/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications

class SendHomeVC: BaseVC, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, QRScanner {
    
    @IBOutlet weak var enterAddressView: UIView!
    @IBOutlet weak var currencyDropdown: UIView!
    @IBOutlet weak var currencyTable: UITableView!
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var currencyTableHeight: NSLayoutConstraint!
    @IBOutlet weak var shadowViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var scanQRCodeView: UIImageView!
    @IBOutlet weak var dropdownCurrencyImg: UIImageView!
    @IBOutlet weak var dropdownCurrencyNameLbl: UILabel!
    @IBOutlet weak var nextBtn: Button!
    @IBOutlet weak var mosaicBalanceLbl: UILabel!
    @IBOutlet weak var addressStack: UIStackView!
    @IBOutlet weak var badAddressLbl: UILabel!
    
    private var dropdownOpen = false
    private var account = Account.fromCache(key: AppState.fromCache().selectedAddress)
    private var selectedMosaic = Mosaic()
    private var scanner = QRCodeScanner()
    private var createTx = CreateTransaction()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSocketConnectObserver(#selector(refreshAccountDetails), owner: self)
        addSocketListeningObserver(#selector(refreshAccountDetails), owner: self)
        addSocketConfirmedTxObserver(#selector(refreshAccountDetails), owner: self)
        setupScreen()
        currencyTable.delegate = self
        currencyTable.dataSource = self
        changeNextBtnState(enable: false)
        badAddressLbl.textColor = .bsRed
        addressTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNetworkStatus()
        addTapGesturesForVC()
        account = Account.fromCache(key: AppState.fromCache().selectedAddress)
        selectedMosaic = Mosaic()
        if account.mosaics.count > 0 {
            selectedMosaic = account.mosaics[0]
        }
        updateDropdownBar(selectedMosaic)
        currencyTable.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        currencyDropdown.gestureRecognizers?.removeAll()
        scanQRCodeView.gestureRecognizers?.removeAll()
        view.gestureRecognizers?.removeAll()
    }
    
    @objc func refreshAccountDetails() {
        account = Account.fromCache(key: AppState.fromCache().selectedAddress)
        if account.mosaics.count > 0 {
            if let updatedMosaic = account.mosaics.first(where: {$0.mosaicId.namespaceId + $0.mosaicId.name == selectedMosaic.mosaicId.namespaceId + selectedMosaic.mosaicId.name}) {
                updateDropdownBar(updatedMosaic)
                currencyTable.reloadData()
            }
        }
    }
    
    func setupScreen() {
        if let address = Deeplinker.requestAddress, let requestedMosaic = Deeplinker.requestMosaic, let requestAmount = Deeplinker.requestAmount {
            if let userMosaic = account.mosaics.first(where: {$0.mosaicId.namespaceId + $0.mosaicId.name == requestedMosaic}) {
                let quantity = requestAmount.toApiReadable(userMosaic.properties.divisibility)
                if userMosaic.quantity >= quantity {
                    let txMosaic = Mosaic(mosaicId: userMosaic.mosaicId, properties: userMosaic.properties, levy: userMosaic.levy, quantity: quantity, ticker: userMosaic.ticker, isXEM: userMosaic.isXEM)
                    createTx = CreateTransaction(address: address, mosaic: txMosaic, message: "")
                    goToConfirmationScreen(createTx, userMosaic: userMosaic)
                } else {
                    present(Alert.instance.singleMsgAlert(title: AlertMessage.insufficientFunds, message: "You do not have the \(quantity.decimalFormat(userMosaic.properties.divisibility)) \(userMosaic.mosaicId.name) that was requested"), animated: true, completion: nil)
                    Deeplinker.clearUserDefaults()
                }
                
            } else {
                present(Alert.instance.singleMsgAlert(title: AlertMessage.missingMosaic, message: "You do not have the \(requestedMosaic) Mosaic that was requested"), animated: true, completion: nil)
                Deeplinker.clearUserDefaults()
            }
        }
    }
    
    func setupQrScanner() {
        scanner = QRCodeScanner()
        scanner.delegate = self
        scanner.checkCameraPermissions { (granted) in
            if granted {
                DispatchQueue.main.async {
                    let dropdownPadding: CGFloat = 260
                    self.scanner.prepareCaptureSession(dropdownPadding)
                    self.scanner.videoPreview.frame = self.enterAddressView.bounds
                    self.enterAddressView.addSubview(self.scanner.videoPreview)
                } 
            }
        }
    }
    
    func changeNextBtnState(enable: Bool) {
        nextBtn.isEnabled = enable
        if enable {
            nextBtn.alpha = 1.0
        } else {
            nextBtn.alpha = 0.4
        }
    }
    
    func scanResult(result: String) {
        scanner.videoPreview.removeFromSuperview()
        if let data = result.data(using: .utf8) {
            if let nanoData = data.returnResult(NanoAccountInfoQR.self) {
                addressTF.text = nanoData.data.addr
                if let range = NSRange(nanoData.data.addr) {
                    _ = textField(addressTF, shouldChangeCharactersIn: range, replacementString: nanoData.data.addr)
                    return
                }
            }
        }
        addressTF.text = result
        if let range = NSRange(result) {
            _ = textField(addressTF, shouldChangeCharactersIn: range, replacementString: result)
        }
    }
    
    func cancelSession() {
        scanner.videoPreview.removeFromSuperview()
    }
    
    func accessDenied() {
        present(Alert.instance.singleMsgAlert(title: AlertMessage.notAuthorized, message: AlertMessage.cameraAccess), animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        badAddressLbl.isHidden = true
        if !string.isEmpty {
            if let text = textField.text {
                let newString = NSString(string: text).replacingCharacters(in: range, with: string)
                formatAddressCheck(newString)
            }
        }
        return true
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        if let text = sender.text {
            formatAddressCheck(text)
        }
    }
    
    func formatAddressCheck(_ address: String) {
        Account.formatAddress(address: address, onComplete: { formattedAddress in
            if let _ = formattedAddress as? AddressObj {
                self.changeNextBtnState(enable: true)
            }
        }) { err in
            if let err = err as? APIError {
                self.badAddressLbl.text = err.message
                self.badAddressLbl.isHidden = false
                self.changeNextBtnState(enable: false)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func addTapGesturesForVC() {
        let currencyMenuTap = UITapGestureRecognizer(target: self, action: #selector(showCurrencyMenu(_:)))
        currencyDropdown.addGestureRecognizer(currencyMenuTap)
        let qrScannerTap = UITapGestureRecognizer(target: self, action: #selector(scanQRCode(_:)))
        scanQRCodeView.addGestureRecognizer(qrScannerTap)
        let keyboardDismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(keyboardDismissTap)
        keyboardDismissTap.cancelsTouchesInView = false
    }
    
    @objc func scanQRCode(_ sender: UITapGestureRecognizer) {
        setupQrScanner()
    }
    
    func updateDropdownBar(_ selection: Mosaic) {
        CurrencyConverter.instance.convert(selection.mosaicId.name) { (_) in }
        mosaicBalanceLbl.text = selection.quantity.decimalFormat(selection.properties.divisibility).thousandsSeparator(selection.properties.divisibility)
        dropdownCurrencyNameLbl.text = selection.mosaicId.name
        dropdownCurrencyImg.image = UIImage(named: "\(selection.mosaicId.namespaceId)\(selection.mosaicId.name)") ?? UIImage(named: "mosaic_default_image")
    }
    
    func showError(_ msg: String) {
        addressStack.shake()
        badAddressLbl.isHidden = false
        badAddressLbl.text = msg
    }
    
    @IBAction func nextBtnTapped(_ sender: Button) {
        guard account.mosaics.count >= 1 else { return }
        guard let address = addressTF.text?.trim() else { return }
        Account.formatAddress(address: address, onComplete: { formattedAddress in
            let txMosaic = Mosaic(mosaicId: self.selectedMosaic.mosaicId, properties: self.selectedMosaic.properties, levy: self.selectedMosaic.levy, quantity: 0, ticker: self.selectedMosaic.ticker, isXEM: self.selectedMosaic.isXEM)
            let createTx = CreateTransaction.init(address: address, mosaic: txMosaic, message: "")
            self.goToSendAmountScreen(createTx)
        }) { err in
            if let err = err as? APIError {
                self.showError(err.message)
            }
        }
    }
    
    func goToSendAmountScreen(_ tx: CreateTransaction) {
        if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.sendAmountVC) as? SendAmountVC {
            if let navigator = navigationController {
                vc.transactionInProgress(tx, userMosaic: selectedMosaic)
                vc.hidesBottomBarWhenPushed = true
                navigator.pushViewController(vc, animated: true)
            }
        }
    }
    
    func goToConfirmationScreen(_ tx: CreateTransaction, userMosaic: Mosaic) {
        if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.sendConfirmationVC) as? SendConfirmationVC {
            if let nav = navigationController {
                vc.loadTransactionInfo(tx, userMosaic: userMosaic)
                vc.hidesBottomBarWhenPushed = true
                nav.pushViewController(vc, animated: true)
            }
        }
    }
    
    func dropdownHeight(_ height: CGFloat) -> CGFloat {
        let maxHeight = enterAddressView.frame.size.height
        return height < maxHeight ? height : maxHeight
    }
    
    @objc func showCurrencyMenu(_ sender: UITapGestureRecognizer) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            let cellCount = self.account.mosaics.count
            let heightValue: CGFloat = self.dropdownOpen ? 0 : CGFloat(cellCount*Int(CellHeight.sendMosaicCell))
            self.currencyTable.alpha = self.dropdownOpen ? 0 : 1
            self.shadowView.alpha = self.dropdownOpen ? 0 : 1
            self.shadowViewHeight.constant = self.dropdownHeight(heightValue)
            self.currencyTableHeight.constant = self.dropdownHeight(heightValue)
            self.enterAddressView.alpha = self.dropdownOpen ? 1 : 0
            self.view.layoutIfNeeded()
        }) { (true) in
            self.dropdownOpen = !self.dropdownOpen
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return account.mosaics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.sendMosaicCell) as? SendCurrencyCell {
            if self.account.mosaics.count > 0 {
                let ownedCurrency = account.mosaics[indexPath.row]
                cell.configureCell(ownedCurrency, selected: selectedMosaic)
                return cell
            } else {
                cell.noOwnedCurrency()
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SendCurrencyCell {
            guard let cellMosaic = cell.returnSelectedMosaic() else { return }
            selectedMosaic = cellMosaic
            updateDropdownBar(selectedMosaic)
            currencyTable.reloadData()
            showCurrencyMenu(UITapGestureRecognizer())
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CellHeight.sendMosaicCell
    }
    
}





