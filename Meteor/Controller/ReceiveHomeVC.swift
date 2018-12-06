//
//  ReceiveHomeVC.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/27/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

class ReceiveHomeVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var currencyTable: UITableView!
    @IBOutlet weak var dropdownView: UIView!
    @IBOutlet weak var dropdownCurrencyImg: UIImageView!
    @IBOutlet weak var dropdownCurrencyNameLbl: UILabel!
    @IBOutlet weak var dropdownLeftIconImg: UIImageView!
    @IBOutlet weak var balanceAmountLbl: UILabel!
    @IBOutlet weak var QRCodeImg: UIImageView!
    @IBOutlet weak var copyAddressBtn: Button!
    @IBOutlet weak var greyBlockView: UIView!
    @IBOutlet weak var paymentRequestBtn: Button!
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var currencyTableHeight: NSLayoutConstraint!
    @IBOutlet weak var shadowViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addressCopiedLbl: UILabel!
    
    private var dropdownOpen = false
    private var account = Account.fromCache(key: AppState.fromCache().selectedAddress)
    private var selectedMosaic = Mosaic()
    private var scanner = QRCodeScanner()

    override func viewDidLoad() {
        super.viewDidLoad()
        addSocketConnectObserver(#selector(refreshAccountDetails), owner: self)
        addSocketListeningObserver(#selector(refreshAccountDetails), owner: self)
        addSocketConfirmedTxObserver(#selector(refreshAccountDetails), owner: self)
        setupScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNetworkStatus()
        addDropdownGestures()
        account = Account.fromCache(key: AppState.fromCache().selectedAddress)
        if account.mosaics.count > 0 {
            selectedMosaic = account.mosaics[0]
            updateDropdownBar(selectedMosaic)
        }
        currencyTable.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dropdownView.gestureRecognizers?.removeAll()
    }
    
    func setupScreen() {
        addressCopiedLbl.backgroundColor = .primaryLight
        scanner = QRCodeScanner()
        if let QRImage = scanner.generateQRCode(from: account.address) {
            QRCodeImg.image = QRImage
        }
    }
    
    @objc func refreshAccountDetails() {
        account = Account.fromCache(key: AppState.fromCache().selectedAddress)
        if account.mosaics.count > 0 {
            if let updatedMosaic = account.mosaics.first(where: {$0.mosaicId.namespaceId + $0.mosaicId.name == selectedMosaic.mosaicId.namespaceId + selectedMosaic.mosaicId.name}) {
                updateDropdownBar(updatedMosaic)
            }
        }
    }
    
    func addDropdownGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showCurrencyMenu(_:)))
        dropdownView.addGestureRecognizer(tap)
    }
    
    func updateDropdownBar(_ selection: Mosaic) {
        CurrencyConverter.instance.convert(selection.mosaicId.name) { (_) in }
        dropdownCurrencyNameLbl.text = selection.mosaicId.name
        dropdownCurrencyImg.image = UIImage(named: "\(selection.mosaicId.namespaceId)\(selection.mosaicId.name)")
        balanceAmountLbl.text = selection.quantity.decimalFormat(selection.properties.divisibility).thousandsSeparator(selection.properties.divisibility) + " " + selection.mosaicId.name
    }
    
    func dropdownHeight(_ height: CGFloat) -> CGFloat {
        var maxHeight = view.frame.size.height
        if #available(iOS 11.0, *) {
            maxHeight = view.safeAreaLayoutGuide.layoutFrame.size.height
        }
        return height < maxHeight ? height : maxHeight
    }
    
    @objc func showCurrencyMenu(_ sender: UITapGestureRecognizer) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            let heightValue: CGFloat = CGFloat(self.dropdownOpen ? 0 : self.account.mosaics.count * 50)
            self.currencyTable.alpha = self.dropdownOpen ? 0 : 1
            self.greyBlockView.alpha = self.dropdownOpen ? 0 : 1
            self.shadowView.alpha = self.dropdownOpen ? 0 : 1
            self.shadowViewHeight.constant = self.dropdownHeight(heightValue)
            self.currencyTableHeight.constant = self.dropdownHeight(heightValue)
            self.view.layoutIfNeeded()
        }) { (success) in
            if success {
                self.dropdownOpen = !self.dropdownOpen
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return account.mosaics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.receiveMosaicCell) as? SendCurrencyCell {
            if account.mosaics.count > 0 {
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
        let selection = account.mosaics[indexPath.row]
        selectedMosaic = selection
        updateDropdownBar(selectedMosaic)
        currencyTable.reloadData()
        showCurrencyMenu(UITapGestureRecognizer())
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CellHeight.sendMosaicCell
    }

    @IBAction func copyAddressTapped(_ sender: UIButton) {
        UIPasteboard.general.string = account.address
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCrossDissolve, animations: {
            self.addressCopiedLbl.alpha = 1.0
        }) { (success) in
            UIView.animate(withDuration: 0.2, delay: 0.8, animations: {
                self.addressCopiedLbl.alpha = 0
            })
        }
    }
    
    @IBAction func paymentRequestTapped(_ sender: UIButton) {
        if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.sendAmountVC) as? SendAmountVC {
            let createTx = CreateTransaction.init(address: account.address, mosaic: selectedMosaic, message: "")
            vc.transactionInProgress(createTx, userMosaic: selectedMosaic, isRequest: true)
            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func unwindFromRequest(_ segue: UIStoryboardSegue) {
        
    }
    
}
