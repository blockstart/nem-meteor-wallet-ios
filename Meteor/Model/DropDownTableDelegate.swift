//
//  DropDownTableDelegate.swift
//  Meteor
//
//  Created by Nathan Brewer on 8/18/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

class DropDownTableDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    fileprivate var accounts = Account.allFromCache(addresses: AppState.fromCache().addresses, networkFilter: AppState.fromCache().currentNetwork)
    var delegate: DropdownDelegate?
    
    init(_ delegate: DropdownDelegate) {
        self.delegate = delegate
        accounts = Account.allFromCache(addresses: AppState.fromCache().addresses, networkFilter: AppState.fromCache().currentNetwork)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.walletCell) as? WalletCell {
            let wallet = accounts[indexPath.row].wallet
            cell.configureCell(wallet)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? WalletCell {
            guard let address = cell.returnCellsAddress() else { return }
            delegate?.didSelectCell(address)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let removedAccount = accounts[indexPath.row]
            accounts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            var appState = AppState.fromCache()
            if appState.selectedAddress == removedAccount.address {
                appState.selectedAddress = accounts.count > 0 ? accounts[0].address : ""
            }
            appState.addresses.removeAll(where: {$0 == removedAccount.address})
            appState.save()
            delegate?.didDeleteCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}
