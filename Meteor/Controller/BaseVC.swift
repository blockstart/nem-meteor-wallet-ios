//
//  BaseVC.swift
//  Meteor
//
//  Created by Nathan Brewer on 9/13/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

class BaseVC: UIViewController, SocketConnectionDelegate {
    
    static let SOCKET_CONNECT_OBS = "socket_connect_obs"
    static let SOCKET_LISTENING_OBS = "socket_listening_obs"
    static let SOCKET_CONFIRMED_TX_OBS = "socket_confirmed_tx_obs"
    static let SOCKET_UNCONFIRMED_TX_OBS = "socket_unconfirmed_tx_obs"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func setNetworkStatus() {
        let appState = AppState.fromCache()
        let title = appState.currentNetwork == NetworkTypeStrings.main ? "" : "•Test"
        let item = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        item.tintColor = UIColor.bsOrange
        item.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: MeteorFonts.fontBold, size: 16) as Any], for: .normal)
        navigationItem.setRightBarButton(item, animated: true)
    }
    
    func currentNetwork() -> String {
        let appState = AppState.fromCache()
        return appState.currentNetwork == NetworkTypeStrings.main ? "" : "•Test"
    }
    
    func observerNamed(_ selector: Selector, name: String, owner: UIViewController) {
        NotificationCenter.default.addObserver(owner, selector: selector, name: Notification.Name(rawValue: name), object: nil)
    }
    
    func addSocketConnectObserver(_ selector: Selector, owner: UIViewController) {
        observerNamed(selector, name: BaseVC.SOCKET_CONNECT_OBS, owner: owner)
    }
    
    func addSocketListeningObserver(_ selector: Selector, owner: UIViewController) {
        observerNamed(selector, name: BaseVC.SOCKET_LISTENING_OBS, owner: owner)
    }
    
    func addSocketConfirmedTxObserver(_ selector: Selector, owner: UIViewController) {
        observerNamed(selector, name: BaseVC.SOCKET_CONFIRMED_TX_OBS, owner: owner)
    }
    
    func addSocketUnconfirmedTxObserver(_ selector: Selector, owner: UIViewController) {
        observerNamed(selector, name: BaseVC.SOCKET_UNCONFIRMED_TX_OBS, owner: owner)
    }
    
    func onSocketEvent(event: String, data: Any?) {
        switch event {
        case SocketService.CONNECT:
            debugPrint("refresh account data")
            NotificationCenter.default.post(Notification(name: Notification.Name(BaseVC.SOCKET_CONNECT_OBS)))
            break
        case SocketService.LISTENING:
            debugPrint("refresh account data")
            NotificationCenter.default.post(Notification(name: Notification.Name(BaseVC.SOCKET_LISTENING_OBS)))
            break
        case SocketService.CONFIRMED_TX:
            debugPrint("refresh account data")
            NotificationCenter.default.post(Notification(name: Notification.Name(BaseVC.SOCKET_CONFIRMED_TX_OBS)))
            break
        case SocketService.UNCONFIRMED_TX:
            NotificationCenter.default.post(Notification(name: Notification.Name(BaseVC.SOCKET_UNCONFIRMED_TX_OBS)))
            break
        default:
            break
        }
    }
    
}
