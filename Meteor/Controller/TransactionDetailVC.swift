//
//  TransactionDetailVC.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/26/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

class TransactionDetailVC: BaseVC {
    
    @IBOutlet weak var balanceLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var usdValueLbl: UILabel!
    @IBOutlet weak var recipientLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var transactionIdLbl: UILabel!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var signerAddressLbl: UILabel!
    @IBOutlet weak var feeLbl: UILabel!
    
    private var transactionDetails: Transaction!
    private var mosaicProperties: MosaicProperties!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNetworkStatus()
    }
    
    func setupScreen() {
        navItem.title = Helpers.instance.sentOrReceived(recipient: transactionDetails.recipient.value)
        var quantity = transactionDetails._xem.quantity
        var mosaicName = "xem"
        usdValueLbl.isHidden = false
        if(transactionDetails._mosaics.count >= 1) {
            quantity = transactionDetails._mosaics[0].quantity
            mosaicName = transactionDetails._mosaics[0].mosaicId.name
            usdValueLbl.isHidden = true
        }
        balanceLbl.text = quantity.decimalFormat(mosaicProperties.divisibility).thousandsSeparator(mosaicProperties.divisibility)
        nameLbl.text = mosaicName
        usdValueLbl.text = quantity.localeValue(mosaicProperties.divisibility)
        recipientLbl.text = transactionDetails.recipient.value
        signerAddressLbl.text = transactionDetails.signer.address
        dateLbl.text = "Date:".localized + " " + "\(transactionDetails.timeWindow.timeStamp.formatTimestamp)"
        feeLbl.text = "Fee:".localized + " " + "\(transactionDetails.fee.decimalFormat(6)) xem"
        let message = Message(payload: transactionDetails.message.payload)
        Transaction.decodeMessage(message: message, onComplete:  { (data) in
            if let message = data as? String {
                self.messageLbl.text = "Message:".localized + " " + message
                self.reloadInputViews()
            }
        })
        transactionIdLbl.text = "Transaction ID:".localized + "\n" + "\(transactionDetails.transactionInfo.hash.data)"
    }
    
    func assignTxsDetails(details: Transaction, properties: MosaicProperties) {
        transactionDetails = details
        mosaicProperties = properties
    }

    @IBAction func viewOnExplorerTapped(_ sender: UIButton) {
        let network = AppState.fromCache().currentNetwork
        let explorerUrl = (network == NetworkTypeStrings.main)
            ? ExternalUrls.mainNet
            : ExternalUrls.testNet
        if let url = URL(string: explorerUrl + transactionDetails.transactionInfo.hash.data) {
            UIApplication.shared.open(url)
        }
    }
}
