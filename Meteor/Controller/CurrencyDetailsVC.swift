//
//  CurrencyDetailsVC.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/26/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

class CurrencyDetailsVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var balanceLbl: UILabel!
    @IBOutlet weak var mosaicIdLbl: UILabel!
    @IBOutlet weak var usdValueLbl: UILabel!
    @IBOutlet weak var noTxLbl: UILabel!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    private var txHistory = [Transaction]()
    private var mosaicInfo = Mosaic()
    private var nextPageId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupScreen()
        addSocketConnectObserver(#selector(setupScreen), owner: self)
        addSocketListeningObserver(#selector(setupScreen), owner: self)
        addSocketConfirmedTxObserver(#selector(setupScreen), owner: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let filteredTXs = FilterTransaction.fromCache(key: AppState.fromCache().selectedAddress + mosaicInfo.mosaicId.namespaceId + mosaicInfo.mosaicId.name)
        self.txHistory = filteredTXs.transactions
        self.nextPageId = filteredTXs.nextPageId
        self.tableview.reloadData()
        if txHistory.count > 0 {
            loadingSpinner.stopAnimating()
        }
        SocketService.instance.delegate = self
        setNetworkStatus()
    }
    
    @objc func setupScreen() {
        loadingSpinner.color = UIColor.bsPrimary
        loadingSpinner.tintColor = UIColor.primaryLight
        let filterBody = FilterTXBody.init(address: AppState.fromCache().selectedAddress, mosaicId: mosaicInfo.mosaicId, nextPageId: nil)
        loadTransactionHistory(filterBody: filterBody)
        balanceLbl.text = mosaicInfo.quantity.decimalFormat(mosaicInfo.properties.divisibility).thousandsSeparator(mosaicInfo.properties.divisibility)
        mosaicIdLbl.text = mosaicInfo.mosaicId.name
        usdValueLbl.isHidden = !mosaicInfo.isXEM
        if mosaicInfo.isXEM {
            CurrencyConverter.instance.convert(mosaicInfo.mosaicId.name) { (success) in
                if success {
                    self.usdValueLbl.text = self.mosaicInfo.quantity.localeValue(self.mosaicInfo.properties.divisibility)
                }
            }
        }
    }
    
    func loadTransactionHistory(filterBody: FilterTXBody) {
        FilterTransaction.fetchFilterTransactions(filterTransaction: filterBody) { (data) in
            self.loadingSpinner.stopAnimating()
            if let filterTransaction = data as? FilterTransaction {
                self.txHistory = filterTransaction.transactions
                self.noTxLbl.isHidden = self.txHistory.count > 0
                self.nextPageId = filterTransaction.nextPageId
                self.tableview.reloadData()
            }
        }
    }

    func assignTxsAndCurrencyInfo(mosaic: Mosaic) {
        mosaicInfo = mosaic
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return txHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.walletDetailCell) as? CurrencyDetailCell {
            let tx = txHistory[indexPath.row]
            cell.configureCell(tx: tx, mosaicProperites: mosaicInfo.properties)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.transactionDetailVC) as? TransactionDetailVC {
            if let navigator = navigationController {
                vc.assignTxsDetails(details: txHistory[indexPath.row], properties: mosaicInfo.properties)
                vc.hidesBottomBarWhenPushed = true
                navigator.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CellHeight.walletDetailCell
    }
}




