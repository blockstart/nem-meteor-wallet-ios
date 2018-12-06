//
//  SendAmountVC.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/27/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

class SendAmountVC: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var recipientAddressLbl: UILabel!
    @IBOutlet weak var sendAmountTF: UITextField!
    @IBOutlet weak var currencyTypeLbl: UILabel!
    @IBOutlet weak var currencyValueLbl: UILabel!
    @IBOutlet weak var swapCurrencyIcon: UIImageView!
    @IBOutlet weak var insufficientFundsLbl: UILabel!
    @IBOutlet weak var mosaicBalanceLbl: UILabel!
    
    private var account = Account.fromCache(key: AppState.fromCache().selectedAddress)
    private var createdTx = CreateTransaction()
    private var selectedMosaic = Mosaic()
    private var showUsd = false
    private var isPaymentRequest = false
    private var composer = MessageBuilder()
    private var divisibility = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNetworkStatus()
        addGestures()
        mosaicBalanceLbl.text = "Bal.".localized + " " + selectedMosaic.quantity.decimalFormat(divisibility).thousandsSeparator(divisibility)
        swapCurrencyIcon.isHidden = !selectedMosaic.isXEM
        currencyValueLbl.isHidden = !selectedMosaic.isXEM
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isPaymentRequest = false
        swapCurrencyIcon.gestureRecognizers?.removeAll()
    }
    
    func setupScreen() {
        if let payload = payloadFromDeepLink() {
            sendAmountTF.text = payload.amount
            currencyTypeLbl.text = payload.currency
        }
        insufficientFundsLbl.textColor = UIColor.bsRed
        sendAmountTF.becomeFirstResponder()
        currencyTypeLbl.text = createdTx.mosaic.mosaicId.name
        recipientAddressLbl.text = createdTx.address
        sendAmountTF.inputAccessoryView = createAccessoryView()
        showUsd = false
        adjustMarketValue()
        Deeplinker.clearUserDefaults()
    }
    
    func transactionInProgress(_ tx: CreateTransaction, userMosaic: Mosaic, isRequest: Bool = false) {
        createdTx = tx
        selectedMosaic = userMosaic
        isPaymentRequest = isRequest
        divisibility = userMosaic.properties.divisibility
    }
    
    func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(swapCurrencyValue))
        swapCurrencyIcon.addGestureRecognizer(tap)
    }
    
    func payloadFromDeepLink() -> DeepLinkPayload? {
        if let amount = Deeplinker.requestAmount, let currency = Deeplinker.requestMosaic, let address = Deeplinker.requestAddress {
            return DeepLinkPayload(address: address, amount: amount, currency: currency)
        }
        return nil
    }
    
    @objc func swapCurrencyValue() {
        showUsd = !showUsd
        sendAmountTF.text = swappedValue(from: showUsd)
        adjustMarketValue()
    }
    
    func swappedValue(from usd: Bool) -> String {
        let locale = NSLocale.current
        let commaSeparator = locale.groupingSeparator ?? ","
        if let inputValue = currencyValueLbl.text?.replacingOccurrences(of: commaSeparator, with: "") {
            return usd ? trimStringFromUsd(inputValue) : trimStringFromCrypto(inputValue)
        }
        return "n/a"
    }
    
    func usdLbl() -> UILabel {
        let usdLbl = UILabel()
        usdLbl.frame.size = CGSize(width: 25, height: 50)
        usdLbl.text = CurrencyConverter.currentMosaicsRate.localeSymbol
        usdLbl.textColor = .darkGray
        usdLbl.font = UIFont(name: MeteorFonts.fontRegular, size: 40)
        return usdLbl
    }
    
    func adjustMarketValue() {
        guard createdTx.mosaic.mosaicId.name != "" else { return }
        let index = sendAmountTF.text?.decimalIndex() ?? 0
        guard let value = sendAmountTF.text?.toApiReadable(index) else { return }
            if showUsd {
                currencyValueLbl.text = value.cryptoValueFromLocale(divisibility, inputIndex: index) + " " + (createdTx.mosaic.ticker ?? "")
                currencyTypeLbl.text = CurrencyStrings.USD
                sendAmountTF.leftViewMode = .always
                sendAmountTF.leftView = usdLbl()
            } else {
                currencyValueLbl.text = value.localeValue(index)
                currencyTypeLbl.text = createdTx.mosaic.ticker
                sendAmountTF.leftViewMode = .never
                sendAmountTF.leftView = nil
            }
    }
    
    func trimStringFromUsd(_ str: String) -> String {
        let prefix = String(str.dropLast(6))
        return String(prefix.dropFirst(2))
    }
    
    func trimStringFromCrypto(_ str: String) -> String {
        return String(str.dropLast(4))
    }
    
    func createAccessoryView() -> UIView {
        let bgColor: UIColor = .primaryLight
        let btnTitle = isPaymentRequest
            ? SEND
            : NEXT
        let action = isPaymentRequest
            ? #selector(sendPaymentRequest(_:))
            : #selector(goToConfirmationScreen(_:))
        let accessory = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        accessory.translatesAutoresizingMaskIntoConstraints = false
        accessory.backgroundColor = bgColor
        let nextBtn = UIButton(frame: accessory.bounds)
        nextBtn.setTitle(btnTitle, for: .normal)
        nextBtn.titleLabel?.font = UIFont(name: MeteorFonts.fontBold, size: 16)
        nextBtn.addTarget(self, action: action, for: UIControlEvents.touchUpInside)
        accessory.addSubview(nextBtn)
        return accessory
    }
    
    @objc func goToConfirmationScreen(_ sender: UIButton) {
        let index = sendAmountTF.text?.decimalIndex() ?? 0
        let diviser = showUsd ? index : divisibility
        guard let sendAmount = sendAmountTF.text?.toApiReadable(diviser) else { return }
        let mosaicAmount = showUsd
            ? sendAmount.cryptoValueFromLocale(divisibility, inputIndex: index).toApiReadable(divisibility)
            : sendAmount
        guard mosaicAmount <= selectedMosaic.quantity else {
            present(Alert.instance.singleMsgAlert(title: AlertMessage.insufficientFunds, message: ""), animated: true, completion: nil)
            return
        }
        if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.sendConfirmationVC) as? SendConfirmationVC {
            if let nav = navigationController {
                vc.hidesBottomBarWhenPushed = true
                createdTx.mosaic.quantity = mosaicAmount
                vc.loadTransactionInfo(createdTx, userMosaic: selectedMosaic)
                nav.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func sendPaymentRequest(_ sender: UIButton) {
        guard let sendAmount = sendAmountTF.text else { return }
        Deeplinker.clearUserDefaults()
        composer = MessageBuilder()
        let urlComp = NSURLComponents()
        urlComp.scheme = SCHEME
        urlComp.host = HOST
        urlComp.path = PATH
        let address = NSURLQueryItem(name: RECIPIENT, value: account.address)
        let amount = NSURLQueryItem(name: AMOUNT, value: sendAmount)
        let currency = NSURLQueryItem(name: CURRENCY, value: selectedMosaic.mosaicId.namespaceId + selectedMosaic.mosaicId.name)
        urlComp.queryItems = [address, amount, currency] as [URLQueryItem]
        if let url = urlComp.url {
            if composer.canCompose {
                composer.body = SMS_BODY + " " + String(describing: url)
                composer.show(self)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let locale = NSLocale.current
        let separator = locale.decimalSeparator ?? "."
        var decimalPlaces = showUsd ? 2 : divisibility
        if CurrencyConverter.instance.localeCode == "BTC" {
            decimalPlaces = 8
        }
        if let text = textField.text {
            if !string.isEmpty {
                if text.contains(separator) {
                    if text.components(separatedBy: separator)[1].count == decimalPlaces {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    @IBAction func editingChanged(_ sender: Any) {
        if !isPaymentRequest && !showUsd {
            if let inputAmount = sendAmountTF.text?.toApiReadable(divisibility) {
                sendAmountTF.textColor = selectedMosaic.quantity >= inputAmount
                    ? UIColor.darkGray
                    : UIColor.bsRed
                insufficientFundsLbl.isHidden = selectedMosaic.quantity >= inputAmount ? true : false
            }
        } else {
            sendAmountTF.textColor = UIColor.darkGray
            insufficientFundsLbl.isHidden = true
        }
        adjustMarketValue()
    }
    
}
