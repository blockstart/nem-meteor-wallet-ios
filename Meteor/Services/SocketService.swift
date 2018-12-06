//
//  SocketService.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/14/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import SocketIO

class SocketService: NSObject {
    
    static let instance = SocketService();
    static let CONNECT = "connect"
    static let SETUP_CONFIRMED_OBSERVER = "setupConfirmedObserver"
    static let SETUP_UNCONFIRMED_OBSERVER = "setupUnconfirmedObserver"
    static let CONFIRMED_TX = "confirmedTx"
    static let UNCONFIRMED_TX = "unconfirmedTx"
    static let LISTENING = "listening"
    private let SELECTED_ADDRESS = "selectedAddress"
   
    let manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!)
    var socket: SocketIOClient
    var delegate: SocketConnectionDelegate?
    

    override init() {
        self.socket = manager.defaultSocket
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(onAppStateChanged), name: AppState.NOTIF_APP_STATE_UPDATED, object: nil)
    }
    
    func openConnection() {
        socket.connect()
        setupListeners(address: AppState.fromCache().selectedAddress)
    }
    
    func closeConnection(){
        socket.disconnect()
    }
    
    func setupListeners(address: String) {
        socket.on(SocketService.CONNECT) { _, _ in
            self.delegate?.onSocketEvent(event: SocketService.CONNECT, data: nil)
            self.addListeners(address: address)
        }
    }
    
    @objc func onAppStateChanged() {
        addListeners(address: AppState.fromCache().selectedAddress)
    }
    
    func addListeners(address: String) {
        if (address != "") {
            debugPrint("listening on address: \(address)")
            self.socket.emit(SocketService.SETUP_CONFIRMED_OBSERVER, address)
            self.socket.emit(SocketService.SETUP_UNCONFIRMED_OBSERVER, address)
            self.socket.on(SocketService.CONFIRMED_TX) { (data, _) in
                if data.count > 0 {
                    let tx = data[0]
                    self.delegate?.onSocketEvent(event: SocketService.CONFIRMED_TX, data: tx)
                }
            }
            self.socket.on(SocketService.UNCONFIRMED_TX) { (data, _) in
                if data.count > 0 {
                    let tx = data[0]
                    self.delegate?.onSocketEvent(event: SocketService.UNCONFIRMED_TX, data: tx)
                }
            }
        }
    }
}
