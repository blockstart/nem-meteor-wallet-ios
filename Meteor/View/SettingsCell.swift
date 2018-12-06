//
//  SettingsCell.swift
//  Meteor
//
//  Created by Nathan Brewer on 8/29/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var isSelectedImg: UIImageView!
    
    func configureCell(_ title: String, currentSelection: String) {
        isSelectedImg.image = (title == currentSelection) ? UIImage(named: "dropdown_checkmark") : nil
        titleLbl.text = title
    }

}
