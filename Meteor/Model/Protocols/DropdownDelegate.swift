//
//  DropdownDelegate.swift
//  Meteor
//
//  Created by Nathan Brewer on 8/18/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit
protocol DropdownDelegate {
    func didSelectCell(_ selection: String)
    func didDeleteCell()
}
