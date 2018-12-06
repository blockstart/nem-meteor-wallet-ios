//
//  EmailSentVC.swift
//  Blockstart
//
//  Created by Nathan Brewer on 7/17/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import Lottie

class EmailSentVC: BaseVC {

    @IBOutlet weak var headerTextLbl: UILabel!
    @IBOutlet weak var currentNetworkLbl: UILabel!
    
    private var backupMethod = ""
    private var headerTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentNetworkLbl.text = currentNetwork()
    }
    
    func assignBackupMethod(_ location: String, header: String) {
        backupMethod = location
        headerTitle = header
    }
    
    func setupScreen() {
        headerTextLbl.addBoldText(fullText: "\(headerTitle) \(backupMethod)", bold: [backupMethod])
    }

    @IBAction func btnTapped(_ sender: UIButton) {
        let lottie = LOTAnimationView(name: AnimationJson.checkmarkGreen)
        view.addLottieAnimation(lottie) {
            self.fadeOut()
        }
    }
    
    func fadeOut() {
        if let vc = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.rootVC) as? RootController {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
}
