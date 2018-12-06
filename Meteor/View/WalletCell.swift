//
//  WalletCell.swift
//  Meteor
//
//  Created by Devslopes on 9/1/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

class WalletCell: UITableViewCell {
    
    @IBOutlet weak var walletNameLbl: UILabel!
    
    private var wallet: Wallet?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(_ wallet: Wallet) {
        self.wallet = wallet
        walletNameLbl.text = wallet.name
    }
    
    func returnCellsAddress() -> String? {
        guard wallet != nil else { return nil }
        return self.wallet?.address.value
    }

}
