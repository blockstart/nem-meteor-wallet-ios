//
//  CurrencyDetailCell.swift
//  Meteor
//
//  Created by Nathan Brewer on 6/26/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

class CurrencyDetailCell: UITableViewCell {
    
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var currencyIdLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureCell(tx: Transaction, mosaicProperites: MosaicProperties) {
        statusImg.image = Helpers.instance.imgSentOrReceived(recipient: tx.recipient.value)
        statusLbl.text = Helpers.instance.sentOrReceived(recipient: tx.recipient.value)
        var quantity = tx._xem.quantity
        var mosaicName = "xem"
        if (tx._mosaics.count >= 1) {
            quantity = tx._mosaics[0].quantity
            mosaicName = tx._mosaics[0].mosaicId.name
        }
        amountLbl.text = quantity.decimalFormat(mosaicProperites.divisibility).thousandsSeparator(mosaicProperites.divisibility)
        timestampLbl.text = "\(tx.timeWindow.timeStamp.formatTimestamp)"
        currencyIdLbl.text = mosaicName
    }
}
