//
//  SettingsTableVC.swift
//  Meteor
//
//  Created by Nathan Brewer on 8/29/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

class SettingsTableVC: UITableViewController {
    
    @IBOutlet weak var selectedCurrencyLbl: UILabel!
    @IBOutlet weak var networkSwitch: UISwitch!
    @IBOutlet weak var pinSwitch: UISwitch!
    
    private var composer = EmailManager()
    private var delegate: PrivateKeyDelegate?
    private var networkDelegate: NetworkChangeDelegate?
    private var account = Account.fromCache(key: AppState.fromCache().selectedAddress)
    private var appState = AppState.fromCache()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        appState = AppState.fromCache()
        networkSwitch.setOn((appState.currentNetwork == NetworkTypeStrings.main), animated: false)
        pinSwitch.setOn(LocalAuth.fromCache().pinLockEnabled, animated: false)
        selectedCurrencyLbl.text = CurrencyConverter.instance.localeCode
    }
    
    func assignDelegateOwner(_ delegate: PrivateKeyDelegate, networkDelegate: NetworkChangeDelegate) {
        self.delegate = delegate
        self.networkDelegate = networkDelegate
    }
    
    func sendFeedbackEmail() {
        composer = EmailManager()
        if composer.canCompose {
            composer.subject = EmailMessage.emailFeedbackSubject
            composer.recipients = [EmailMessage.emailFeedback]
            composer.body = ""
            composer.show()
        } else {
            present(Alert.instance.singleMsgAlert(title: ERROR, message: EmailMessage.noEmailFound), animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = UIColor.darkGray
            headerView.textLabel?.font = UIFont(name: MeteorFonts.fontLight, size: 17)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 1:
                //How to use Meteor Wallet
                break
            case 2:
                //Send Feedback
                sendFeedbackEmail()
            case 3:
                //Backup
                if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.backupWalletVC) as? BackupWalletVC {
                    hidesBottomBarWhenPushed = true
                    parent?.present(vc, animated: true, completion: nil)
                }
                break
            case 4:
                delegate?.privateKeyPrompt()
                break
            default:
                return
            }
        } else if indexPath.section == 1 {
            var preparedData: SettingsData? = nil
            var navigationTitle = ""
            switch indexPath.row {
            case 1:
                //Languages
                break
            case 2:
                preparedData = SettingsData.currency(Currency(codes: ["USD","JPY","EUR","GBP","BTC"]))
                navigationTitle = "Currency"
            default:
                return
            }
            if let data = preparedData {
                if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.settingSelectionVC) as? SettingSelectionVC {
                    vc.prepareData(data, navTitle: navigationTitle)
                    parent?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func toggleMainNet(_ sender: UISwitch) {
        let network = sender.isOn
            ? NetworkTypeStrings.main
            : NetworkTypeStrings.test
        let accountArray = Account.allFromCache(addresses: AppState.fromCache().addresses, networkFilter: network)
        if accountArray.count < 1 {
            showNoAccountsAlert(for: network)
        } else {
            appState.switchNetwork(to: network, address: accountArray[0].address) { (_) in
                self.networkDelegate?.networkChanged()
                self.account = Account.fromCache(key: AppState.fromCache().selectedAddress)
                self.account.refresh(onComplete: { (_) in })
            }
        }
    }
    
    @IBAction func togglePinLogin(_ sender: UISwitch) {
        sender.isOn
            ? showPinLoginWarning(sender)
            : showRemovePinLoginWarning(sender)
    }
    
    func showPinLoginWarning(_ sender: UISwitch) {
        let alert = UIAlertController(title: AuthStrings.enablePin, message: AuthStrings.enablePinWarning , preferredStyle: .alert)
        let okay = UIAlertAction(title: "OK", style: .default) { (action) in
            if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.pinVC) as? PinVC {
                vc.setInitialState(.SetPin)
                self.parent?.present(vc, animated: true, completion: nil)
            }
        }
        let cancel = UIAlertAction(title: CANCEL, style: .default) { (_) in
            sender.setOn(!sender.isOn, animated: true)
        }
        alert.addAction(okay)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func showRemovePinLoginWarning(_ sender: UISwitch) {
        let alert = UIAlertController(title: AuthStrings.disablePin, message: "", preferredStyle: .alert)
        let okay = UIAlertAction(title: "Yes", style: .default) { (action) in
            if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.pinVC) as? PinVC {
                vc.setInitialState(.RemovePin)
                self.parent?.present(vc, animated: true, completion: nil)
            }
        }
        let cancel = UIAlertAction(title: CANCEL, style: .default) { (_) in
            sender.setOn(!sender.isOn, animated: true)
        }
        alert.addAction(okay)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func showNoAccountsAlert(for network: String) {
        let alert = UIAlertController(title: AlertMessage.noStoredWallets, message: AlertMessage.noWalletNotice1 + " " + network + ", " + AlertMessage.noWalletNotice2, preferredStyle: .alert)
        let createNew = UIAlertAction(title: WalletCreation.createWallet, style: .default) { (action) in
            self.appState.switchNetwork(to: network, address: "", onComplete: { (_) in
                if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.newWalletVC) as? NewWalletVC {
                    self.present(vc, animated: true, completion: nil)
                }
            })
        }
        let cancel = UIAlertAction(title: CANCEL, style: .default) { (action) in
            self.networkSwitch.setOn(!self.networkSwitch.isOn, animated: true)
        }
        alert.addAction(createNew)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

}
