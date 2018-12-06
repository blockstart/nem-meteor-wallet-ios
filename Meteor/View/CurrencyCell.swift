//
//  CurrencyCell.swift
//  Meteor
//
//  Created by Nathan Brewer on 6/26/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell {
    
    @IBOutlet weak var currencyImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var amountNameLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureCell(_ mosaic: Mosaic) {
       self.currencyImg.image = UIImage(named: "mosaic_default_image")
        if let img = UIImage(named: "\(mosaic.mosaicId.namespaceId)\(mosaic.mosaicId.name)") {
            self.currencyImg.image = img
        }
        self.nameLbl.text = mosaic.mosaicId.name
        self.amountLbl.text = "\(mosaic.quantity.decimalFormat(mosaic.properties.divisibility).thousandsSeparator(mosaic.properties.divisibility))"
        self.amountNameLbl.text = mosaic.ticker ?? ""
    }

}
