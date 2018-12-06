//
//  SettingSelectionVC.swift
//  Meteor
//
//  Created by Nathan Brewer on 8/29/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

class SettingSelectionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var disclaimerView: UITextView!
    
    private var currentSelection = CurrencyConverter.instance.localeCode
    var cells: SettingsData?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(openUrl))
        disclaimerView.addGestureRecognizer(tap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disclaimerView.gestureRecognizers?.removeAll()
    }
    
    @objc func openUrl() {
        if let url = URL(string: ExternalUrls.cryptoCompare) {
            UIApplication.shared.open(url)
        }
    }
    
    func prepareData(_ data: SettingsData, navTitle: String) {
        cells = data
        navigationItem.title = navTitle
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.settingCell) as? SettingsCell {
            guard let cellModel = cells else { return UITableViewCell() }
            switch cellModel {
            case .currency(let curr):
                disclaimerView.isHidden = false
                let titles = curr.titles[indexPath.row]
                cell.configureCell(titles, currentSelection: currentSelection)
            case .language(let lang):
                disclaimerView.isHidden = true
                cell.configureCell(lang.titles[indexPath.row], currentSelection: currentSelection)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SettingsCell {
            if let localeCode = cell.titleLbl.text {
                CurrencyConverter.instance.localeCode = localeCode
                currentSelection = localeCode
                tableView.reloadData()
            }
        }
    }

}
