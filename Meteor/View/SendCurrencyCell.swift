//
//  SendCurrencyCell.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/26/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

class SendCurrencyCell: UITableViewCell {
    
    @IBOutlet weak var currencyImg: UIImageView!
    @IBOutlet weak var currencyName: UILabel!
    @IBOutlet weak var isSelectedImg: UIImageView!
    var mosaic: Mosaic?

    func configureCell(_ mosaic: Mosaic, selected: Mosaic) {
        self.mosaic = mosaic
        currencyImg.image = UIImage(named: "\(mosaic.mosaicId.namespaceId)\(mosaic.mosaicId.name)") ?? UIImage(named: "mosaic_default_image")
        currencyName.text = mosaic.mosaicId.name
        isSelectedImg.image = (mosaic.mosaicId.namespaceId + mosaic.mosaicId.name == selected.mosaicId.namespaceId + selected.mosaicId.name) ? UIImage(named: "dropdown_checkmark") : nil
    }
    
    func returnSelectedMosaic() -> Mosaic? {
        return self.mosaic
    }
    
    func noOwnedCurrency() {
        currencyName.text = NO_CURRENCY_IN_WALLET
    }

}
